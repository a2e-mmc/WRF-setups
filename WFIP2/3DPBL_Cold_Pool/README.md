# MMC 3D PBL WFIP2 Cold Pool Case

Documented by: Tim Juliano (tjuliano@ucar.edu)

Documented on: 6/13/22

File in this directory:

 - `namelist.input`
    Namelist for two domain, high-resolution mesoscale simulation.

Forcing files are too large to host on GitHub.
Please [download from the DAP](https://a2e.energy.gov/data/wfip2.model/refcst.coldstart.icbc.02) 
the following files:

 - `wrfinput_d0*`
    Initial condition files from HRRR-WFIP2 model configuration.
 - `wrfbdy_d01`
    Lateral boundary condition file from HRRR-WFIP2 model configuration.

The `wrfinput_d0*` and `wrfbdy_d01` files should have a start date of `2017-01-14_12:00:00`.

Note: As of 6/13/22, the DOE DAP is having issues with large file downloads.
For the purposes of testing this workflow, you can also download the forcing files the [team Google Drive](https://drive.google.com/drive/folders/15rDka6cNUcc405d4YYmLRiaqTKHCslJY?usp=sharing).

