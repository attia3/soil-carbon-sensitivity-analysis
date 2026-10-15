# Generic statistical helpers adapted from the method classes documented in
# Attia et al. (2021), Field Crops Research 260, 107981.
# These operate on prepared tables or model functions. They do NOT reproduce
# the published figures without the original simulation inputs and results.

check_numeric_table <- function(x, label = "table") {
  x <- as.data.frame(x)
  if (nrow(x) < 3L || ncol(x) < 1L) stop(label, ": expected >=3 rows and >=1 column")
  if (!all(vapply(x, is.numeric, logical(1)))) stop(label, ": all columns must be numeric")
  if (any(!is.finite(as.matrix(x)))) stop(label, ": data must be complete and finite")
  x
}

run_co_inertia <- function(inputs, outputs, axes = 3L) {
  if (!requireNamespace("ade4", quietly = TRUE)) stop("Install 'ade4'")
  inputs <- check_numeric_table(inputs, "inputs")
  outputs <- check_numeric_table(outputs, "outputs")
  if (nrow(inputs) != nrow(outputs))
    stop("Input and output rows must be aligned observations/simulation runs")
  if (any(vapply(inputs, sd, numeric(1)) == 0) ||
      any(vapply(outputs, sd, numeric(1)) == 0))
    stop("Remove constant columns before co-inertia analysis")
  axes <- as.integer(axes)
  if (axes < 1L) stop("axes must be positive")
  nf <- min(axes, ncol(inputs), ncol(outputs), nrow(inputs) - 1L)
  dinput <- ade4::dudi.pca(inputs, scale = TRUE, scannf = FALSE, nf = nf)
  doutput <- ade4::dudi.pca(outputs, scale = TRUE, scannf = FALSE, nf = nf)
  ade4::coinertia(dinput, doutput, scannf = FALSE, nf = nf)
}

# Reflects the original Sobol scripts' use of sensitivity::sobolSalt.
# Provide independently selected factor designs X1 / X2; this does not
# encode the publication's original factor ranges or simulation workflow.
run_sobol_salt <- function(model_function, x1, x2, nboot = 100L) {
  if (!requireNamespace("sensitivity", quietly = TRUE))
    stop("Install 'sensitivity'")
  x1 <- check_numeric_table(x1, "x1")
  x2 <- check_numeric_table(x2, "x2")
  if (!identical(dim(x1), dim(x2)) || !identical(names(x1), names(x2)))
    stop("x1 and x2 must have matching dimensions and column names")
  if (!is.function(model_function)) stop("model_function must be a function")
  sensitivity::sobolSalt(
    model = model_function, X1 = x1, X2 = x2,
    scheme = "A", nboot = as.integer(nboot)
  )
}
