# Regression and input-validation checks for the self-contained R functions.
# From repository root:
#   Rscript tests/test_sensitivity_pipeline.R
#
# Statistical package-dependent checks run when the packages are installed;
# all scientific inputs below are SYNTHETIC, not publication datasets.

source("R/parameter_sampling.R")
source("R/sensitivity_helpers.R")
source("R/maize_study_parameters.R")
source("R/co_inertia_analysis.R")
source("R/sobol_soc_analysis.R")
source("R/soc_response_metrics.R")

co <- maize_co_inertia_factors()
sob <- maize_soc_sobol_factors()
stopifnot(
  nrow(co) == 26L, nrow(sob) == 4L,
  length(maize_co_inertia_responses()) == 14L,
  length(maize_soc_sobol_responses()) == 5L,
  all(co$lower < co$upper),
  all(sob$lower < sob$upper),
  !anyDuplicated(co$parameter),
  !anyDuplicated(sob$parameter)
)

# Create three annual snapshots with known carbon-pool relationships.
carbon <- data.frame(
  YEAR = 2020:2022, DOY = rep(230L, 3),
  SOCD = c(25, 26, 27), "SC%20D" = c(0.4, 0.5, 0.6),
  S1CTD = c(10, 11, 12), S1C0D = c(1, 1, 1),
  S2CTD = c(5, 5, 5), LC0D = c(2, 2, 2),
  LCTD = c(3, 3, 3), S3CTD = c(4, 4, 4),
  check.names = FALSE
)
nitrogen <- data.frame(
  YEAR = 2020:2022, DOY = rep(230L, 3),
  NLCC = c(1, 2, 3), NMNC = c(10, 12, 14),
  NNMNC = c(7, 9, 11)
)
annual <- summarize_annual_soc_pools(carbon, nitrogen)
stopifnot(
  nrow(annual) == 3L,
  identical(as.numeric(annual$model_soc_pool_1), c(11, 12, 13)),
  all(annual$model_soc_pool_2 == 10),
  identical(as.numeric(annual$soc_percent_top20), c(0.4, 0.5, 0.6))
)
sums <- summarize_soc_period(annual, years = 2020:2022)
stopifnot(abs(sums$total_soc_model_units - 26) < 1e-12)
err <- try(summarize_annual_soc_pools(rbind(carbon, carbon[1, ]),
                                      nitrogen), silent = TRUE)
stopifnot(inherits(err, "try-error"))

# Parameter design and full co-inertia check (requires optional packages).
if (requireNamespace("lhs", quietly = TRUE)) {
  d <- design_maize_co_inertia(n = 30L, seed = 123L)
  stopifnot(nrow(d) == 30L, ncol(d) == 27L,
            all(d$P1 >= 167 & d$P1 <= 311),
            all(d$SAOC.90 >= 0.07 & d$SAOC.90 <= 0.3))

  if (requireNamespace("ade4", quietly = TRUE)) {
    simulator <- function(row) {
      x <- unlist(row[1, , drop = FALSE], use.names = FALSE)
      response <- vapply(seq_len(14), function(k) {
        x[k] * 0.8 + x[k + 12L] * 0.2
      }, numeric(1))
      stats::setNames(response, maize_co_inertia_responses())
    }
    y <- evaluate_maize_design(d, simulator)
    result <- analyze_maize_co_inertia(d, y)
    stopifnot(result$n == 30L, is.finite(result$rv))
    bad <- y[-1, ]
    stopifnot(inherits(try(analyze_maize_co_inertia(d, bad),
                           silent = TRUE), "try-error"))
  }
}

# Sobol design pair draws are independently generated.
a <- make_soc_sobol_design(n = 50L, seed = 321L)
stopifnot(
  identical(names(a$A), c("v1", "v2", "v3", "v4")),
  identical(names(a$B), names(a$A)),
  nrow(a$A) == 50L, nrow(a$B) == 50L,
  !identical(a$A, a$B),
  all(a$A$v4 >= 0 & a$A$v4 <= 10000)
)

cat("All available sensitivity checks passed.\n")
