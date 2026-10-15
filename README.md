# Soil Carbon Sensitivity Analysis

**Carbon dynamics · Model calibration · Global sensitivity analysis · Variance decomposition**

Scientific code and methods for investigating how **soil characteristics, management inputs, and model parameters** influence simulated soil organic carbon (SOC) and related agroecosystem outcomes.

The **statistical methods are transferable across models**; the peer-reviewed study motivating this repository used **DSSAT** for maize and SOC dynamics under arid Mediterranean conditions.

## Associated peer-reviewed study

**Attia, A., et al. (2021).** [Sensitivity of the DSSAT model in simulating maize yield and soil carbon dynamics in arid Mediterranean climate: Effect of soil, genotype and crop management](https://doi.org/10.1016/j.fcr.2020.107981). *Field Crops Research*, **260**, 107981.

The study combined:

- **Calibration and evaluation** of simulated maize growth, water balance, nitrogen dynamics, and related outputs against field measurements.
- **Co-inertia analysis** relating 25 soil/cultivar inputs to 14 model outputs.
- **Sobol global sensitivity analysis** to investigate contributions and interactions of carbon-related soil properties and crop management.
- Long-term interpretation of SOC stock change, carbon turnover, residue retention, organic amendments, and soil CO₂ emissions.

**Scientific provenance:** The original research archives include several historical versions with different factor sets. These have not yet been fully matched to the publication's final tables and figures.

## Repository contents

### Reusable, model-independent statistical functions

| File | Purpose |
| --- | --- |
| [`R/parameter_sampling.R`](R/parameter_sampling.R) | Improved Latin hypercube samples within explicitly defined parameter bounds |
| [`R/sensitivity_helpers.R`](R/sensitivity_helpers.R) | Co-inertia analysis and Sobol/Saltelli sensitivity wrappers for user-provided model inputs/outputs |
| [`examples/synthetic_analysis.R`](examples/synthetic_analysis.R) | Synthetic, standalone example illustrating co-inertia; **not the study dataset** |

### Preserved historical research assets

| File | Purpose |
| --- | --- |
| [`dssat_cornCV_calib.R`](dssat_cornCV_calib.R) | Maize cultivar calibration against field observations |
| [`mediaforarticle.R`](mediaforarticle.R) | Research plotting and comparison of measured versus simulated data |
| [`Corn_calibration.csv`](Corn_calibration.csv), [`OBS_Calib-Data_.csv`](OBS_Calib-Data_.csv) | Calibration parameters and observation examples |
| [`DSSAT-files/`](DSSAT-files/) | Original model-related project assets |

The historical scripts contain local Windows file paths and can overwrite model genotype and experiment inputs. **Review and run them in an isolated working copy**, not directly against an installed model directory.

## Example — explore links between input and output variables

Use R with the CRAN package `ade4`; optional functions require `lhs` and `sensitivity`.

```r
install.packages(c("ade4", "lhs", "sensitivity"))
source("R/sensitivity_helpers.R")
source("R/parameter_sampling.R")

# Run from the repository root:
# Rscript examples/synthetic_analysis.R
```

`run_co_inertia(inputs, outputs)` accepts numeric tables with matched simulation rows. `make_lhs_design(bounds, n_samples)` draws a parameter experiment design. `run_sobol_salt(model_function, x1, x2)` is a generic Sobol wrapper.

**These reusable helpers are not yet validated as an end-to-end replication of the article.** The original experiment ranges, model runs, and saved outputs must be verified before claiming to reproduce published statistics.

## Relevance to soil carbon quantification

Sensitivity analysis identifies influential model assumptions and their interactions. That can inform:

- prioritization of soil and management measurements;
- parameter calibration and independent model evaluation;
- investigation of uncertainty drivers in SOC predictions;
- design of spatial simulation studies across heterogeneous environments.

These are methodological building blocks, **not** a substitute for probability-based soil sampling, carbon-stock uncertainty accounting, or a registry-approved crediting procedure.

## Development and reproducibility

- [Inventory of original co-inertia and Sobol scripts](docs/UPLOADED_SOURCE_INVENTORY.md)
- [Validation and repository modernization roadmap](docs/ROADMAP.md)
- [Companion regional modeling pipeline](https://github.com/attia3/agroecosystem-simulation-pipeline)

## Citation, limitations, and permissions

Maintained by **Ahmed Attia**. Cite the [*Field Crops Research* paper](https://doi.org/10.1016/j.fcr.2020.107981) for the scientific findings and a specific Git commit for the available source code.

The published calculations have **not yet been reproduced from the public repository alone**. Licensed scientific software, institutional datasets, and experiment inputs may be required. No open-source license has been specified.
