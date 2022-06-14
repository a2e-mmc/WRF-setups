# WRF-setups
This repository is an archive of WRF simulations successfully run within the A2e
MMC project. These have been tested with a2e-mmc version of WRF (https://github.com/a2e-mmc/WRF),
which tracks the NCAR WRF development branch. 

For information on how to run the WRF Setup scripts, see `templates/README.md`.

## Requirements for Archives
Each archived case will contain at least the following information:
- WRF and WPS namelists (namelist.input and namelist.wps, respectively)
- Initial and boundary condition information

  *and/or* 
- a WRF setup script that will allow for automatic download of the IC/BC data
- tslist file (if applicable)
- any auxiliary input/output information (e.g., cell perturbation files, alternate land use data, etc.)
- Information on where to download any relevant observations

## Archived cases
- `SWiFT_20131108_GFS` - Reference simulation of the SWiFT diurnal cycle from
  2013-11-08 to 09, used in the coupling comparison study. 48 hrs were simulated
  with 12 hours of spinup, using the GFS reanalysis dataset.
- `SWiFT_20131108_PertMethodsGroup` - Simulations of idealized convective,
  neutral, and stable conditions extracted from the SWiFT canonical day between
  2013-11-08 to 09, used to study different perturbation methods for turbulent
  inflow generation.
  Subdirectories contain the input_sounding, namelist, tslist, and output-control
  file (which reduces the number of variables that are stored in the wrfout_d0*
  files).
  - convective: 1800-2000 UTC, specified heat flux of 175 W/m^2
- `FINO_20100512` contains the WRF setup script and templates for the offshore
FINO simulations for the 13 day period of interest.

