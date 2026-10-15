# R modules — soil carbon sensitivity analysis

The R directory contains the **selected, refactored methods** from the original research scripts, plus reusable statistical helpers. All functions are defined without automatically executing a simulation or overwriting a DSSAT installation.

## Recommended reading order

1. [`maize_study_parameters.R`](maize_study_parameters.R) — paper-related **research source configurations**: 26 co-inertia factor names/ranges, 14 response labels, four Sobol factor ranges, five Sobol outcomes.
2. [`parameter_sampling.R`](parameter_sampling.R) — `lhs::improvedLHS` wrapper with input-bound checks.
3. [`co_inertia_analysis.R`](co_inertia_analysis.R) — study-informed LHS design, simulation response alignment, `ade4` co-inertia/PCA and plotting.
4. [`sobol_soc_analysis.R`](sobol_soc_analysis.R) — independent experimental matrices and `sensitivity::sobolSalt` functions.
5. [`soc_response_metrics.R`](soc_response_metrics.R) — SOC model-pool and N-cycling response extraction from prepared annual output tables.
6. [`sensitivity_helpers.R`](sensitivity_helpers.R) — generic statistical validation and sensitivity estimators.
7. [`maize_calibration_utils.R`](maize_calibration_utils.R) — read experiment CSVs, align cultivar/treatment observations and predictions, calculate the original weighted calibration objective and evaluation metrics.
8. [`dssat_cornCV_calib.R`](dssat_cornCV_calib.R) — documented, callable cultivar calibration with bounded `optimx` optimization and an explicit simulation interface.
9. [`mediaforarticle.R`](mediaforarticle.R) — reusable four-panel paper figures: yield, dry matter, and two annual growth-trajectory panels.

## Set up

Source modules in dependency order from the repository root:

```r
source("R/parameter_sampling.R")
source("R/sensitivity_helpers.R")
source("R/maize_study_parameters.R")
source("R/co_inertia_analysis.R")
source("R/sobol_soc_analysis.R")
source("R/soc_response_metrics.R")
source("R/maize_calibration_utils.R")
source("R/dssat_cornCV_calib.R")
source("R/mediaforarticle.R")
```

Then execute [the synthetic worked example](../examples/maize_sensitivity_demo.R) or import your own aligned simulation results. The synthetic example demonstrates the methods only; it does not reproduce the journal dataset.

## Scientific distinctions

- Original `Co_inertia1.R`: **26-factor exploratory source**; published co-inertia analysis reports **25 inputs and 14 outputs**.
- Original `Sobol.R`: four-factor design with several C/N/crop model outputs; modernized second factor matrix is **sampled independently**, not a permutation of the first.
- Carbon pools extracted from `SOMLITC.OUT` are **process-based model pools**, not direct measurements of particulate/mineral-associated organic carbon.
- The model-execution adapter is not included because the original code wrote directly to fixed paths in the installed model; a safe configured adapter is planned.

### Maize cultivar calibration and figures

The two original root-level R scripts have been moved to this directory and refactored for safe, explicit use. They **no longer install packages or launch/modify an installed DSSAT environment when sourced**. The calibration script accepts a user-supplied simulator callback and retains the historical SC10/TC310 measurement filters and weighted RMSE objective; figures require simulation output tables keyed to verified observation treatment IDs. See [the calibration migration guide](../docs/MAIZE_CALIBRATION_REFACTOR.md).

The original TC310 final evaluation inadvertently reused the SC10 optimized parameter vector; the refactoring evaluates each cultivar with its own vector. This is a documented correction, not an unnoticed scientific result change.

For a detailed source crosswalk and unchanged source hashes, see [Methods](../docs/METHODS_SOURCE_MAP.md) and [Provenance](../docs/SOURCE_PROVENANCE.md).
