# Scaled Wind Farm Technology (SWiFT) facility simulations

These simulations focus on the SWiFT diurnal cycle from 2013-11-08 to 09.

## Archived cases
- `20131108_GFS` - Reference simulation of the SWiFT diurnal cycle from
  2013-11-08 to 09, used in several coupling comparison studies. 48 hrs were
  simulated with 12 hours of spinup, using the GFS reanalysis dataset.
- `PerturbationsStudy` - Simulations of idealized convective, neutral, and
  stable conditions extracted from the SWiFT canonical day between
  2013-11-08 to 09, used to study different perturbation methods for turbulent
  inflow generation. Subdirectories contain the `input_sounding`,
  `namelist.input`, `tslist`, and output-control file (which reduces the number
of variables that are stored in the `wrfout_d0*` files).
  - convective: 1800-2000 UTC, specified heat flux of 175 W/m^2

