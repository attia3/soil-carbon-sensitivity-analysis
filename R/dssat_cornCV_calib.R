#' Maize cultivar calibration using process-based model simulations
#'
#' Refactored from the research script dssat_cornCV_calib.R (2019).
#' Authors: Ahmed Attia and collaborators.
#' Study: Attia et al. (2021), Field Crops Research 260, 107981.
#' https://doi.org/10.1016/j.fcr.2020.107981
#'
#' Scientific method retained:
#' - cultivar-specific observations for SC10 and TC310;
#' - nitrogen = 190; dry matter at DAP 60/75; grain at DAP 110;
#' - weighted objective RMSE(dry matter)/100 + RMSE(grain yield)/50;
#' - constrained optimx optimization, including Nelder-Mead, hjkb, L-BFGS-B.
#'
#' This module defines FUNCTIONS ONLY. It does not install packages, change
#' working directories, rewrite DSSAT genotype files, or execute a simulator
#' when sourced. Users supply a safe model adapter that runs in an isolated,
#' licensed experiment workspace. See R/README.md.
#'
#' Dependencies: source("R/maize_calibration_utils.R") before calling.
#' optimx is required only when actually running calibration.

#' Validate initial cultivar/ecotype parameters and calibration bounds.
#'
#' @param parameters Data frame from Corn_calibration.csv.
#' @return List of named numeric initial, lower and upper parameter vectors.
maize_calibration_bounds <- function(parameters) {
  needed <- c("Par_orig", "initial_values",
              "Calib_range_min", "Calib_range_max")
  if (!is.data.frame(parameters) || !all(needed %in% names(parameters))) {
    stop("parameters requires: ", paste(needed, collapse = ", "))
  }
  if (nrow(parameters) != 15L) {
    stop("The historical maize calibration expects 15 cultivar/ecotype parameters")
  }
  names <- as.character(parameters$Par_orig)
  if (anyNA(names) || any(!nzchar(names)) || anyDuplicated(names)) {
    stop("Parameter names must be present and unique")
  }
  initial <- as.numeric(parameters$initial_values)
  lower <- as.numeric(parameters$Calib_range_min)
  upper <- as.numeric(parameters$Calib_range_max)
  if (any(!is.finite(c(initial, lower, upper))) ||
      any(lower >= upper) || any(initial < lower | initial > upper)) {
    stop("Parameter bounds/initial values must be finite and consistent")
  }
  names(initial) <- names(lower) <- names(upper) <- names
  list(initial = initial, lower = lower, upper = upper)
}

#' Return the original weighted objective for a parameter vector.
#'
#' @param parameter_values Named numeric parameters, ordered as in CSV.
#' @param observations Field observation data frame.
#' @param cultivar Cultivar identifier, e.g. "SC10" or "TC310".
#' @param simulate Function(parameter_values, cultivar, treatment_ids)
#'   -> list of PlantGro tables in the supplied treatment_ids order.
#' @return Numeric objective value minimized by optimx.
maize_calibration_loss <- function(
    parameter_values, observations, cultivar, simulate) {
  if (!is.function(simulate)) stop("simulate must be a function")
  targets <- maize_observed_targets(observations, cultivar)
  plantgro <- simulate(
    parameter_values = parameter_values,
    cultivar = cultivar,
    treatment_ids = targets$treatment_ids
  )
  predicted <- maize_simulated_targets(
    plantgro, dry_matter_days = targets$dry_matter_days
  )
  maize_calibration_objective(targets, predicted)$objective
}

#' Optimize a single maize cultivar, without changing model files directly.
#'
#' Original script: optimx with Nelder-Mead, hjkb and L-BFGS-B and a
#' 100,000 evaluation / iteration limit; that may be expensive when coupled
#' to a process-based simulator. No installation or execution happens until
#' this function is explicitly called with a valid simulator callback.
#'
#' @param methods Optimizers passed to optimx.
#' @param max_iterations Upper bound used for optimizer iteration settings.
#' @return List with cultivar, baseline score, parameter fit, optimizer
#'   diagnostics, final objective and per-response RMSE values.
calibrate_maize_cultivar <- function(
    cultivar, observations, parameters, simulate,
    methods = c("Nelder-Mead", "hjkb", "L-BFGS-B"),
    max_iterations = 100000L) {
  if (!requireNamespace("optimx", quietly = TRUE)) {
    stop("Install CRAN package 'optimx' before running calibration")
  }
  if (!is.function(simulate)) stop("simulate must be a function")
  if (length(max_iterations) != 1L || !is.finite(max_iterations) ||
      max_iterations < 1L) {
    stop("max_iterations must be positive")
  }

  bounds <- maize_calibration_bounds(parameters)
  targets <- maize_observed_targets(observations, cultivar)

  objective <- function(p) {
    maize_calibration_loss(
      parameter_values = stats::setNames(as.numeric(p),
                                          names(bounds$initial)),
      observations = observations,
      cultivar = cultivar,
      simulate = simulate
    )
  }

  baseline <- objective(bounds$initial)

  results <- optimx::optimx(
    par = bounds$initial,
    fn = objective,
    lower = bounds$lower,
    upper = bounds$upper,
    method = methods,
    itnmax = as.integer(max_iterations),
    control = list(
      maxit = as.integer(max_iterations),
      all.methods = FALSE,
      follow.on = TRUE
    )
  )

  if (!is.data.frame(results) || !"value" %in% names(results)) {
    stop("Optimizer did not return a usable results table")
  }
  finite <- which(is.finite(results$value))
  if (!length(finite)) stop("All optimizers returned non-finite objectives")
  best_row <- finite[which.min(results$value[finite])]

  # optimx reports parameter columns before the value/status columns.
  # Match by explicit parameter names when possible, otherwise positional
  # extraction mirrors the original research script.
  parameter_names <- names(bounds$initial)
  if (all(parameter_names %in% names(results))) {
    best <- as.numeric(results[best_row, parameter_names, drop = TRUE])
  } else {
    best <- as.numeric(results[best_row, seq_along(parameter_names),
                               drop = TRUE])
  }
  if (length(best) != length(bounds$initial) ||
      any(!is.finite(best))) {
    stop("Could not extract a finite optimized parameter vector")
  }
  names(best) <- parameter_names

  final_runs <- simulate(
    parameter_values = best,
    cultivar = cultivar,
    treatment_ids = targets$treatment_ids
  )
  final_predicted <- maize_simulated_targets(
    final_runs, dry_matter_days = targets$dry_matter_days
  )
  final_score <- maize_calibration_objective(targets, final_predicted)

  list(
    cultivar = as.character(cultivar),
    baseline_objective = baseline,
    optimized_parameters = best,
    optimizer_results = results,
    final_objective = final_score$objective,
    dry_matter_rmse = final_score$dry_matter_rmse,
    grain_rmse = final_score$grain_rmse,
    treatment_ids = targets$treatment_ids,
    simulated = final_predicted
  )
}

#' Calibrate SC10 and TC310 independently using the same observed dataset.
#'
#' Important correction relative to the 2019 script: TC310's final
#' evaluation must use the TC310 optimized parameter vector, not the
#' SC10 vector (a copy/paste error in the historical code).
calibrate_both_maize_cultivars <- function(
    observations, parameters, simulate,
    cultivars = c("SC10", "TC310"), ...) {
  if (anyDuplicated(cultivars) || !length(cultivars)) {
    stop("Provide distinct cultivar identifiers")
  }
  fits <- lapply(cultivars, function(cultivar) {
    calibrate_maize_cultivar(
      cultivar = cultivar,
      observations = observations,
      parameters = parameters,
      simulate = simulate,
      ...
    )
  })
  names(fits) <- cultivars
  fits
}
