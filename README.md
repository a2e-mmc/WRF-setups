# WRF-setups
This repository is an archive of WRF simulations successfully run within the A2e
MMC project. These have been tested with a2e-mmc version of WRF
(https://github.com/a2e-mmc/WRF), which tracks the NCAR WRF development branch. 

For information on how to run the WRF Setup scripts, see `templates/README.md`.

## Requirements for Archives
Each archived case will contain at least the following information:
- WRF and WPS namelists (namelist.input and namelist.wps, respectively)
- Initial and boundary condition information

  *and/or* 
- A WRF setup script that will allow for automatic download of the IC/BC data
- tslist file (if applicable)
- Any auxiliary input/output information (e.g., cell perturbation files,
  alternate land use data, etc.)
- Information on where to download any relevant observations

