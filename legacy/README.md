# Original R research scripts — co-inertia and Sobol analysis

This directory contains the **actual R scripts** from the uploaded co-inertia and Sobol project archives. The purpose is to make the statistical methods and model-parameter experiments visible alongside the peer-reviewed paper.

## Safety first

**These files are archival research source, not directly executable reproducibility packages.** The R code originally assumed local `C:/DSSAT47` and `D:/ISmalia_DSSAT` directories and includes writing to DSSAT cultivar, ecotype, soil and experiment files, followed by executing the DSSAT command-line program.

Each archived file retains the original scientific logic and has a short header with a **`stop()` guard inserted before the original first line**. This prevents accidental execution against an installed model directory. Do not remove the guard until you have reviewed all file write operations, obtained a licensed local installation, and prepared a **disposable experiment copy** with independent backups.

The original ZIPs included `.RData`, `.Rhistory`, IDE metadata and some derived outputs. These have not been published in this directory.

## Navigation

### Co-inertia family

- [Co_inertia1.R](co_inertia/Co_inertia1.R) — 1,500-run improved Latin hypercube, 26-factor variant, simulation loops and PCA/co-inertia.
- [Co_inertia3_12.R](co_inertia/Co_inertia3_12.R) — a historical 27-factor design; inspect the actual input matrix before execution.
- [Senseanalysis5.R](co_inertia/Senseanalysis5.R) — 1,500-run 27-factor experiment.
- [Senseanalysis6.R](co_inertia/Senseanalysis6.R) — 500-run 21-factor experiment.
- [Senseanalysis7.R](co_inertia/Senseanalysis7.R) — 500-run 24-factor experiment.
- [Senseanalysis4.R](co_inertia/Senseanalysis4.R) — 1,500-run 23-factor co-inertia design plus another 2,000-run 23-factor experiment and exploratory `sobolowen` analysis.

### Sobol family

- [Sobol.R](sobol/Sobol.R) — four-factor 200-sample design, DSSAT sequence execution, and Sobol/Saltelli response analyses.
- [Sobol2.R](sobol/Sobol2.R) — four-factor 300-sample variant focused on a soil-carbon response.

### Reusable model-independent utilities

- [R/sensitivity_helpers.R](../R/sensitivity_helpers.R): functions for co-inertia analysis and Sobol/Saltelli sensitivity on user-provided inputs.
- [R/parameter_sampling.R](../R/parameter_sampling.R): improved Latin hypercube designs using user-defined factor ranges.
- [Synthetic example](../examples/synthetic_analysis.R): demonstrations without licensed model software, **not** the original study inputs.

## Scientific interpretation

The article reports a **co-inertia analysis of 25 inputs and 14 simulated outputs** and **Sobol analysis of four soil-carbon/management factors**. The archival R files include multiple historical experiments with factor counts not necessarily identical to the published design. The exact figure-to-file correspondence is **not yet independently confirmed**.

See [METHODS_SOURCE_MAP.md](../docs/METHODS_SOURCE_MAP.md) for details, including model-input dependencies and reproducibility boundaries.

### Citation

Attia, A. et al. (2021). *Sensitivity of the DSSAT model in simulating maize yield and soil carbon dynamics in arid Mediterranean climate: Effect of soil, genotype and crop management*. **Field Crops Research**, 260, 107981. https://doi.org/10.1016/j.fcr.2020.107981
