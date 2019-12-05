# WRF-setups
This repository is an archive of WRF simulations successfully run within the A2e
MMC project. These have been tested with a2e-mmc version of WRF (https://github.com/a2e-mmc/WRF),
which tracks the NCAR WRF development. 

Running `setup.sh`, will automatically download the initial/boundary conditions
from the NCAR Research Data Archive (RDA), and then run preprocessing utilities
`geogrid`, `ungrib`, and `metgrid` for real WRF cases.

For more information on running `setup.sh`, see `templates/README`.


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
