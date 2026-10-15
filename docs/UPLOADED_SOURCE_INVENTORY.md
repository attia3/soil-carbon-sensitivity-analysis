# Inventory of research R scripts reviewed

Two research archives were reviewed before consolidating the sensitivity-analysis workflows into a professional `R/` directory.

## Co-inertia source family

| Archived R script | Original experimental design | Decision |
| --- | --- | --- |
| `Latest_1_11_20/Co_inertia1.R` | 1,500 × 26 improved LHS, original source includes explicit SAOC/SASC model C pools | **Selected** for transparent factor ranges and 14 response labels |
| `Co_inertia_3_12/Co_inertia3_12.R` | 1,500 × 27 | Not selected: exploratory alternative |
| `Latest_1_11_20/Senseanalysis5.R` | 1,500 × 27 | Not selected: exploratory alternative |
| `Latest_1_11_20/Senseanalysis6.R` | 500 × 21 | Not selected: shorter exploratory variant |
| `Latest_1_11_20/Senseanalysis7.R` | 500 × 24 | Not selected: shorter exploratory variant |
| `new/Senseanalysis4.R` | 1,500 × 23; additional 2,000 × 23 experiment | Not selected: combines exploratory co-inertia/Sobol–Owen methods |

## Sobol source family

| Archived R script | Original experimental design | Decision |
| --- | --- | --- |
| `Sobol_3_18/Sobol.R` | Four factors, 200 base samples, multiple crop and SOC responses | **Selected** as source for factor settings and the five response labels |
| `Sobol_3_18/Sobol2/Sobol2.R` | Four factors, 300 base samples, narrower SOC response | Not selected: exploratory alternative |

The retained methods have been refactored into [`R/maize_study_parameters.R`](../R/maize_study_parameters.R), [`R/co_inertia_analysis.R`](../R/co_inertia_analysis.R), [`R/sobol_soc_analysis.R`](../R/sobol_soc_analysis.R), and [`R/soc_response_metrics.R`](../R/soc_response_metrics.R), supported by generic sampling and statistical functions already in `R/`.

The source versions previously included in Git are still retrievable through [repository history](https://github.com/attia3/soil-carbon-sensitivity-analysis/commit/eafab135c919988df0f8ddf87bf3aa51e34d238d). See [SOURCE_PROVENANCE.md](SOURCE_PROVENANCE.md) for original SHA-256 checksums.

**Scientific caution:** These are historical script experiments; the published paper describes 25 inputs and 14 outputs. Version selection alone does not verify which source generated the journal figures. Model-specific execution and full numerical replication require additional licensed inputs, calibration files and independent validation.
