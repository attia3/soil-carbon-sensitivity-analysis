# Reproducibility and development roadmap

## Available now

- Selected research settings from `Co_inertia1.R` and `Sobol.R` in `R/maize_study_parameters.R`.
- Improved LHS, run-level simulation callbacks, paired data checks, PCA/co-inertia results, and loading plots in `R/co_inertia_analysis.R`.
- Independent Sobol factor sampling and response-specific sensitivity evaluation in `R/sobol_soc_analysis.R`.
- Source-derived SOC model-pool and nitrogen metrics from prepared annual outputs in `R/soc_response_metrics.R`.
- Generic `R/parameter_sampling.R` and `R/sensitivity_helpers.R`.
- Synthetic examples, input/metric tests and R syntax CI checks, none requiring licensed DSSAT software.
- Original research variant details, SHA-256 checksums and historical Git commit references in `docs/`.
- Refactored maize calibration (`R/dssat_cornCV_calib.R`) and paper figure preparation (`R/mediaforarticle.R`) with matched treatment IDs, a configurable simulator interface, and dependency-free validation of the historical weighted objective.

## Remaining work

1. **Reconcile final research methods**: the peer-reviewed article refers to 25 input variables and 14 outputs, while the selected exploratory archived script uses 26 factors.
2. **Verify source-to-figure mapping**: use saved model results to match original R source and paper figures/tables.
3. **Add a safe DSSAT maize simulation adapter**: duplicate calibrated experiment assets into disposable, versioned model-run workspaces; never write directly into installed model directories.
4. **Document units and interpretation**: validate all original factor units, especially the two carbon-related Sobol input settings and the lab/model-pool distinction.
5. **Test package-dependent analysis**: validate all ade4/lhs/sensitivity execution in a pinned R environment, including estimator versions and reproducible seeds.
6. **Cross-validate the original calculations**: report explained variance, co-inertia statistics, first/total Sobol effects and independent numerical agreement with published figures.
7. **Release a full example**: include representative, permission-cleared model input/output data and automated figure reproduction if rights allow.
8. **Document other model adapters**: generalize beyond DSSAT only after each engine's inputs, internal carbon pools and outputs have been independently checked.

The current code is scientific analysis infrastructure, **not** an approved carbon-market MRV or soil sampling system.
