# Synthetic demonstration of the co-inertia and Sobol workflows.
# This uses mock responses, NOT the observations or model results of
# Attia et al. (2021). Run from the repository root:
#   Rscript examples/maize_sensitivity_demo.R
#
# Required: install.packages(c("lhs", "ade4", "sensitivity"))

source("R/parameter_sampling.R")
source("R/sensitivity_helpers.R")
source("R/maize_study_parameters.R")
source("R/co_inertia_analysis.R")
source("R/sobol_soc_analysis.R")

# 1. Original source-derived co-inertia ranges; synthetic model responses.
design <- design_maize_co_inertia(n = 80L, seed = 42L)
mock_model <- function(x) {
  values <- unlist(x[1, , drop = FALSE], use.names = FALSE)
  names(values) <- names(x)
  # Make 14 finite, varying outputs to illustrate paired analysis.
  out <- vapply(seq_along(maize_co_inertia_responses()), function(k) {
    values[k] + 0.2 * values[k + 12L]
  }, numeric(1))
  stats::setNames(out, maize_co_inertia_responses())
}
responses <- evaluate_maize_design(design, mock_model)
fit <- analyze_maize_co_inertia(design, responses)
cat("Synthetic co-inertia RV coefficient:", fit$rv, "\n")

# 2. Original four-factor Sobol ranges; independent Saltelli A/B matrices.
#    This is a deliberate correction to the historical row-permuted X2.
sobol_design <- make_soc_sobol_design(n = 120L, seed = 42L)
mock_carbon_response <- function(x) {
  # Deliberate nonlinear response with a v2 x v4 interaction.
  4 * x$v1 + 1.5 * x$v2 + 0.001 * x$v3 +
    0.0004 * x$v2 * x$v4
}
s <- analyze_soc_sobol(
  model_function = mock_carbon_response,
  response = "synthetic_soc_response",
  design = sobol_design,
  nboot = 20L
)
cat("Synthetic SOC-response sensitivity estimates:\n")
print(s$indices$S)
print(s$indices$T)
cat("All outputs are synthetic; no claim is made to reproduce the paper.\n")
