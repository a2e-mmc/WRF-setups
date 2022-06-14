This case uses the ERA5 Reanalysis data that is identical to the mesoscale setup. Please follow the mesoscale workflow to download the reanalysis and run the WRF Preprocessing System.

For completeness, the namelist.wps is included, as are the scripts to download the ERA5 reanalysis in the 'data_download_tools' directory.

To run the microscale case, use the appropriate namelist files in the apppropriate order:
namelist.input.MESOSCALE_SPINUP < spins up mesoscale simulation
namelist.input.MESOSCALE_SPINUP_2 < finishes spinning up mesooscale, spins up coarse LES domains as well Ends at 2010-05-15_2300UTC.
namelist.input.MICROSCALE_SPINUP < spins up domain 6, the LES domain of interest, using cell perturbationn method.
This step requires a few restarts, expected throughout is 24 minutes model time / 24 hour wall clock on 360 processors (on LLNL's Quartz HPC system).

namelist.input.MICROSCALE_RUN < Outputs data through all output streams at designated frequency. Expected throughput is 15 minutes per 24 hour wall clock on 360 processors (on LLNL's Quartz HPC system).
