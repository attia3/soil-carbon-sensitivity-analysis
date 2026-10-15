# R modules — soil carbon sensitivity analysis

The R directory contains the **selected, refactored methods** from the original research scripts, plus reusable statistical helpers. All functions are defined without automatically executing a simulation or overwriting a DSSAT installation.

## Recommended reading order

1. [`maize_study_parameters.R`](maize_study_parameters.R) — paper-related **research source configurations**: 26 co-inertia factor names/ranges, 14 response labels, four Sobol factor ranges, five Sobol outcomes.
2. [`parameter_sampling.R`](parameter_sampling.R) — `lhs::improvedLHS` wrapper with input-bound checks.
3. [`co_inertia_analysis.R`](co_inertia_analysis.R) — study-informed LHS design, simulation response alignment, `ade4` co-inertia/PCA and plotting.
4. [`sobol_soc_analysis.R`](sobol_soc_analysis.R) — independent experimental matrices and `sensitivity::sobolSalt` functions.
5. [`soc_response_metrics.R`](soc_response_metrics.R) — SOC model-pool and N-cycling response extraction from prepared annual output tables.
6. [`sensitivity_helpers.R`](sensitivity_helpers.R) — generic statistical validation and sensitivity estimators.

## Set up

Source modules in dependency order from the repository root:

```r
source("R/parameter_sampling.R")
source("R/sensitivity_helpers.R")
source("R/maize_study_parameters.R")
source("R/co_inertia_analysis.R")
source("R/sobol_soc_analysis.R")
source("R/soc_response_metrics.R")
```

Then execute [the synthetic worked example](../examples/maize_sensitivity_demo.R) or import your own aligned simulation results. The synthetic example demonstrates the methods only; it does not reproduce the journal dataset.

## Scientific distinctions

- Original `Co_inertia1.R`: **26-factor exploratory source**; published co-inertia analysis reports **25 inputs and 14 outputs**.
- Original `Sobol.R`: four-factor design with several C/N/crop model outputs; modernized second factor matrix is **sampled independently**, not a permutation of the first.
- Carbon pools extracted from `SOMLITC.OUT` are **process-based model pools**, not direct measurements of particulate/mineral-associated organic carbon.
- The model-execution adapter is not included because the original code wrote directly to fixed paths in the installed model; a safe configured adapter is planned.

For a detailed source crosswalk and unchanged source hashes, see [Methods](../docs/METHODS_SOURCE_MAP.md) and [Provenance](../docs/SOURCE_PROVENANCE.md).
