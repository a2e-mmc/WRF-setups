#!/bin/bash
#PBS -N WRFSIMNAME
#PBS -A nsap0003
#PBS -l walltime=06:00:00
#PBS -q economy
#PBS -j oe
#PBS -m abe
#PBS -M hawbecke@ucar.edu
### Select 2 nodes with 36 CPUs each for a total of 72 MPI processes
#PBS -l select=4:ncpus=36:mpiprocs=36

date_start=`date`
echo $date_start
mpiexec_mpt ./wrf.exe
date_end=`date`
echo $date_end
