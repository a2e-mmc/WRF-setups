#!/bin/sh
#SBATCH -J gad_2.3_chisolm
#SBATCH -N 10
#SBATCH --partition=quartz
#SBATCH -t 24:00:00
#SBATCH -A gsmisc
#SBATCH -p pbatch
#SBATCH --mail-type=ALL
#SBATCH --export=ALL

#Display job info
date
echo "Job id = $SLURM_JOBID"
hostname

export exec_name=$1
export exec_path=`which ${exec_name}`

#Run job
if (test ! -z "$exec_path" )
then
  echo "Found the executable ${exec_name} at: ${exec_path}"
  srun -n360 ${exec_name}
  echo 'Successfully done the simulation'
  exit 0
else
  echo "ERROR: ${exec_name} NOT Found!"
  echo "Exiting with ERRORS"
  exit 1
fi

