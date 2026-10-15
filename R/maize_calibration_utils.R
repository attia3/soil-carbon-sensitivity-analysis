#' Shared data validation and model-evaluation utilities for maize calibration
#'
#' These functions preserve the historical objective structure of
#' dssat_cornCV_calib.R: RMSE(dry matter) / 100 + RMSE(grain yield) / 50.
#' No model is executed and no files are modified when this module is sourced.
#'
#' Study: Attia et al. (2021), Field Crops Research 260, 107981.
#' DSSAT output field names correspond to the historical PlantGro.OUT files.

#' Read the small research datasets supplied in the repository root.
#' @param project_dir Directory containing calibration and observation CSVs.
#' @return Named list with parameter and observation data frames.
read_maize_calibration_data <- function(project_dir = ".") {
  if (!dir.exists(project_dir)) stop("project_dir does not exist")
  obs_path <- file.path(project_dir, "OBS_Calib-Data_.csv")
  par_path <- file.path(project_dir, "Corn_calibration.csv")
  if (!file.exists(obs_path) || !file.exists(par_path)) {
    stop("Required CSVs not found in project_dir: ", normalizePath(project_dir))
  }

  observations <- utils::read.csv(obs_path, stringsAsFactors = FALSE)
  parameters <- utils::read.csv(par_path, stringsAsFactors = FALSE)

  obs_fields <- c("Trt", "CV", "Yr", "Irri", "Nit", "Vari", "DAP", "Value")
  par_fields <- c("Par_orig", "initial_values", "Calib_range_min",
                  "Calib_range_max")
  if (!all(obs_fields %in% names(observations))) {
    stop("Observations are missing: ",
         paste(setdiff(obs_fields, names(observations)), collapse = ", "))
  }
  if (!all(par_fields %in% names(parameters))) {
    stop("Parameter table is missing: ",
         paste(setdiff(par_fields, names(parameters)), collapse = ", "))
  }
  list(observations = observations, parameters = parameters)
}

#' Prepare independent cultivar observations, with deterministic alignment.
#'
#' The historical objective uses nitrogen level 190, grain yield at
#' DAP 110, and total dry matter at DAP 60 and 75. Measurements are ordered
#' by treatment within day, matching the simulated vector construction.
#'
#' @param observations Source CSV data frame.
#' @param cultivar Either SC10 or TC310 (or a compatible cultivar label).
#' @param nitrogen Nitrogen treatment identifier; original: 190.
#' @param dry_matter_days Measurement days; original: c(60, 75).
#' @param grain_day Grain measurement day; original: 110.
#' @return List of treatment_ids, observed_dry_matter and observed_grain.
maize_observed_targets <- function(
    observations, cultivar, nitrogen = 190,
    dry_matter_days = c(60L, 75L), grain_day = 110L) {
  required <- c("Trt", "CV", "Nit", "Vari", "DAP", "Value")
  if (!is.data.frame(observations) ||
      !all(required %in% names(observations))) {
    stop("observations must contain: ", paste(required, collapse = ", "))
  }
  data <- observations[
    as.character(observations$CV) == as.character(cultivar) &
      as.character(observations$Nit) == as.character(nitrogen), ,
    drop = FALSE
  ]
  if (!nrow(data)) stop("No observations for cultivar ", cultivar)
  data$Trt <- suppressWarnings(as.integer(as.character(data$Trt)))
  data$DAP <- suppressWarnings(as.integer(as.character(data$DAP)))
  data$Value <- suppressWarnings(as.numeric(as.character(data$Value)))
  if (anyNA(data[, c("Trt", "DAP", "Value")]) ||
      any(!is.finite(data$Value))) {
    stop("Observation identifiers, days and measurements must be valid")
  }
  if (anyDuplicated(dry_matter_days)) stop("dry_matter_days must be unique")

  treatment_ids <- sort(unique(data$Trt))
  get_value <- function(treatment, variable, day) {
    selection <- data$Trt == treatment & data$Vari == variable &
      data$DAP == day
    if (sum(selection) != 1L) {
      stop("Expected one ", variable, " measurement for treatment ",
           treatment, " on DAP ", day, "; found ", sum(selection))
    }
    data$Value[selection]
  }
  obs_dm <- unlist(lapply(dry_matter_days, function(day) {
    vapply(treatment_ids, get_value, numeric(1),
           variable = "totaldryweight", day = day)
  }), use.names = FALSE)
  obs_grain <- vapply(treatment_ids, get_value, numeric(1),
                      variable = "GrainYield", day = grain_day)
  list(
    cultivar = as.character(cultivar),
    nitrogen = nitrogen,
    treatment_ids = treatment_ids,
    dry_matter_days = as.integer(dry_matter_days),
    grain_day = as.integer(grain_day),
    observed_dry_matter = obs_dm,
    observed_grain = as.numeric(obs_grain)
  )
}

#' Extract modeled grain yield and biomass at the original observation days.
#'
#' @param plantgro List of PlantGro.OUT tables, explicitly ordered to match
#'   the treatment_ids returned by maize_observed_targets().
#' @param dry_matter_days Days for matched total dry matter observations.
#' @return List with simulated_dry_matter, simulated_grain, and treatment count.
maize_simulated_targets <- function(
    plantgro, dry_matter_days = c(60L, 75L)) {
  if (!is.list(plantgro) || !length(plantgro)) {
    stop("plantgro must be a nonempty list of treatment tables")
  }
  tables <- lapply(seq_along(plantgro), function(i) {
    x <- as.data.frame(plantgro[[i]])
    if (!all(c("DAP", "CWAD", "GWAD") %in% names(x))) {
      stop("PlantGro table ", i, " lacks DAP, CWAD or GWAD")
    }
    x
  })
  dm <- unlist(lapply(dry_matter_days, function(day) {
    vapply(seq_along(tables), function(i) {
      x <- tables[[i]]
      match_rows <- which(x$DAP == day)
      if (length(match_rows) != 1L) {
        stop("PlantGro table ", i, " requires one record for DAP ", day)
      }
      as.numeric(x$CWAD[match_rows])
    }, numeric(1))
  }), use.names = FALSE)
  gy <- vapply(seq_along(tables), function(i) {
    x <- tables[[i]]
    if (!nrow(x)) stop("Empty PlantGro table ", i)
    as.numeric(tail(x$GWAD, 1L))
  }, numeric(1))
  if (any(!is.finite(c(dm, gy)))) {
    stop("Simulated grain and biomass outputs must be finite")
  }
  list(simulated_dry_matter = dm, simulated_grain = gy,
       treatment_count = length(tables))
}

#' Calculate the original 2019 maize calibration objective.
#'
#' Objective = RMSE(total dry matter, kg/ha)/100 +
#'             RMSE(grain yield, kg/ha)/50.
#' The denominators are historical optimization weights, not uncertainties.
#' Both measured and modeled vectors must have the same treatment ordering.
maize_calibration_objective <- function(observed, simulated) {
  needed_obs <- c("observed_dry_matter", "observed_grain", "treatment_ids")
  needed_sim <- c("simulated_dry_matter", "simulated_grain", "treatment_count")
  if (!all(needed_obs %in% names(observed)) ||
      !all(needed_sim %in% names(simulated))) {
    stop("Pass output lists from maize_observed_targets and maize_simulated_targets")
  }
  if (length(observed$treatment_ids) != simulated$treatment_count ||
      length(observed$observed_dry_matter) !=
        length(simulated$simulated_dry_matter) ||
      length(observed$observed_grain) !=
        length(simulated$simulated_grain)) {
    stop("Observed and simulated treatments are not aligned")
  }
  rmse <- function(o, s) sqrt(mean((o - s)^2))
  dm_rmse <- rmse(observed$observed_dry_matter,
                  simulated$simulated_dry_matter)
  gy_rmse <- rmse(observed$observed_grain, simulated$simulated_grain)
  if (any(!is.finite(c(dm_rmse, gy_rmse)))) {
    stop("Non-finite calibration objective")
  }
  list(
    objective = dm_rmse / 100 + gy_rmse / 50,
    dry_matter_rmse = dm_rmse,
    grain_rmse = gy_rmse
  )
}

#' Calculate straightforward model evaluation statistics.
#'
#' R2 is the squared Pearson correlation when both vectors vary;
#' NSE is Nash-Sutcliffe efficiency, relative RMSE = RMSE / mean(obs) * 100.
maize_model_metrics <- function(observed, simulated) {
  o <- as.numeric(observed)
  s <- as.numeric(simulated)
  if (!length(o) || length(o) != length(s) ||
      any(!is.finite(c(o, s)))) {
    stop("observed and simulated must be finite equal-length vectors")
  }
  rmse <- sqrt(mean((o - s)^2))
  denominator <- sum((o - mean(o))^2)
  list(
    n = length(o),
    bias = mean(s - o),
    rmse = rmse,
    rrmse_pct = if (mean(o) != 0) 100 * rmse / mean(o) else NA_real_,
    r_squared = if (length(o) > 1L && stats::sd(o) > 0 &&
                     stats::sd(s) > 0) stats::cor(o, s)^2 else NA_real_,
    nse = if (denominator > 0) 1 - sum((o - s)^2) / denominator
          else NA_real_
  )
}
