#!/bin/bash

# seeds=( 1 2 3 4 5 6 7 8 9 10 )
seeds=($(seq 1 1 20))
dataIdx=($(seq 1 1 25))

# Quick methods run in series
for i in "${dataIdx[@]}"; do
    sbatch R/jobR.sh "R/runAndSave.R --method=rawLasso --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=clrLasso --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=rawRF --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=clrRF --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=rawXGB --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=clrXGB --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=codaboostA0.0SE --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=codaboostB0.0SE --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=codaboostA1.0SE --seed=all --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=codaboostB1.0SE --seed=all --dataIdx=$i"
done

for i in "${dataIdx[@]}"; do
for s in "${seeds[@]}"; do
    sbatch R/jobR.sh "R/runAndSave.R --method=PRA --seed=$s --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=codalasso --seed=$s --dataIdx=$i"
#    sbatch R/jobR.sh "R/runAndSave.R --method=deepcoda --seed=$s --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=deepcodaSE --seed=$s --dataIdx=$i"
done
done

# Comment this line out to execute 'slow' runs as well 
# (beware - hundreds of jobs many of which take multiple days to run)
exit 1

# Slow methods run in parallel
for i in "${dataIdx[@]}"; do
for s in "${seeds[@]}"; do
    sbatch R/jobR.sh "R/runAndSave.R --method=amalgamCLR --seed=$s --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=amalgamSLR --seed=$s --dataIdx=$i"
    sbatch R/jobR.sh "R/runAndSave.R --method=selbal --seed=$s --dataIdx=$i"

done
done

