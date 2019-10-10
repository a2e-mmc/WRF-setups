# WRF-models
This repository is an archive of WRF simulations successfully run within the A2e
MMC project. These have been tested with a2e-mmc version of WRF (https://github.com/a2e-mmc/WRF),
which tracks the NCAR WRF development. 

Running `setup.sh`, will automatically download the initial/boundary conditions
from the NCAR Research Data Archive (RDA), and then run preprocessing utilities
`geogrid`, `ungrib`, and `metgrid`.
