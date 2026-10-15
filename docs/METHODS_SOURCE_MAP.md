# Methods and source-file crosswalk

**Study:** Attia et al. (2021), *Field Crops Research* **260**, 107981. [DOI](https://doi.org/10.1016/j.fcr.2020.107981)

This document connects the *original uploaded R scripts* to the methodological categories described in the peer-reviewed paper, while distinguishing verified source facts from unverified figure-level reproducibility.

## 1. Study methodology reported in the paper

The paper evaluated maize production and soil-carbon dynamics under arid Mediterranean conditions using a process-based DSSAT model and eight years of experimental observations. Its sensitivity section comprises:

**A. Co-inertia/global input–output associations.** The paper describes **25 selected soil and cultivar/ecotype input parameters** and **14 output variables**. Improved Latin hypercube sampling and many process-based simulation runs were used to generate input/output matrices. Multivariate ordination (PCA) and co-inertia identify associations and shared variability between the matrices. In the source scripts, core functions are `lhs::improvedLHS`, `ade4::dudi.pca`, and `ade4::coinertia`.

**B. Sobol variance-based sensitivity for SOC dynamics.** The study examines four factors related to initial/stable soil carbon and residue/compost management in a **10-year maize–fallow** simulation. Model outputs include yield, water productivity, N mineralization, SOC concentration or pools, and soil CO₂ efflux, with first-order and total-order sensitivity indices and interactions.

**C. Model calibration and evaluation.** Maize field observations and model calibration form a foundation for subsequent sensitivity experiments. The repository's root-level historical calibration scripts are relevant, but not every original input, executable, or output is distributed here.

## 2. Exact R files uploaded and now archived

| Historical R file | Core method and observed script settings | Direct file |
| --- | --- | --- |
| `Latest_1_11_20/Co_inertia1.R` | Improved LHS **1,500 × 26**; process-model runs and `dudi.pca`/`coinertia` plots | [Co_inertia1.R](../legacy/co_inertia/Co_inertia1.R) |
| `Co_inertia_3_12/Co_inertia3_12.R` | Improved LHS **1,500 × 27**; a historical variant requiring verification of input matrix construction | [Co_inertia3_12.R](../legacy/co_inertia/Co_inertia3_12.R) |
| `Latest_1_11_20/Senseanalysis5.R` | Improved LHS **1,500 × 27**; co-inertia workflow | [Senseanalysis5.R](../legacy/co_inertia/Senseanalysis5.R) |
| `Latest_1_11_20/Senseanalysis6.R` | Improved LHS **500 × 21**; co-inertia workflow | [Senseanalysis6.R](../legacy/co_inertia/Senseanalysis6.R) |
| `Latest_1_11_20/Senseanalysis7.R` | Improved LHS **500 × 24**; co-inertia workflow | [Senseanalysis7.R](../legacy/co_inertia/Senseanalysis7.R) |
| `new/Senseanalysis4.R` | **1,500 × 23** LHS, additional **2,000 × 23** design; combined co-inertia/exploratory Sobol–Owen workflow | [Senseanalysis4.R](../legacy/co_inertia/Senseanalysis4.R) |
| `Sobol_3_18/Sobol.R` | **Four factors**, `parameterSets(..., samples=200, method="sobol")`; `sobolSalt` on multiple outputs | [Sobol.R](../legacy/sobol/Sobol.R) |
| `Sobol_3_18/Sobol2/Sobol2.R` | **Four factors**, `parameterSets(..., samples=300, method="sobol")`; soil-C response | [Sobol2.R](../legacy/sobol/Sobol2.R) |

**Caution:** The number of columns supplied to an LHS design in a historical source file does **not**, by itself, verify the number of final input parameters or outputs that were successfully simulated. These are source-level design settings, not statements that every file reproduces the paper.

## 3. Execution stages in the original R analyses

1. Load R packages: notably `sensitivity`, `lhs`, `ade4`, `Dasst`, `plotrix` and, in some variants, `operators`.
2. Read calibration inputs and define ranges for soil, ecotype/cultivar and management parameters.
3. Draw an improved LHS sample or construct a Sobol parameter design.
4. For each sampled point, modify DSSAT experiment/genotype/soil/rotation parameters (historical code uses installed model file paths).
5. Run DSSAT using the original system command and parse output files into simulation-response matrices.
6. Use co-inertia/PCA or Sobol/Saltelli calculations to characterize important factors, main effects and interactions.
7. Plot associations or sensitivity indices and compare with the paper's tables/figures.

**Source-level caveat:** The Sobol archives include paired factor matrices formed by row-permuting a single design. Before claiming exact Sobol estimates or using the approach in new work, examine the intended estimator's design/independence requirements and test the original numerical outputs.

## 4. Which files are easiest to use for other models?

| Code | Transferable part | Model-specific dependency |
| --- | --- | --- |
| [`R/parameter_sampling.R`](../R/parameter_sampling.R) | Latin hypercube experimental design across explicit parameter bounds | None, if valid bounds are supplied |
| [`R/sensitivity_helpers.R`](../R/sensitivity_helpers.R) | PCA/co-inertia for aligned tables; Sobol analysis for model functions and matched designs | Caller must supply a valid statistical design and model outputs |
| [Original co-inertia scripts](../legacy/co_inertia/) | Published-method experimental design and interpretation | DSSAT input files, installed model, local paths, cultivar/soil definition |
| [Original Sobol scripts](../legacy/sobol/) | SOC-response calculation logic and sensitivity setup | DSSAT sequential model, site management/soil inputs, saved output conventions |

## 5. Reproducibility limitations and validation plan

The public repository now contains **all eight original R analysis scripts** with only safety guards added. However, the original ZIPs also contain session images, intermediate datasets and local model assets not copied here.

**Do not claim one-click replication.** A verified reproduction of the 2021 article requires determining the final 25-factor co-inertia source variant and mapping the **14 documented outputs**, aligning the original model and experiment files, and reproducing the published figures and sensitivity indices.

Recommended audit trail: original source snapshot → parameter schema and units → input parameter design → simulation executable/configuration → exact model outputs → analysis script → paper figure/table → code commit.

This is **statistical model sensitivity research**, not a certified carbon-crediting implementation.
