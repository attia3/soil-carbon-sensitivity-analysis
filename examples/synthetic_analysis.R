# Synthetic illustration of co-inertia; not the Attia et al. field dataset.
# Run from repository root: Rscript examples/synthetic_analysis.R
source("R/sensitivity_helpers.R")
set.seed(2026)
n <- 100L
inputs <- data.frame(
  clay = runif(n, 5, 45),
  water_capacity = runif(n, 0.10, 0.35),
  initial_soc = runif(n, 0.3, 1.2)
)
outputs <- data.frame(
  carbon_response = 2 * inputs$initial_soc + 0.03 * inputs$clay + rnorm(n, sd = 0.1),
  water_response = 12 * inputs$water_capacity + 0.01 * inputs$clay + rnorm(n, sd = 0.1)
)
analysis <- run_co_inertia(inputs, outputs)
print(analysis$RV)
