# Model-agnostic Latin hypercube parameter sampling using original study's
# improvedLHS method. Factor bounds must be provided and are not inferred
# from the Field Crops Research publication without a figure/code crosswalk.

make_lhs_design <- function(bounds, n_samples = 500L, seed = 2026L, dup = 5L) {
  if (!requireNamespace("lhs", quietly = TRUE)) stop("Install 'lhs'")
  required <- c("parameter", "lower", "upper")
  if (!all(required %in% names(bounds)))
    stop("bounds requires: parameter, lower, upper")
  if (!is.numeric(bounds$lower) || !is.numeric(bounds$upper) ||
      anyNA(bounds[, required]) || any(!is.finite(bounds$lower)) ||
      any(!is.finite(bounds$upper)) || any(bounds$lower >= bounds$upper)) {
    stop("Each factor needs finite lower < upper")
  }
  if (anyDuplicated(bounds$parameter)) stop("Parameter names must be unique")
  if (n_samples < 2L) stop("Use at least two samples")
  if (!is.null(seed)) set.seed(as.integer(seed))
  u <- lhs::improvedLHS(as.integer(n_samples), nrow(bounds), dup = as.integer(dup))
  values <- sweep(u, 2L, bounds$upper - bounds$lower, "*")
  values <- sweep(values, 2L, bounds$lower, "+")
  result <- as.data.frame(values)
  names(result) <- as.character(bounds$parameter)
  result
}
