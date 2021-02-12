# codacore

This repo contains the code for reproducing the results from our paper [Learning Sparse Log-Ratios For High-Throughput Sequencing Data"](add_arxiv_link).

If you are simply looking to use CoDaCoRe on your own dataset (or if you just want to download CoDaCoRe for any other reason), you should go directly to [py-codacore](https://github.com/egr95/py-codacore) (for python users) or [R-codacore](https://github.com/egr95/R-codacore) (for R users). 

## Reproducibility:

Note that this repo is just a snapshot of the code we used for the paper. It is kept for reproducibility, but it is not updated and it is not the cleanest code. To reproduce our analyses and replicate our figures and tables, execute the numbered scripts in the code directory. Note that these require access to a HPC cluster with Slurm, and many of the runs (particularly those using selbal on large datasets) will take up to a week to run. The entire code will run in ~1 week if executed fully in parallel. The source data must be downloaded separately (as per ```in/readme.txt```), and a conda environment must be set up prior (using ```conda env create -f environment.yml```). Any questions, do not hesitate to contact <eg2912@columbia.edu>.

