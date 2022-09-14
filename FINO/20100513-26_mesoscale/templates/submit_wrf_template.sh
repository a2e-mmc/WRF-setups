#!/bin/bash
#PBS -N WRFSIMNAME
#PBS -A nwsa0002
#PBS -l walltime=08:00:00
#PBS -q economy
#PBS -j oe
#PBS -m abe
#PBS -M hawbecke@ucar.edu
### Select 2 nodes with 36 CPUs each for a total of 72 MPI processes
#PBS -l select=10:ncpus=36:mpiprocs=36

date_start=`date`
echo $date_start
mpiexec_mpt ./wrf.exe
date_end=`date`
echo $date_end
