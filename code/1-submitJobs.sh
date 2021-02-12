#!/bin/bash

# seeds=( 1 2 3 4 5 6 7 8 9 10 )
seeds=($(seq 1 1 20))
dataIdx=($(seq 1 1 25))

# Quick methods run in series
for i in "${dataIdx[@]}"; do
    sbatch code/jobR.sh "code/runAndSave.R --method=rawLasso --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=clrLasso --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=rawRF --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=clrRF --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=rawXGB --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=clrXGB --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=codaboostA0.0SE --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=codaboostB0.0SE --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=codaboostA1.0SE --seed=all --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=codaboostB1.0SE --seed=all --dataIdx=$i"
done

# Slow methods run in parallel
for i in "${dataIdx[@]}"; do
for s in "${seeds[@]}"; do
    sbatch code/jobR.sh "code/runAndSave.R --method=PRA --seed=$s --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=codalasso --seed=$s --dataIdx=$i"
#    sbatch code/jobR.sh "code/runAndSave.R --method=deepcoda --seed=$s --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=deepcodaSE --seed=$s --dataIdx=$i"
done
done

for i in "${dataIdx[@]}"; do
for s in "${seeds[@]}"; do
    sbatch code/jobR.sh "code/runAndSave.R --method=amalgamCLR --seed=$s --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=amalgamSLR --seed=$s --dataIdx=$i"
    sbatch code/jobR.sh "code/runAndSave.R --method=selbal --seed=$s --dataIdx=$i"

done
done

