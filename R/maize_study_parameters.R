#' Parameter ranges and response variables from historical maize sensitivity runs
#'
#' Study context: Attia et al. (2021), Field Crops Research 260:107981.
#' These are the settings extracted from two selected uploaded source variants:
#' Co_inertia1.R (26-factor, 1,500-run exploratory design) and Sobol.R
#' (four-factor, 200-sample design). Do not mistake them for an independently
#' verified, exact reconstruction of the article's final 25-factor experiment.
#'
#' Original source files: Co_interia_19_12_22/Latest_1_11_20/Co_inertia1.R
#' and Sobol_3_18/Sobol.R. The code below preserves their factor limits and
#' names; the model input-writing portions are intentionally not copied
#' because they modify installed DSSAT soil, genotype and experiment files.

#' Return the 26 input ranges in the selected co-inertia research variant.
#' Names are the exact model-input labels used in that R script.
#' @return Data frame: parameter, lower, upper.
maize_co_inertia_factors <- function() {
  parameter <- c(
    "P1", "P5", "G2", "G3", "PHINT",
    "GDDE", "DSGFT", "RUE", "KCAN",
    "SLU1", "SLDR", "SLPF",
    "SLLL.30", "SDUL.30", "SSAT.30", "SBDM.30",
    "SLLL.60", "SDUL.60", "SSAT.60", "SBDM.60",
    "SAOC.30", "SASC.30", "SAOC.60", "SASC.60",
    "SAOC.90", "SASC.90"
  )
  lower <- c(
    167, 620, 590, 4.5, 35,
    4.2, 120, 3.3, 0.68,
    3, 0.4, 0.7,
    0.01, 0.06, 0.3, 1.2,
    0.01, 0.06, 0.3, 1.2,
    0.2, 0.3, 0.15, 0.3,
    0.07, 0.3
  )
  upper <- c(
    311, 1100, 1100, 10.5, 65,
    7.8, 220, 5, 1.02,
    12, 0.95, 1,
    0.05, 0.22, 0.6, 1.8,
    0.05, 0.22, 0.6, 1.8,
    0.6, 0.8, 0.5, 0.8,
    0.3, 0.8
  )
  stopifnot(length(parameter) == 26L,
            length(lower) == length(parameter),
            length(upper) == length(parameter))
  data.frame(parameter = parameter, lower = lower, upper = upper,
             stringsAsFactors = FALSE)
}

#' Four experimental factors in the selected original Sobol.R source.
#'
#' v1 and v2 modify soil-carbon-related parameters in a DSSAT experiment;
#' v3 alters residue input and v4 compost input. Physical units and precise
#' interpretations must be checked against the original experiment template.
#' Do not substitute these code settings for registry-approved ranges.
maize_soc_sobol_factors <- function() {
  data.frame(
    parameter = c("v1", "v2", "v3", "v4"),
    lower = c(0.20, 0.20, 0, 0),
    upper = c(0.60, 0.70, 5000, 10000),
    model_setting = c(
      "soil_C_setting_1", "soil_C_setting_2",
      "residue_input", "compost_input"
    ),
    stringsAsFactors = FALSE
  )
}

#' The 14 simulated response columns assembled in Co_inertia1.R.
#' Labels are historical output symbols, not inferred new measurements.
maize_co_inertia_responses <- function() {
  c(
    "Emer", "Anth", "Mat", "GY", "Straw", "Nleach",
    "sN", "MLAI", "TsC", "Transp", "sEvap",
    "sWater", "Nup", "Drin"
  )
}

#' Five targets from the selected original Sobol.R sensitivity loop.
#' These are source variable names; output construction needs model files.
maize_soc_sobol_responses <- function() {
  c(
    "GY_vec", "mean_DMPEM_all", "mean_NMNC_all",
    "mean_SCS20D_all", "mean_CO2EC_all"
  )
}
