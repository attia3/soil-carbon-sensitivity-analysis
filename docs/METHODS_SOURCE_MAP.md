# Methods and source provenance

This repository implements reusable methods from Attia et al. (2021), *Field Crops Research* **260**, 107981. [DOI](https://doi.org/10.1016/j.fcr.2020.107981).

## Selection from the original R scripts

After reviewing six co-inertia and two Sobol variants in the research archives, we retained the **specific factor ranges and response definitions** from:

| Selected original | Original archive location | Why selected | Current R modules |
| --- | --- | --- | --- |
| `Co_inertia1.R` | `Co_interia_19_12_22/Latest_1_11_20/` | 26 inputs including SAOC/SASC model carbon-pool settings across profile depths, 1,500 LHS runs, 14 responses | [Study inputs](../R/maize_study_parameters.R), [co-inertia](../R/co_inertia_analysis.R) |
| `Sobol.R` | `Sobol_3_18/` | 4 soil carbon and management factors, 200-sample experimental variant, multivariate SOC/crop response loop | [Study inputs](../R/maize_study_parameters.R), [Sobol](../R/sobol_soc_analysis.R), [SOC response metrics](../R/soc_response_metrics.R) |

Other uploaded variants were inspected but **not duplicated** in the current working `R/` directory: `Co_inertia3_12.R` (27 design factors), `Senseanalysis5.R` (27), `Senseanalysis6.R` (21), `Senseanalysis7.R` (24), `Senseanalysis4.R` (23), and `Sobol2.R` (four-factor 300-sample variant). These contain alternative exploratory configurations rather than independently confirmed final figure-generating implementations.

For scientific traceability, the original scripts are retained in **Git commit history**, notably [the source archive commit](https://github.com/attia3/soil-carbon-sensitivity-analysis/commit/eafab135c919988df0f8ddf87bf3aa51e34d238d); see [SHA-256 provenance](SOURCE_PROVENANCE.md) to compare with the uploaded ZIPs. Current R files are professional refactorings, **not verbatim copies**.

## Co-inertia analysis from the selected source

`Co_inertia1.R` generated an improved Latin hypercube sample of **1,500 × 26** using `lhs::improvedLHS(..., dup=5)`. The source factor variables:

- Cultivar/ecotype: `P1`, `P5`, `G2`, `G3`, `PHINT`, `GDDE`, `DSGFT`, `RUE`, `KCAN`.
- Soil surface/hydrology: `SLU1`, `SLDR`, `SLPF`, `SLLL.30`, `SDUL.30`, `SSAT.30`, `SBDM.30`, `SLLL.60`, `SDUL.60`, `SSAT.60`, `SBDM.60`.
- Carbon pool settings: `SAOC.30`, `SASC.30`, `SAOC.60`, `SASC.60`, `SAOC.90`, `SASC.90`.

The **14 source-derived outputs**, retained as labels, were:
`Emer`, `Anth`, `Mat`, `GY`, `Straw`, `Nleach`, `sN`, `MLAI`, `TsC`, `Transp`, `sEvap`, `sWater`, `Nup`, `Drin`.

The original scripts coupled PCA on input/output tables with `ade4::coinertia`. The modernized analysis explicitly matches `run_id` and rejects missing, non-finite, or mismatched observations rather than silently mixing input and output rows.

**Important discrepancy:** The published *Field Crops Research* article refers to **25 input parameters and 14 output variables**. The selected uploaded source variant has **26 sampled factors**. We do **not** label that variant the exact final version used for the published figures. It is a documented study-derived exploratory configuration.

## SOC Sobol analysis from the selected source

The original `Sobol.R` factor ranges were:

| Source factor | Minimum | Maximum | File operation / inferred role |
| --- | ---: | ---: | --- |
| `v1` | 0.20 | 0.60 | carbon-related experiment setting |
| `v2` | 0.20 | 0.70 | second carbon-related experiment setting |
| `v3` | 0 | 5,000 | crop-residue input |
| `v4` | 0 | 10,000 | compost-amendment input |

Units and exact meanings should be checked against the original model experiment template before using these numerical ranges in new applications.

The source loop named five analysis targets: `GY_vec`, `mean_DMPEM_all`, `mean_NMNC_all`, `mean_SCS20D_all`, and `mean_CO2EC_all`. The script obtained soil carbon and nitrogen pool values from `SOMLITC.OUT` and `SoilNi.OUT`, including `SOCD`, `SC%20D`, `S1CTD`, `S1C0D`, `S2CTD`, `LC0D`, `LCTD`, `S3CTD`, `NLCC`, `NMNC`, `NNMNC`. The new `soc_response_metrics.R` exposes those pool definitions and day-of-year 230 sampling.

**Statistical change:** The archival Sobol code built its `X2` design by permuting rows of `X1`; the refactoring draws two independent factor matrices for the Sobol/Saltelli estimator. This is a methodological correction and must not be claimed to reproduce the old sensitivity numbers exactly.

## Workflow for a scientifically validated replication

1. Identify which archived source variant and model input file were used for each publication figure.
2. Record exact factor ranges, labels, units and model version, then reconstruct the parameter designs (including any saved seeds).
3. Execute all model runs in dedicated isolated experiment directories; never edit installed model definitions as part of a sensitivity run.
4. Capture model outputs, simulation failures, and machine-readable run metadata.
5. Match input/output tables by stable run IDs. Check the expected 25/14 published dimensions against the source data.
6. Run PCA/co-inertia and first/total Sobol indices; compare numerically to published figures/tables.
7. Document any remaining methodological differences transparently.

The modules under `R/` are **usable analysis components**, not a one-command recreation of the entire article or a carbon-crediting implementation.
