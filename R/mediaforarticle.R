#' Figure generation for maize cultivar calibration/evaluation
#'
#' Refactored from mediaforarticle.R (2019), Attia et al. (2021),
#' Field Crops Research 260, 107981.
#'
#' Preserves the scientific figure categories:
#' (1) observed vs simulated grain yield;
#' (2) observed vs simulated aboveground dry matter;
#' (3) biomass trajectories and observations for first growing season;
#' (4) biomass trajectories and observations for second season.
#'
#' Assumes a *provided* list of already generated PlantGro tables named
#' with observation treatment IDs. This is intentional: unlike the original
#' script, sourcing this module does not overwrite DSSAT cultivar/ecotype
#' files or launch a licensed model on a hard-coded installation.
#'
#' Source R/maize_calibration_utils.R before calling the functions here.

#' Align a named collection of model outputs to treatment observations.
#'
#' @param simulations Named list: names are treatment IDs from
#'   OBS_Calib-Data_.csv; list elements are PlantGro data frames.
#' @param treatment_ids Integer treatment IDs in observation order.
#' @return Ordered list of model output tables.
maize_align_simulation_tables <- function(simulations, treatment_ids) {
  if (!is.list(simulations) || is.null(names(simulations))) {
    stop("Provide a named list of PlantGro tables keyed by treatment ID")
  }
  keys <- as.character(treatment_ids)
  if (anyDuplicated(names(simulations)) ||
      !all(keys %in% names(simulations))) {
    stop("Missing or duplicated treatment identifiers in simulations: ",
         paste(setdiff(keys, names(simulations)), collapse = ", "))
  }
  lapply(simulations[keys], as.data.frame)
}

#' Draw one measured/simulated scatter panel with model statistics.
#'
#' Values are supplied in kg/ha; displayed data are converted to Mg/ha.
maize_plot_scatter_panel <- function(observed, simulated, heading,
                                     max_axis = NULL) {
  metrics <- maize_model_metrics(observed, simulated)
  x <- observed / 1000
  y <- simulated / 1000
  upper <- if (is.null(max_axis)) {
    max(c(x, y), na.rm = TRUE) * 1.08
  } else as.numeric(max_axis)
  if (!is.finite(upper) || upper <= 0) stop("Invalid axis limit")

  graphics::plot(
    x, y, pch = 21, bg = "grey70", col = "grey25",
    xlim = c(0, upper), ylim = c(0, upper),
    xlab = expression(paste("Observed (Mg ", ha^{-1}, ")")),
    ylab = expression(paste("Simulated (Mg ", ha^{-1}, ")")),
    main = heading, xaxs = "i", yaxs = "i"
  )
  graphics::abline(0, 1, lty = 2, col = "grey35", lwd = 1.4)
  if (metrics$n >= 2L && stats::sd(x) > 0) {
    graphics::abline(stats::lm(y ~ x), col = "steelblue4", lwd = 1.4)
  }
  metric_labels <- c(
    sprintf("n = %d", metrics$n),
    sprintf("RMSE = %.3f Mg/ha", metrics$rmse / 1000),
    sprintf("RRMSE = %.1f%%", metrics$rrmse_pct),
    sprintf("R² = %.2f", metrics$r_squared),
    sprintf("NSE = %.2f", metrics$nse)
  )
  graphics::legend(
    "topleft", legend = metric_labels,
    bty = "n", cex = 0.70, text.col = "grey25"
  )
  invisible(metrics)
}

#' Draw growing-season modeled biomass trajectories with measured points.
#'
#' Uses source study treatment identifiers and observed irrigation levels
#' rather than hard-coded record numbers or manually repeated plot calls.
#' Model traces are selected by treatment ID, preventing accidental mismatch
#' when the number/order of treatments differs between calibration runs.
maize_plot_growth_panel <- function(
    observations, simulations, cultivar, year, nitrogen = 190L,
    days = c(60L, 75L), show_until = 110L) {
  required <- c("Trt", "CV", "Yr", "Nit", "Vari", "DAP", "Value", "Irri")
  if (!is.data.frame(observations) ||
      !all(required %in% names(observations))) {
    stop("Observations require ", paste(required, collapse = ", "))
  }
  x <- observations[
    as.character(observations$CV) == as.character(cultivar) &
      as.character(observations$Yr) == as.character(year) &
      as.character(observations$Nit) == as.character(nitrogen) &
      observations$Vari == "totaldryweight" &
      as.integer(as.character(observations$DAP)) %in% days, ,
    drop = FALSE
  ]
  if (!nrow(x)) stop("No biomass observations for ", cultivar, " ", year)
  x$Trt <- as.integer(as.character(x$Trt))
  x$DAP <- as.integer(as.character(x$DAP))
  x$Value <- as.numeric(x$Value)
  treatments <- unique(x[, c("Trt", "Irri"), drop = FALSE])
  treatments <- treatments[order(treatments$Irri, treatments$Trt),
                           , drop = FALSE]
  runs <- maize_align_simulation_tables(simulations, treatments$Trt)
  colors <- grDevices::hcl.colors(nrow(treatments), palette = "Dark 3")

  all_values <- unlist(lapply(runs, function(d) {
    if (!all(c("DAP", "CWAD") %in% names(d))) {
      stop("Each model table must contain DAP and CWAD")
    }
    d$CWAD[d$DAP <= show_until] / 1000
  }), use.names = FALSE)
  y_max <- max(c(all_values, x$Value / 1000), na.rm = TRUE) * 1.10
  if (!is.finite(y_max) || y_max <= 0) stop("Invalid model biomass data")

  graphics::plot(
    NA_real_, NA_real_, type = "n",
    xlim = c(0, as.numeric(show_until)), ylim = c(0, y_max),
    xlab = "Days after planting",
    ylab = expression(paste("Dry matter (Mg ", ha^{-1}, ")")),
    main = sprintf("%s — %s", cultivar, year),
    xaxs = "i", yaxs = "i"
  )
  for (i in seq_len(nrow(treatments))) {
    id <- treatments$Trt[i]
    model <- runs[[i]]
    included <- which(model$DAP <= show_until)
    graphics::lines(model$DAP[included], model$CWAD[included] / 1000,
                    col = colors[i], lwd = 1.6)
    measured <- x[x$Trt == id, , drop = FALSE]
    if (anyDuplicated(measured$DAP) ||
        !setequal(measured$DAP, days)) {
      stop("Expected one biomass observation at each specified DAP for treatment ", id)
    }
    graphics::points(measured$DAP, measured$Value / 1000,
                     pch = 21, bg = colors[i], col = "grey20", cex = 1.1)
  }
  graphics::legend(
    "topleft", legend = as.character(treatments$Irri),
    col = colors, lty = 1, lwd = 1.6, pch = 21, pt.bg = colors,
    bty = "n", cex = 0.78
  )
  invisible(treatments)
}

#' Produce a reproducible four-panel cultivar evaluation figure.
#'
#' @param observations Table loaded from OBS_Calib-Data_.csv.
#' @param simulations Named list of PlantGro tables; e.g.
#'   list("1" = run1, "2" = run2, ...).
#' @param cultivar Cultivar label SC10 or TC310.
#' @param nitrogen Original study used treatment nitrogen=190.
#' @param years Two years for the crop-growth trajectory panels.
#' @param file Optional PDF file path; NULL plots on current R device.
#' @return Invisible list with grain and biomass model metrics.
plot_maize_paper_figures <- function(
    observations, simulations, cultivar, nitrogen = 190L,
    years = c(2005L, 2006L), file = NULL) {
  if (length(years) != 2L || anyDuplicated(years)) {
    stop("Supply exactly two distinct years for the four-panel figure")
  }
  targets <- maize_observed_targets(
    observations, cultivar = cultivar, nitrogen = nitrogen
  )
  ordered <- maize_align_simulation_tables(simulations, targets$treatment_ids)
  modeled <- maize_simulated_targets(
    ordered, dry_matter_days = targets$dry_matter_days
  )
  # Fail early if prediction and observation lengths differ.
  maize_calibration_objective(targets, modeled)

  made_device <- FALSE
  if (!is.null(file)) {
    grDevices::pdf(file = file, width = 12, height = 9)
    made_device <- TRUE
  }
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit({
    graphics::par(old_par)
    if (made_device) grDevices::dev.off()
  }, add = TRUE)
  graphics::par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3.0, 1.2),
                mgp = c(2.5, 0.8, 0))

  grain <- maize_plot_scatter_panel(
    targets$observed_grain, modeled$simulated_grain,
    heading = sprintf("%s: grain yield", cultivar)
  )
  dry_matter <- maize_plot_scatter_panel(
    targets$observed_dry_matter, modeled$simulated_dry_matter,
    heading = sprintf("%s: aboveground dry matter", cultivar)
  )
  for (year in years) {
    maize_plot_growth_panel(
      observations, simulations, cultivar = cultivar,
      year = year, nitrogen = nitrogen,
      days = targets$dry_matter_days
    )
  }
  invisible(list(
    cultivar = cultivar,
    grain_yield = grain,
    dry_matter = dry_matter,
    treatment_count = length(targets$treatment_ids)
  ))
}
