#!/bin/bash

# Script to schedule the jobs for the (large) Best et al 2015 cancer mRNA data

seeds=($(seq 1 1 20))

# Quick methods run in series

for s in "${seeds[@]}"; do
    sbatch code/jobR.sh "code/runAndSave.R --method=rawLasso --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=clrLasso --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=rawRF --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=clrRF --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=rawXGB --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=clrXGB --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=codacoreA0.0SE --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=codacoreB0.0SE --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=codacoreA1.0SE --seed=$s --dataIdx=26"
    sbatch code/jobR.sh "code/runAndSave.R --method=codacoreB1.0SE --seed=$s --dataIdx=26"
done
