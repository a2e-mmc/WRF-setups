# WRF-models
This repository is an archive of WRF simulations successfully run within the A2e
MMC project.

Running `setup.sh`, will automatically download the initial/boundary conditions
from the NCAR Research Data Archive (RDA), and then run preprocessing utilities
`geogrid`, `ungrib`, and `metgrid`.

`SWiFT_20131108_PertMethodsGroup` contains the input_sounding, namelist, tslist,
and output-control file (which reduces the number of variables that are stored 
in the wrfout_d0* files) for the convective case. 

`FINO_20100512` contains the WRF setup script and templates for the offshore
FINO simulations for the 13 day period of interest.
