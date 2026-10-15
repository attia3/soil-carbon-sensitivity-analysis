#' Co-inertia sensitivity analysis for process-based model simulations
#'
#' Refactors the statistical stages of the uploaded Co_inertia1.R source:
#' improved LHS -> paired model inputs and 14 outputs -> PCA -> co-inertia.
#' No global paths, automatic model execution, or changes to genotype/soil
#' files. Model-specific simulation must be provided explicitly by the caller.
#'
#' Requires R/parameter_sampling.R, R/sensitivity_helpers.R, and
#' R/maize_study_parameters.R to be sourced first.

#' Generate the original 26-factor exploratory design from Co_inertia1.R.
#' @param n Number of design rows (original research variant: 1500).
#' @param seed Reproducible seed (the historical script did not record one).
#' @return Data frame with run_id and one column per sampled factor.
design_maize_co_inertia <- function(n = 1500L, seed = 2026L) {
  stopifnot(is.function(make_lhs_design),
            is.function(maize_co_inertia_factors))
  factors <- maize_co_inertia_factors()
  design <- make_lhs_design(
    factors[, c("parameter", "lower", "upper")],
    n_samples = n, seed = seed, dup = 5L
  )
  data.frame(run_id = seq_len(nrow(design)), design, check.names = FALSE)
}

#' Evaluate a supplied safe simulator on a parameter design.
#'
#' The simulator must take a *single-row* data frame of named model inputs
#' and return a named numeric vector containing all expected responses.
#' It is NOT implemented by the historical model-specific file-writing
#' script. Implement a separate adapter that uses a disposable workspace.
#'
#' @param design Data frame including a unique run_id.
#' @param simulator Function(one_row_parameters) -> named numeric outputs.
#' @param expected Named output fields from the original co-inertia source.
#' @return Data frame of simulation IDs and response values.
evaluate_maize_design <- function(
    design, simulator, expected = maize_co_inertia_responses()) {
  if (!is.function(simulator)) stop("simulator must be a function")
  if (!is.data.frame(design) || !"run_id" %in% names(design))
    stop("design must be a data frame with run_id")
  if (nrow(design) < 3L || anyNA(design$run_id) ||
      anyDuplicated(design$run_id))
    stop("run_id must be unique; at least 3 runs are required")
  if (any(!vapply(design[setdiff(names(design), "run_id")],
                  is.numeric, logical(1))))
    stop("design parameter columns must be numeric")
  if (!is.character(expected) || !length(expected) ||
      anyDuplicated(expected))
    stop("expected must contain unique response names")

  output <- lapply(seq_len(nrow(design)), function(i) {
    parameters <- design[i, setdiff(names(design), "run_id"),
                         drop = FALSE]
    ans <- simulator(parameters)
    if (!is.numeric(ans) || is.null(names(ans)) ||
        !all(expected %in% names(ans)) ||
        any(!is.finite(ans[expected]))) {
      stop("Invalid response for run_id ", design$run_id[i],
           ": simulator must return all expected finite numeric outputs")
    }
    as.numeric(ans[expected])
  })
  result <- as.data.frame(do.call(rbind, output))
  names(result) <- expected
  data.frame(run_id = design$run_id, result, check.names = FALSE)
}

#' Analyze paired input–output tables by PCA and co-inertia.
#'
#' Both tables need unique run_id fields. Strict alignment by run_id avoids
#' accidentally comparing differently ordered or partly failed simulations.
#' Constant columns, non-finite results, or missing runs cause explicit errors.
#'
#' @return List with the co-inertia object, RV coefficient, run count,
#'         input/output variable names, and aligned run IDs.
analyze_maize_co_inertia <- function(
    design, responses, axes = 3L,
    required_outputs = maize_co_inertia_responses()) {
  if (!is.data.frame(design) || !is.data.frame(responses) ||
      !"run_id" %in% names(design) || !"run_id" %in% names(responses))
    stop("design and responses must be data frames with run_id")
  if (anyNA(design$run_id) || anyNA(responses$run_id) ||
      anyDuplicated(design$run_id) || anyDuplicated(responses$run_id))
    stop("run_id values must be complete and unique in both tables")
  if (nrow(design) != nrow(responses) ||
      !setequal(design$run_id, responses$run_id))
    stop("Design and response run_id sets must match exactly")
  if (!all(required_outputs %in% names(responses)))
    stop("Missing required model outputs: ",
         paste(setdiff(required_outputs, names(responses)), collapse = ", "))

  index <- match(design$run_id, responses$run_id)
  inputs <- design[setdiff(names(design), "run_id")]
  outputs <- responses[index, required_outputs, drop = FALSE]
  stopifnot(is.function(run_co_inertia))
  fit <- run_co_inertia(inputs, outputs, axes = axes)
  list(
    fit = fit,
    rv = as.numeric(fit$RV),
    n = nrow(design),
    input_variables = names(inputs),
    output_variables = names(outputs),
    run_id = design$run_id
  )
}

#' Plot input and response co-inertia scores on the selected axes.
#' Uses the same ade4 visualization family as the original study.
plot_maize_co_inertia <- function(result, axes = c(1L, 2L)) {
  if (!requireNamespace("ade4", quietly = TRUE)) stop("Install 'ade4'")
  if (length(axes) != 2L || any(axes < 1L))
    stop("axes must be two positive axis indices")
  fit <- result$fit
  if (max(axes) > ncol(fit$c1) || max(axes) > ncol(fit$l1))
    stop("Requested axes unavailable")
  previous <- graphics::par(mfrow = c(1, 2))
  on.exit(graphics::par(previous), add = TRUE)
  ade4::s.arrow(fit$c1, xax = axes[1], yax = axes[2], clabel = 0.7,
                main = "Model input variables")
  ade4::s.arrow(fit$l1, xax = axes[1], yax = axes[2], clabel = 0.7,
                main = "Model response variables")
  invisible(result)
}
