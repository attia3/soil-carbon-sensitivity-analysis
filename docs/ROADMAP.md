# Development roadmap — Soil Carbon Sensitivity Analysis

The objective is to make peer-reviewed sensitivity analyses easier to understand and reproduce **without changing the publication's actual scientific method**.

## Currently available

- Legacy maize calibration and figure scripts; auxiliary CSV tables and model inputs.
- Generic `R/sensitivity_helpers.R` functions for co-inertia and Sobol analyses, assuming user-supplied compatible data/model functions.
- Generic `R/parameter_sampling.R` improved Latin hypercube sampling.
- Synthetic co-inertia example, explicitly separate from the journal article.
- Inventory of original co-inertia and Sobol source variants in `docs/UPLOADED_SOURCE_INVENTORY.md`.

## Remaining priorities

1. **Publication-specific provenance:** reconcile archived factor designs against the *Field Crops Research* paper's 25-input / 14-output co-inertia and four-factor SOC/management Sobol experiments.
2. **Match source to results:** establish script, DSSAT version, random seed, input/output matrix, plot and table for each published analysis.
3. **Preserve the originals:** select definitive archive versions and place copies under a clearly marked `legacy/` directory only after permissions and path/safety review.
4. **Make model execution safe:** remove writes to the installed genotype, ecotype, soil and experiment files; use generated run workspaces and parameterized config files.
5. **Verify generic statistical functions:** add small deterministic R tests for Latin hypercube bounds, data alignment, PCA/co-inertia and Sobol sensitivity methods.
6. **Create reproducible examples:** provide a synthetic standalone example and—if rights permit—a small real-data validation example reproducing identified statistics.
7. **Pin dependencies:** R packages/versions, experiment matrix metadata, model version and any required nonredistributable inputs.
8. **Document limitations:** make explicit which computations are reproducible using public code versus dependent on licensed scientific modeling tools and unpublished inputs.

## Potential later layout (not all files exist yet)

```text
R/
    parameter_sampling.R
    sensitivity_helpers.R
    model_evaluation.R
examples/
    synthetic_analysis.R
legacy/
    <reviewed research snapshots>
data/
    README.md
tests/
    testthat/
docs/
    methods.md
    source_to_figure_map.md
```

## Methodological scope

AHP/GIS suitability weighting, Latin hypercube input-design, co-inertia analysis, Sobol sensitivity, probability-based soil sampling and MCMC calibration solve different problems. This repository concentrates on **model-input experimental design and sensitivity of simulated SOC and crop-system responses**. It is not a soil-carbon certification engine, a validated field sampling scheme, or evidence of an implemented hierarchical Bayesian MRV framework.

Full-paper replication will only be claimed after input data and numerical results are independently cross-checked.
