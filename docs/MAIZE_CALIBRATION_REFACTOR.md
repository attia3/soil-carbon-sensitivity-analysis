# Maize calibration and figure scripts: scientific refactoring notes

**Associated research:** Attia et al. (2021), *Field Crops Research*, 260, 107981. https://doi.org/10.1016/j.fcr.2020.107981

The two former root-level files have been reorganized into:

- [R/maize_calibration_utils.R](../R/maize_calibration_utils.R): shared measured-data alignment and model evaluation.
- [R/dssat_cornCV_calib.R](../R/dssat_cornCV_calib.R): cultivar-specific bounded optimization.
- [R/mediaforarticle.R](../R/mediaforarticle.R): reusable yield, dry matter, and growing-season graphics.

The original versions remain available through Git history. These modules are intentionally not presented as a byte-identical execution of the paper.

## Original scientific method retained

| Element | Original research script | Current implementation |
| --- | --- | --- |
| Maize cultivars | SC10 and TC310 | Same cultivar identifiers |
| Observed nitrogen treatment | Nit = 190 | Same, explicitly supplied |
| Total dry matter | DAP 60 and 75, variable totaldryweight | Same, aligned by treatment ID and DAP |
| Grain yield | DAP 110, variable GrainYield | Same |
| Model biomass | PlantGro.OUT CWAD at DAP 60/75 | Same variable/day selection |
| Model grain yield | Final GWAD of each model treatment | Same |
| Calibration loss | RMSE(total dry matter)/100 + RMSE(grain yield)/50 | Same formula, explicit function |
| Optimization | optimx: Nelder-Mead, hjkb, L-BFGS-B | Same primary method choices, configurable |
| Extra exploratory optimizers | Additional dfoptim::hjkb and FME::modFit(Pseudo) runs | Not part of the refactored primary workflow; the original script selected its final vector from optimx |
| Figure panels | Yield, biomass and growing-season curves (2005/2006) | Same scientific comparisons, with reusable plotting |

## Explicit correction to the historical code

In the original TC310 calibration block, optimization produced a TC310 vector, but final evaluation called the model with the **SC10 optimized vector**. The modernized code evaluates each cultivar using its **own** optimized parameters.

This likely fixes a copy-and-paste issue; it may change the TC310 numerical results if the original output was derived from that incorrect call. Compare the new results with the original outputs before describing them as a paper reproduction.

## Safety and execution

The original scripts automatically installed packages, set machine-specific absolute paths, overwrote installed cultivar/ecotype files, and launched the DSSAT executable on import.

The refactored modules **define functions only**. Calibration requires an explicit function of the form **simulate(parameter_values, cultivar, treatment_ids)** returning ordered PlantGro tables; users must implement that function against a licensed, **disposable and backed-up experiment workspace**. The project does not currently supply a complete DSSAT execution adapter.

The primary optimizer requires the CRAN optimx package. Plotting uses base R graphics and expects a **named list of PlantGro data frames keyed to treatment IDs**.

## Minimal usage

From the repository root:

~~~r
source("R/maize_calibration_utils.R")
source("R/dssat_cornCV_calib.R")
source("R/mediaforarticle.R")

project <- read_maize_calibration_data(".")
bounds <- maize_calibration_bounds(project$parameters)

# Once a separate simulator has been configured:
# fit <- calibrate_maize_cultivar(
#   "SC10", project$observations, project$parameters, simulate = simulate
# )

# With previously verified, treatment-keyed model outputs:
# plot_maize_paper_figures(
#   project$observations, simulations = named_plantgro_runs,
#   cultivar = "SC10", file = "SC10_evaluation.pdf"
# )
~~~

## Tests and reproducibility limits

~~~sh
Rscript tests/test_maize_calibration.R
Rscript tests/test_sensitivity_pipeline.R
~~~

The maize test uses the *actual* repository CSVs and **synthetic** modeled treatments. It verifies treatment/day matching, the weighted objective, graphics output and fail-loudly input checks. It does **not** run DSSAT or assess the expensive optimx process against field data.

Exact paper reproduction still requires confirming the DSSAT version, weather/soil/management inputs, model-run-to-treatment mapping, saved model output tables, and the historical TC310 fit.
