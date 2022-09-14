In order to use the bathymetry data for the depth-dependent sea surface roughness calculation, you
must first download and unpack the bathymetry data [from the DAP]
(https://a2e.energy.gov/data/mmc/bathymetry.z01.c0). 

The directory within the tar file is named `topobath_30s/` and will need to be placed in, or linked from, your `geog` data directory that is pointed to in the WPS namelist. This allows WPS to see the data and read it during geogrid.exe.

Next, update the `namelist.wps` file so that the geog data that is being used contains the `topobath_30s` data (see `namelist.wps_template` for an example).

Finally, update the `GEOGRID.TBL` file with the included file. This tells geogrid.exe how to interpolate and read the new bathymetry data.

Once this has been done, run geogrid.exe and make sure that the new variable, BATHYMETRY, is available in each of the domains that you want to use for the depth-dependent roughness formulation. If the variable exists, the MMC version of WRF will be able to ingest BATHYMETRY and will convert it to WATER_DEPTH during real.exe. This variable is added as standard output, if available.
