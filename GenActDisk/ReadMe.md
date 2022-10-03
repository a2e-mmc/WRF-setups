# Introduction
This set-up is meant for simulating a single wind turbine in WRF-LES-GAD formulation. The latest WRF code can be found [here](https://github.com/a2e-mmc/WRF/tree/mmc_update_v4.3).

A single domain is used with LES model and turbines parameterized using a generalized actuator disk (GAD) formulation. The turbine modeled is the NREL 5-MW turbine. 
The uniform wind speed is provided in `input_sounding` file. The GAD parameters are provided in `windspec.in` file.

# Recommended compilers and run settings
The WRF compilation and tests were done using the following dependencies on LLNL [quartz](https://hpc.llnl.gov/hardware/compute-platforms/quartz) cluster:
- intel/18.0.1
- mvapich2/2.2
- netcdf/4.4.1.1
- netcdf-fortran/4.4.4
- hdf5-parallel/1.8.18
- mkl/2020.0

For configuring WRF for compilation, option 15 was used. The test case was run on 36 CPUs (1 node with ppn = 36).
