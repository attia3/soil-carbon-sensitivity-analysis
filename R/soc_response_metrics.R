#' Extract SOC pool and nitrogen response metrics from prepared model tables
#'
#' The original Sobol.R reads SOMLITC.OUT and SoilNi.OUT, taking selected
#' variables at day of year 230 for each simulation year. This refactoring
#' works on already-parsed data frames and makes annual records and units
#' explicit. It NEVER modifies model input or output files.
#'
#' Inputs must be pre-filtered to one site, treatment, scenario and run.
#' Column names correspond to the original DSSAT output vocabulary.
#' The soil carbon fractions here are *model pools*, not measured POM/MAOC.

require_fields <- function(data, fields, label) {
  if (!is.data.frame(data))
    stop(label, " must be a data frame")
  missing <- setdiff(fields, names(data))
  if (length(missing))
    stop(label, " missing fields: ", paste(missing, collapse = ", "))
  invisible(TRUE)
}

select_annual_snapshot <- function(data, variables, doy = 230L,
                                   label = "table") {
  require_fields(data, c("YEAR", "DOY", variables), label)
  if (length(doy) != 1L || !is.finite(doy) || doy < 1L || doy > 366L)
    stop("doy must be between 1 and 366")
  rows <- data[data$DOY == doy, c("YEAR", variables), drop = FALSE]
  if (nrow(rows) < 1L)
    stop(label, ": no records for day-of-year ", doy)
  if (anyNA(rows) || anyDuplicated(rows$YEAR))
    stop(label, ": expected exactly one finite yearly record at DOY ", doy)
  if (!all(vapply(rows[variables], is.numeric, logical(1))) ||
      any(!is.finite(as.matrix(rows[variables]))))
    stop(label, ": non-finite/non-numeric response detected")
  rows[order(rows$YEAR), , drop = FALSE]
}

#' Combine source-defined annual carbon and nitrogen pools.
#'
#' Uses source formulas:
#'   TSOC1 = S1C0D + S1CTD
#'   TSOC2 = S2CTD + LC0D + LCTD
#' Do not assume these modeled pools correspond directly to lab MAOC or POM.
#'
#' @param soil_c Data frame parsed from SOMLITC.OUT, single treatment.
#' @param soil_n Data frame parsed from SoilNi.OUT, single treatment.
#' @param doy Day-of-year snapshot for yearly averaging (source: 230).
#' @return One row per year with annual modeled pool/flux indices.
summarize_annual_soc_pools <- function(soil_c, soil_n, doy = 230L) {
  cvars <- c("SOCD", "SC%20D", "S1CTD", "S1C0D",
             "S2CTD", "LC0D", "LCTD", "S3CTD")
  nvars <- c("NLCC", "NMNC", "NNMNC")
  carbon <- select_annual_snapshot(soil_c, cvars, doy, "soil_c")
  nitrogen <- select_annual_snapshot(soil_n, nvars, doy, "soil_n")
  if (!setequal(carbon$YEAR, nitrogen$YEAR))
    stop("Carbon and nitrogen time series have different years")
  nitrogen <- nitrogen[match(carbon$YEAR, nitrogen$YEAR), , drop = FALSE]
  result <- data.frame(
    YEAR = carbon$YEAR,
    total_soc_model_units = carbon$SOCD,
    soc_percent_top20 = carbon[["SC%20D"]],
    model_soc_pool_1 = carbon$S1C0D + carbon$S1CTD,
    model_soc_pool_2 = carbon$S2CTD + carbon$LC0D + carbon$LCTD,
    model_soc_pool_3 = carbon$S3CTD,
    n_leaching_model_units = nitrogen$NLCC,
    n_mineralization_model_units = nitrogen$NMNC,
    net_n_mineralization_model_units = nitrogen$NNMNC
  )
  rownames(result) <- NULL
  result
}

#' Summarize annual modeled SOC response without suppressing missing years.
summarize_soc_period <- function(annual_table, years = NULL) {
  required <- c(
    "YEAR", "total_soc_model_units", "soc_percent_top20",
    "model_soc_pool_1", "model_soc_pool_2", "model_soc_pool_3",
    "n_leaching_model_units", "n_mineralization_model_units",
    "net_n_mineralization_model_units"
  )
  require_fields(annual_table, required, "annual_table")
  if (!is.null(years)) {
    if (!setequal(years, annual_table$YEAR))
      stop("Required years do not exactly match available annual records")
    annual_table <- annual_table[match(years, annual_table$YEAR), ,
                                 drop = FALSE]
  }
  if (!nrow(annual_table) || anyNA(annual_table[required]))
    stop("Annual table is empty or incomplete")
  values <- vapply(annual_table[setdiff(required, "YEAR")],
                   mean, numeric(1))
  as.list(values)
}
