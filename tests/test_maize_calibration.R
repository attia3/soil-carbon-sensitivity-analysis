# Regression checks for the refactored maize calibration and figure scripts.
# All simulations below are synthetic and exactly match the supplied
# observations by construction; no DSSAT installation is required.
#
# From repository root: Rscript tests/test_maize_calibration.R

source("R/maize_calibration_utils.R")
source("R/dssat_cornCV_calib.R")
source("R/mediaforarticle.R")

input <- read_maize_calibration_data(".")
observations <- input$observations
parameters <- input$parameters
bounds <- maize_calibration_bounds(parameters)

stopifnot(
  length(bounds$initial) == 15L,
  length(bounds$lower) == 15L,
  length(bounds$upper) == 15L,
  all(bounds$lower <= bounds$initial),
  all(bounds$initial <= bounds$upper)
)

make_synthetic_plantgro <- function(targets) {
  n <- length(targets$treatment_ids)
  runs <- lapply(seq_len(n), function(i) {
    # DAP 60/75 biomass and final modeled grain yield exactly reproduce
    # the target observations. These are NOT results of DSSAT simulations.
    data.frame(
      DAP = c(0, 60, 75, 110),
      CWAD = c(0, targets$observed_dry_matter[i],
               targets$observed_dry_matter[n + i],
               targets$observed_dry_matter[n + i]),
      GWAD = c(0, 0, 0, targets$observed_grain[i])
    )
  })
  names(runs) <- as.character(targets$treatment_ids)
  runs
}

simulate <- function(parameter_values, cultivar, treatment_ids) {
  target <- maize_observed_targets(observations, cultivar)
  runs <- make_synthetic_plantgro(target)
  unname(runs[as.character(treatment_ids)])
}

for (cultivar in c("SC10", "TC310")) {
  target <- maize_observed_targets(observations, cultivar)
  stopifnot(length(target$treatment_ids) == 10L)

  named <- make_synthetic_plantgro(target)
  predicted <- maize_simulated_targets(unname(named))
  evaluation <- maize_calibration_objective(target, predicted)
  stopifnot(
    abs(evaluation$objective) < 1e-12,
    abs(evaluation$dry_matter_rmse) < 1e-12,
    abs(evaluation$grain_rmse) < 1e-12
  )
  loss <- maize_calibration_loss(bounds$initial, observations, cultivar, simulate)
  stopifnot(abs(loss) < 1e-12)

  # Figures reproduce the same measured/modeled comparisons in a
  # four-panel layout without invoking the model or writing to input files.
  figure <- tempfile(fileext = ".pdf")
  result <- plot_maize_paper_figures(
    observations, named, cultivar = cultivar, file = figure
  )
  stopifnot(
    file.exists(figure),
    file.info(figure)$size > 1000,
    result$treatment_count == 10L,
    result$grain_yield$n == 10L,
    result$dry_matter$n == 20L
  )
  unlink(figure)
}

# Verify loud failure on ambiguous observation rows or misaligned runs.
target <- maize_observed_targets(observations, "SC10")
run <- make_synthetic_plantgro(target)
run_missing <- run[-1L]
stopifnot(inherits(
  try(maize_align_simulation_tables(run_missing, target$treatment_ids),
      silent = TRUE),
  "try-error"
))

double_observation <- rbind(observations, observations[1L, , drop = FALSE])
stopifnot(inherits(
  try(maize_observed_targets(double_observation, "SC10"),
      silent = TRUE),
  "try-error"
))

cat("Maize calibration, evaluation and synthetic figure tests passed.\n")
