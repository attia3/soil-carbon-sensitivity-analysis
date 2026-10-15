# Soil Carbon Sensitivity Analysis

**Global sensitivity · Co-inertia · Sobol indices · Process-based model calibration · SOC dynamics**

Research-oriented R workflows for quantifying how soil properties, cultivar parameters, and management practices influence soil organic carbon (SOC), productivity, and nutrient cycling. The statistical components are **model-independent**. Their scientific provenance is a published maize/DSSAT study in arid Mediterranean conditions.

## Associated publication

**Attia, A., et al. (2021)**. [Sensitivity of the DSSAT model in simulating maize yield and soil carbon dynamics in arid Mediterranean climate: Effect of soil, genotype and crop management](https://doi.org/10.1016/j.fcr.2020.107981). *Field Crops Research*, **260**, 107981.

The study evaluated a calibrated process-based model and applied two complementary techniques:
- **Co-inertia analysis**, relating multivariate soil/cultivar inputs to crop, soil, and water output variables.
- **Sobol variance-based sensitivity analysis**, quantifying main effects and interactions for carbon-related soil and management factors.

## Analysis workflow

```text
Soil / cultivar / management parameter ranges
                    │
       Latin hypercube or Saltelli design
                    │
    User-supplied process-based simulator
                    │
       Checked, matched response tables
                    │
    ┌───────────────┴────────────────┐
    │                                │
PCA + co-inertia                  Sobol indices
Input/output associations         Main and total effects
    └───────────────┬────────────────┘
        SOC response interpretation
```

## R scripts

**Selected historical research methods have been consolidated into readable, configurable files under [`R/`](R/), without keeping eight nearly redundant or destructive original drivers.**

| File | What it does |
| --- | --- |
| [`maize_study_parameters.R`](R/maize_study_parameters.R) | **Source-derived** factor ranges and response names: 26-factor co-inertia exploratory variant, four-factor SOC Sobol design, 14 co-inertia outputs, five Sobol outputs |
| [`co_inertia_analysis.R`](R/co_inertia_analysis.R) | Builds LHS runs, checks and aligns simulation outputs by run ID, performs paired PCA/co-inertia, and plots loadings |
| [`sobol_soc_analysis.R`](R/sobol_soc_analysis.R) | Builds independent Sobol/Saltelli A/B parameter matrices and computes variance-based sensitivity for model outputs |
| [`soc_response_metrics.R`](R/soc_response_metrics.R) | Extracts annual carbon-pool and N-cycling response variables from already-parsed soil C/N outputs |
| [`parameter_sampling.R`](R/parameter_sampling.R) | General-purpose improved Latin hypercube sampling |
| [`sensitivity_helpers.R`](R/sensitivity_helpers.R) | Reusable co-inertia/PCA and Sobol statistical functions |

The repository also retains [maize calibration](dssat_cornCV_calib.R) and [observed-versus-simulated figure code](mediaforarticle.R) from the original study; those historical calibration scripts require a local installation and are not independently portable.

## Quick start

Install R packages used by the analysis:

```r
install.packages(c("lhs", "ade4", "sensitivity"))
```

Run the **synthetic demo** from the repository root:

```bash
Rscript examples/maize_sensitivity_demo.R
Rscript tests/test_sensitivity_pipeline.R
```

Or load the reusable functions and create a study-informed design:

```r
source("R/parameter_sampling.R")
source("R/sensitivity_helpers.R")
source("R/maize_study_parameters.R")
source("R/co_inertia_analysis.R")
source("R/sobol_soc_analysis.R")
source("R/soc_response_metrics.R")

design <- design_maize_co_inertia(n = 1500, seed = 2026)
sobol_design <- make_soc_sobol_design(n = 200, seed = 2026)

# Feed the parameter matrices to YOUR safely configured model adapter.
# Responses must use matching run IDs and the documented output names:
# fit <- analyze_maize_co_inertia(design, responses)
# indices <- analyze_soc_sobol(model_function, design = sobol_design)
```

**These demonstrations use synthetic model responses.** No locally installed DSSAT executable is launched, and none of these R functions modifies installed soil, genotype, or experiment files.

## Original methods and selection

From the uploaded 2020 research archives, two variants were selected for refactoring:

| Source variant | Why selected | What was retained |
| --- | --- | --- |
| `Co_inertia1.R` | Explicit carbon-pool inputs (SAOC/SASC) in a detailed **26-factor, 1,500-run** LHS design | Exact exploratory factor ranges, the **14 source output names**, PCA/co-inertia approach |
| `Sobol.R` | **Four-factor**, multiresponse SOC and crop sensitivity experiment | Factor ranges, SOC/nitrogen response definitions, Sobol/Saltelli analysis structure |

The source study reports **25 inputs and 14 outputs** for the co-inertia analysis. The selected archived script contains **26 design factors**; that discrepancy remains unresolved. Accordingly, the provided files reproduce **the analytical methods and selected source configurations**, not the paper's final numerical tables or sensitivity figures.

The independent Sobol A/B sampling in the modernized code also replaces the row-permutation approach used in the historical script. This improves the design's statistical independence but means estimates are **not guaranteed to equal historical results**.

[Method provenance and original-version comparison](docs/METHODS_SOURCE_MAP.md) · [Research source inventory](docs/UPLOADED_SOURCE_INVENTORY.md)

## Reproducibility and scientific safeguards

- Numeric model responses are checked for finiteness and matched to factor designs using unique `run_id` values.
- Factor bounds and simulated response names are explicit, rather than implicit in fixed line-number edits.
- Simulation execution is injected through a callback, enabling separate safe adapters with versioned inputs and run directories.
- The SOC fractions calculated from model pools **cannot be directly equated with physical laboratory POM/MAOC fractions**.
- Full publication replication requires verifying the final experiment design, simulator version, original weather/soil/management inputs, and output matrices. See the [reproducibility roadmap](docs/ROADMAP.md).

This is **scientific sensitivity analysis, not an approved carbon-crediting or soil-sampling methodology**.

## Related code

- [Agroecosystem Simulation Pipeline](https://github.com/attia3/agroecosystem-simulation-pipeline)
- [SOC–N₂O ML Surrogate](https://github.com/attia3/THP-SOC-N2O-ML-surrogate)
- [NAYD geospatial analysis](https://github.com/attia3/nayd)

## Citation and rights

Maintained by **Ahmed Attia**. Cite the *Field Crops Research* paper for scientific findings and a specific Git commit for source code. The historical DSSAT calibration code and third-party data have separate dependencies and rights. No open-source license has yet been selected.
