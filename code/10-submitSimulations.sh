#!/bin/bash

# seeds=( 1 2 3 4 5 6 7 8 9 10 )
seeds=($(seq 1 1 10))
seeds=( 0 )
n=( 1000 )
n=1000
ps=( 100 300 1000 3000 10000 )
ks=( 1 2 4 8 16 )

# Quick methods run in series
for s in "${seeds[@]}"; do
for p in "${ps[@]}"; do
for k in "${ks[@]}"; do
    sbatch R/jobR.sh "R/runSimulations.R --method=codacoreB1.0 --gen=B --n=$n --p=$p --k=$k --seed=$s"
    sbatch R/jobR.sh "R/runSimulations.R --method=selbal --gen=B --n=$n --p=$p --k=$k --seed=$s"
    sbatch R/jobR.sh "R/runSimulations.R --method=codalasso --gen=B --n=$n --p=$p --k=$k --seed=$s"
    sbatch R/jobR.sh "R/runSimulations.R --method=codacoreA1.0 --gen=A --n=$n --p=$p --k=$k --seed=$s"
    sbatch R/jobR.sh "R/runSimulations.R --method=amalgam --gen=A --n=$n --p=$p --k=$k --seed=$s"
done
done
done

