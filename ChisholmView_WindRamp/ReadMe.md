# Introduction
This set-up is meant for simulating a wind farm consisting of 21 PSU-1.5 wind turbines in WRF-LES-GAD formulation using real atmospheric conditions. 
The latest WRF code can be found [here](https://github.com/a2e-mmc/WRF/tree/mmc_update_v4.3).

6 nested domains are used with LES model and turbines parameterized using a generalized actuator disk (GAD) formulation.
The GAD parameters are provided in `windspec.in` file.

# Recommended compilers and run settings
The WRF compilation and tests were done using the following dependencies on LLNL [quartz](https://hpc.llnl.gov/hardware/compute-platforms/quartz) cluster:
- intel/18.0.1
- mvapich2/2.2
- netcdf/4.4.1.1
- netcdf-fortran/4.4.4
- hdf5-parallel/1.8.18
- mkl/2020.0

For configuring WRF for compilation, option 15 was used. The test case was run on 360 CPUs (10 nodes with ppn = 36).

# Simulation instructions/sequence
- `WPS/script_to_wget_nam_data_pkj.pro` is the script used to download the NAM data used to create the metgrid files.
- `WPS/namelist.wps` is the file used to create the metgrid files from the NAM data.
- `WRF/namelist.input.step1_d01_d03_24hrs` is the namelist that can be used for `real.exe` to create wrfbdy etc. and also run the spin-up simulation for 24 hrs of real time.
- `WRF/namelist.input.step2_d01_d06_part01_1min` is the namelist to kick-start the simulation for internal domains with turbines in place.
- `WRF/namelist.input.step2_d01_d06_part02_5min` is the namelist to run the simulation for the all the 6 domains with turbines in the innermost domain.
- `WRF/windspec.in` is the file needed by GAD.
