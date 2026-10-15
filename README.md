# Soil Carbon Dynamics and Sensitivity Analysis

**Model calibration • Global sensitivity • Variance decomposition • SOC dynamics**

Scientific methods and research source material relating to parameter estimation, co-inertia analysis and Sobol sensitivity of soil organic carbon (SOC) and crop-system dynamics in arid environments. The repository's title reflects **methods transferable to multiple process-based models**, while the original publication and legacy scripts use DSSAT.

## Peer-reviewed research

Attia, A., et al. (2021). *Sensitivity of the DSSAT model in simulating maize yield and soil carbon dynamics in arid Mediterranean climate: Effect of soil, genotype and crop management*. **Field Crops Research**, 260, 107981. https://doi.org/10.1016/j.fcr.2020.107981

The paper:
- evaluated process-based simulations against eight years of experimental observations;
- used **co-inertia analysis** for relationships among model input factors and outputs;
- applied **Sobol variance-based global sensitivity analysis** to SOC-related parameters and crop management (initial and stable SOC, residues, compost);
- interpreted model output variability and interactions among influential inputs.

**Scientific provenance:** The published co-inertia analysis describes 25 soil/cultivar inputs and 14 outputs. The supplied archived scripts contain several historical experiments with different input counts. Those versions have not yet been linked unambiguously to the paper's final figures.

## What's in this repository?

| Code | Purpose / limitation |
| --- | --- |
| `dssat_cornCV_calib.R` | Historical maize cultivar calibration; depends on locally installed model |
| `mediaforarticle.R` | Historical observed/simulated figure workflow; model paths are not portable |
| `Corn_calibration.csv`, `OBS_Calib-Data_.csv` | Original small calibration/observation tables |
| `DSSAT-files/` | Legacy project inputs |
| `R/parameter_sampling.R` | Improved Latin hypercube sampling of user-specified parameter ranges |
| `R/sensitivity_helpers.R` | New **model-agnostic** co-inertia and Sobol analytical wrappers |
| `examples/synthetic_analysis.R` | Synthetic co-inertia example; **not the paper dataset** |
| `docs/UPLOADED_SOURCE_INVENTORY.md` | Inventory of verified co-inertia and Sobol source-script variants |
| `docs/ROADMAP.md` | Reproduction, modernization and validation work to do |

## Run a synthetic statistical example

Requires R and the CRAN package `ade4` for the co-inertia demonstration; install `lhs` for parameter sampling and `sensitivity` for Sobol analysis:

```r
install.packages(c("ade4", "lhs", "sensitivity"))
source("R/sensitivity_helpers.R")
# At the project root, run: Rscript examples/synthetic_analysis.R
```

`run_co_inertia(inputs, outputs)` accepts numeric input and output tables with aligned simulation rows, and performs PCA followed by co-inertia using `ade4`.

`run_sobol_salt(model_function, x1, x2)` wraps the `sensitivity` package's Sobol/Saltelli estimator for **user-supplied factor matrices and a user-supplied model function**. It is not the original article's full simulation driver; no claim is made that a synthetic example reproduces published numerical results.

## Reproducibility status

The original source archives include multiple co-inertia configurations and two Sobol variants. They require local model installations and scripts that may overwrite genotype, soil and experiment input files. The publication-specific code, input schema and outputs need a figure-by-figure crosswalk and separate safe execution before the repository can be described as a full replication package.

**This work demonstrates sensitivity analysis and evaluation of soil carbon dynamics, not independently approved crediting or certification software.**

## Use beyond a single model

The statistical helpers accept generic numerical data or a callable model interface and may be applied to other process-based models when model-specific simulation inputs, calibration and parameter ranges are verified. The published numerical results belong to the DSSAT study and should be cited accordingly.

## Citation and rights

Ahmed Attia and coauthors, *Field Crops Research* (2021), DOI above. Original code and institutional or third-party DSSAT assets may have separate rights. No explicit open-source license has been selected.
