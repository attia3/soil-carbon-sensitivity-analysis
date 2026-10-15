# DSSAT Maize Calibration, SOC Sensitivity Analysis and Soil Carbon Dynamics

**Research code for DSSAT–CERES-Maize calibration**, with planned integration of the **co-inertia and Sobol global sensitivity analyses** associated with the published soil-carbon study in arid Mediterranean environments.

> **Repository status (important):** The publicly available files currently document maize cultivar calibration and related figures. The full co-inertia/Sobol analysis scripts from the paper are **not yet included**. This is not currently a complete, one-command replication package for the publication.

## Scientific reference

Attia, A., et al. (2021). *Sensitivity of the DSSAT model in simulating maize yield and soil carbon dynamics in arid Mediterranean climate: Effect of soil, genotype and crop management*. **Field Crops Research**, 260, 107981.

- DOI: https://doi.org/10.1016/j.fcr.2020.107981
- Scientific aims: evaluate DSSAT under arid sandy-soil conditions; evaluate sensitivity of crop and soil variables to soil, cultivar, and management inputs.
- Published analyses include co-inertia analysis of 14 model outputs and 25 soil/cultivar inputs, and Sobol variance-based analysis of initial/stable SOC, crop residue management, compost inputs, and simulated long-term SOC-related outputs.

**Do not infer** that those published co-inertia/Sobol computations can be rerun from the current repository files alone.

## Repository contents currently available

| Path | Contents |
| --- | --- |
| `dssat_cornCV_calib.R` | Research calibration workflow for maize cultivars, including parameter optimization against observations |
| `mediaforarticle.R` | Local DSSAT execution and observed-versus-simulated figure-generation workflow |
| `Corn_calibration.csv` | Cultivar/parameter starting values and calibration ranges |
| `OBS_Calib-Data_.csv` | Observed calibration dataset |
| `DSSAT-files/` | Auxiliary DSSAT-related project files |

The original scripts contain fixed Windows paths and assume local DSSAT model files and certain R packages. They are preserved as **historical research code** rather than presented as portable production software.

## Scientific workflow and relevance

```text
Field observations + DSSAT soil / cultivar / management inputs
    ↓
Calibrate model parameters and check simulated-versus-observed data
    ↓
(Published paper) co-inertia parameter/output screening
    ↓
(Published paper) Sobol variance-based sensitivity of SOC dynamics
    ↓
Interpret uncertainty drivers and site/management dependence
```

The last two analytical stages are **described in the paper**, but their source scripts must be added and checked before claiming reproducibility from this repository.

### Relevance to soil carbon quantification

The research demonstrates experience identifying **which model inputs and assumptions influence SOC stock, SOC turnover, soil CO₂ efflux, and crop productivity**. These methods can support model evaluation and targeted data-collection decisions. The publication is an agronomic model sensitivity study—not an approved SOC credit-estimation framework.

## Running the existing code

1. Install an appropriate DSSAT version and obtain experiment, soil, cultivar and weather inputs with the required rights.
2. Review the R scripts for DSSAT executable paths and required packages; the current paths reflect the original Windows workstation.
3. Check cultivar, ecotype, management and observational-data schemas before changing model inputs.
4. Make a separate working copy of genotype files: the legacy scripts may overwrite DSSAT cultivar/ecotype files.
5. Run on a small, independently checkable case before producing any figures or extending the analysis.

## Planned improvements

See [docs/ROADMAP.md](docs/ROADMAP.md) for integration of the original co-inertia and Sobol scripts, refactoring, test fixtures, dependency specifications, and reproducible research examples.

## Author, contribution and citation

Ahmed Attia. Cite the **Field Crops Research** paper for scientific claims and use commit-specific GitHub links when referring to code. A formal open-source license is not yet specified.
