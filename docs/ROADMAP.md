# Roadmap — Soil Carbon Dynamics and Sensitivity Analysis

## Confirmed public assets

The current repository contains two R scripts for cultivar calibration and plotting, two CSV data files, and a DSSAT-files directory. The original scripts depend on absolute `D:/...` and `C:/DSSAT47/...` paths.

## Needed original research materials

Import the verified scripts from the 2022 co-inertia and sensitivity study workspace, preserving the published method and its exact input/output conventions:

- Co-inertia analysis associating 14 DSSAT outputs and 25 soil and cultivar inputs.
- Sobol-based sensitivity / variance decomposition for SOC dynamics, initial and stable SOC, residue retention and compost.
- Experiment tables, sampling designs, management inputs, and data dictionaries needed to reproduce reported figures.
- Exact R package versions, random seeds, DSSAT executable/model version, and reproducibility limitations.

**Do not replace the original published methods with approximate example scripts and label them as the article's implementation.**

## Proposed repository structure (not present yet)

```text
R/
    calibrate_maize.R
    co_inertia.R
    sobol_soc.R
    model_evaluation.R
data/
    README.md             # permitted data and provenance
    example/              # small reproducible fixtures only
inst/
    dssat/                # templates permitted to distribute
scripts/
    run_calibration.R
    run_sensitivity.R
tests/
    testthat/
docs/
    methods.md            # published methods vs repository code
legacy/
    dssat_cornCV_calib.R
    mediaforarticle.R
```

## Engineering and scientific quality checks

1. Archive unmodified 2019 calibration scripts under `legacy/`.
2. Convert hard-coded paths to a project-root configuration and avoid writing to installed DSSAT genotype files by default.
3. Document source, units, sampling/runs, factor definitions and outputs for all figures.
4. Validate co-inertia and Sobol analysis on the original saved results, or clearly mark datasets that cannot be redistributed.
5. Add small deterministic fixtures and R unit tests for parsing, metrics, and sampled parameter ranges.
6. Provide a direct link to the publication DOI and a code-to-figure reproducibility matrix.
7. Select a license after checking collaborator and institutional ownership of scripts/data.

## Scope boundaries

- **Co-inertia and Sobol sensitivity analysis** are documented by the paper; they are not equivalent to a probability-based soil sampling design.
- **Optimization for parameter fit** is not in itself Bayesian hierarchical estimation or MCMC.
- No claim is made that this software is Verra/Isometric certified or applicable to carbon credits without further evaluation.
