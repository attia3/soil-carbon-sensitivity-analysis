# Source review — original scientific methods

The user supplied three research archives for assessing and expanding these repositories. This note documents **methods and provenance**. All eight original R source scripts have now been placed under [`legacy/`](../legacy/) with top-level execution guards. Entire workspace folders, session images, IDE metadata, and intermediate data files are **not** published.

## Co-inertia archive (original R scripts now published in [`legacy/co_inertia/`](../legacy/co_inertia/)): `Co_interia_19_12_22.zip`

- `Latest_1_11_20/Co_inertia1.R`: improved Latin hypercube design (26 input factors in this variant), simulation outputs and paired PCA / `ade4::coinertia`.
- `Latest_1_11_20/Senseanalysis5.R`: 27-factor experimental variant.
- `Latest_1_11_20/Senseanalysis6.R`: 21-factor experimental variant.
- `Latest_1_11_20/Senseanalysis7.R`: 24-factor experimental variant.
- `Co_inertia_3_12/Co_inertia3_12.R`: 27-factor experimental variant.
- `new/Senseanalysis4.R`: combined co-inertia and univariate exploration.

## Sobol archive (original R scripts now published in [`legacy/sobol/`](../legacy/sobol/)): `Sobol_3_18.zip`

- `Sobol.R`: four factor ranges, `parameterSets(..., method = "sobol")`, and `sobolSalt` with multiple crop/SOC-related model responses; 200-sample variant.
- `Sobol2/Sobol2.R`: similar four-factor study with soil carbon response; 300-sample variant.

## Scientific provenance / caveats

The peer-reviewed paper describes co-inertia analysis of **25 inputs and 14 model outputs** plus Sobol sensitivity of initial/stable SOC and management variables. Uploaded archival code contains multiple historical parameter counts, and the original exported datasets and exact code-to-figure crosswalk are not yet verified. No individual variant is labelled the definitive publication analysis.

Several archival scripts contain fixed `C:/DSSAT47` and `D:/ISmalia_DSSAT` paths and directly **overwrite genotype, soil, experiment and batch files**. They must be run only on isolated research copies with an independent backup. The scientific statements from these scripts are preserved in `legacy/`, preceded only by a safety header and a `stop()` call. They should not be run without deliberately removing that guard after preparing isolated input files. Public availability does not imply reproduction or a verified production package.

## New code

- `R/sensitivity_helpers.R` provides **generic** co-inertia and Sobol wrappers matching the original methods' analytical structure, not a reimplementation of all model runs.
- `examples/synthetic_analysis.R` uses synthetic values to illustrate the procedure and cannot verify the paper's numerical findings.

See [the source-to-method crosswalk](METHODS_SOURCE_MAP.md) for individual paths, sample sizes, and the source archive guide.

## Planned validation

1. Confirm exact paper-specific parameter design and input-output schema against original saved results.
2. **Completed in part:** retain guarded archival copies in `legacy/`; next, convert them to configurable, isolated runs after path and publication-rights review.
3. Move model execution into a sandbox/configurable adapter and add run provenance.
4. Compare outputs to published tables/figures before claiming independent end-to-end reproduction.
