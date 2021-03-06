#!/bin/sh
#
#SBATCH -A stats # The account name for the job.
#SBATCH --job-name=topSecret # The job name.
##SBATCH -c 4 # The number of cpu cores to use.
##SBATCH --exclusive # run on single node
#SBATCH --time=10:00:00 # The time the job will take to run.
##SBATCH --mem-per-cpu=16gb # The memory the job will use per cpu core.
##SBATCH --gres=gpu:1
##SBATCH -o log.log
##SBATCH --exclude=t118

conda activate r-codacore

sleep 1

date +%s
echo $1

echo IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII

# This tries to run our job up to 5 times, sleeping in between
# Addresses spurious (temporary) node failures due to ldpaths
for i in 1 2 3 4 5; do
echo $i
Rscript $1 && break || sleep 15;
touch mylog/$SLURM_JOBID
done

echo IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII

date +%s
