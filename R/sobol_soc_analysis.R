#' Sobol sensitivity of soil carbon and management responses
#'
#' Scientific basis: Attia et al. (2021), Field Crops Research 260:107981.
#' This is a safe refactoring of the experimental factors and sensitivity
#' stage of uploaded Sobol_3_18/Sobol.R, not its file-writing DSSAT loop.
#'
#' Requires R/sensitivity_helpers.R and R/maize_study_parameters.R.

#' Independently sample two uniform parameter matrices for Saltelli designs.
#'
#' IMPORTANT: The archived Sobol.R script permuted rows of one design to
#' construct X2. Here X1 and X2 are sampled independently. That is a
#' deliberate statistical improvement, *not* a byte-for-byte replication
#' of the published numerical indices. Parameter ranges are unchanged.
#'
#' @param factors Parameter range data frame (parameter, lower, upper).
#' @param n Number of base parameter draws per matrix.
#' @param seed Random seed for independent A/B draws.
#' @return List with data frames A and B and factor metadata.
make_soc_sobol_design <- function(
    factors = maize_soc_sobol_factors(),
    n = 200L, seed = 2026L) {
  required <- c("parameter", "lower", "upper")
  if (!is.data.frame(factors) ||
      !all(required %in% names(factors)) ||
      !is.numeric(factors$lower) || !is.numeric(factors$upper) ||
      anyNA(factors[, required]) ||
      any(!is.finite(factors$lower)) ||
      any(!is.finite(factors$upper)) ||
      any(factors$upper <= factors$lower) ||
      anyDuplicated(factors$parameter))
    stop("Supply unique factors with finite lower < upper")
  if (length(n) != 1L || !is.finite(n) || n < 3 ||
      n != as.integer(n))
    stop("n must be an integer >= 3")
  if (length(seed) != 1L || !is.finite(seed))
    stop("seed must be one finite number")
  # Deterministic design. The seed will change the current R RNG state.
  set.seed(as.integer(seed))
  sample_matrix <- function() {
    u <- matrix(stats::runif(n * nrow(factors)), nrow = n,
                ncol = nrow(factors))
    values <- sweep(u, 2L, factors$upper - factors$lower, "*")
    values <- sweep(values, 2L, factors$lower, "+")
    x <- as.data.frame(values)
    names(x) <- factors$parameter
    x
  }
  list(A = sample_matrix(), B = sample_matrix(), factors = factors)
}

#' Run Sobol/Saltelli analysis for one modeled response.
#'
#' model_function must accept a *data frame of rows* and return a finite
#' numeric vector of the same length (vectorized/batched simulation).
#' The model function is responsible for safe execution; no DSSAT files
#' are accessed by this statistical routine.
#'
#' @param model_function Function(data_frame) -> numeric response vector.
#' @param response Name of target response for result annotation.
#' @param design Result from make_soc_sobol_design().
#' @param nboot Number of bootstrap replicates for uncertainty estimates.
#' @return List(response, indices): sensitivity::sobolSalt result.
analyze_soc_sobol <- function(
    model_function,
    response = "mean_SCS20D_all",
    design = make_soc_sobol_design(),
    nboot = 100L) {
  if (!is.function(model_function)) stop("model_function must be a function")
  if (!is.list(design) || is.null(design$A) || is.null(design$B))
    stop("design must contain parameter matrices A and B")
  if (!is.character(response) || length(response) != 1L ||
      !nzchar(response))
    stop("response must be one nonempty name")
  if (length(nboot) != 1L || !is.finite(nboot) ||
      nboot < 0 || nboot != as.integer(nboot))
    stop("nboot must be a nonnegative integer")

  wrapped <- function(x) {
    y <- model_function(as.data.frame(x))
    if (!is.numeric(y) || length(y) != nrow(x) ||
        any(!is.finite(y)))
      stop("Model must return one finite numeric value per design row")
    as.numeric(y)
  }
  if (!is.function(run_sobol_salt))
    stop("Source R/sensitivity_helpers.R before using analyze_soc_sobol")
  result <- run_sobol_salt(
    model_function = wrapped,
    x1 = design$A, x2 = design$B, nboot = nboot
  )
  list(response = response, factors = names(design$A), indices = result)
}

#' Analyze several outputs without hiding repeated model evaluations.
#'
#' simulator() returns a data frame with one row per input and one column
#' per response. This function wraps each response individually, so
#' simulations may be repeated. Cache stable model outputs in the simulator
#' when execution cost is high.
analyze_soc_sobol_outputs <- function(
    simulator,
    outputs = maize_soc_sobol_responses(),
    design = make_soc_sobol_design(),
    nboot = 100L) {
  if (!is.function(simulator)) stop("simulator must be a function")
  if (!is.character(outputs) || !length(outputs) ||
      anyDuplicated(outputs))
    stop("outputs must be unique names")
  result <- setNames(vector("list", length(outputs)), outputs)
  for (target in outputs) {
    response_function <- function(x) {
      result_table <- simulator(x)
      if (!is.data.frame(result_table) ||
          nrow(result_table) != nrow(x) ||
          !target %in% names(result_table))
        stop("Simulator must return a data frame with output ", target)
      as.numeric(result_table[[target]])
    }
    result[[target]] <- analyze_soc_sobol(
      response_function, response = target,
      design = design, nboot = nboot
    )
  }
  result
}
