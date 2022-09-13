#!/bin/bash
#PBS -N #SIMNAME
#PBS -A nwsa0002
#PBS -l walltime=01:00:00
#PBS -q share  
#PBS -j oe
### Select 2 nodes with 36 CPUs each for a total of 72 MPI processes
#PBS -l select=1:ncpus=1:mpiprocs=1

date_start=`date`
echo $date_start
# Run geogrid
# Run ungrib
# Run metgrid
date_end=`date`
echo $date_end
