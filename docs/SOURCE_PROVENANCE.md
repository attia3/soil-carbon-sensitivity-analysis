# Scientific source provenance

This repository's streamlined R implementations were derived from selected code in the **user-supplied R research archives**, not inferred from the publication title alone.

## Selected versions

| Selected archived source | Source ZIP path | Source SHA-256 | Selected content |
| --- | --- | --- | --- |
| `Co_inertia1.R` | `Co_interia_19_12_22/Latest_1_11_20/Co_inertia1.R` | `23ccc89505e2c772bf172edff2ba8e734403d746edf102f38e21701f5ba408ef` | 26 factor ranges, 14 output labels, 1,500-point LHS, co-inertia/PCA |
| `Sobol.R` | `Sobol_3_18/Sobol.R` | `4265e21e871a2bb53019d3576c8805c9dffc095eb5cfc917dcdb9b29f7e9f31f` | 4 factor ranges, 5 named responses, SOC/N data extraction, Sobol/Saltelli method |

The hashes apply to the **original ZIP bytes**, not the modernized R files. Those source scripts previously appeared in this repository as guarded snapshots in [commit eafab135](https://github.com/attia3/soil-carbon-sensitivity-analysis/commit/eafab135c919988df0f8ddf87bf3aa51e34d238d); the Git history provides audit access even though the redundant `legacy/` directory is no longer part of the current tree.

## What changed in the refactoring

- Replaced fixed `C:/DSSAT47` and `D:/ISmalia_DSSAT` paths with **explicit user-supplied simulator callbacks**.
- Extracted experimental factors and responses into named, checked data structures.
- Removed file operations that overwrote installed cultivar, ecotype, soil and experiment files.
- Matched paired simulation inputs/outputs by unique `run_id`, rejecting missing/failed simulations.
- Exposed model SOC pools and nitrogen metrics without representing those model pools as laboratory carbon fractions.
- Changed historical Sobol row-permuted X2 to an independently sampled second matrix; consequently **the new Sobol output is not numerically identical by definition** to the old estimator setup.

## Limits of traceability

The paper's co-inertia implementation is described as **25 inputs, 14 outputs**. The selected code variant contains **26 LHS factors**; other original scripts contain 21–27. The final publication-specific version and saved numerical outputs must be reconciled before claiming full paper replication. No original datasets or full DSSAT installation have been included here.

Reference: Attia et al. (2021), *Field Crops Research* 260, 107981. https://doi.org/10.1016/j.fcr.2020.107981
