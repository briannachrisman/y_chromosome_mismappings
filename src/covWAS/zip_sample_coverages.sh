#!/bin/sh
#SBATCH --job-name=zip_sample_coverages
#SBATCH --partition=owners
#SBATCH --array=1
#SBATCH --output=/scratch/users/briannac/logs/zip_sample_coverages_%a.out
#SBATCH --error=/scratch/users/briannac/logs/zip_sample_coverages_%a.err
#SBATCH --time=1:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/zip_sample_coverages.sh

## SLURM_ARRAY_TASK_ID=1 ### CHANGE WHEN RUNNING BATCH!!!
ml parallel

cd /scratch/users/briannac/y_chromosome_mismappings/intermediate_files/coverages
N=$((SLURM_ARRAY_TASK_ID-1))
parallel -j 20 gzip -f -v ::: *0.*.txt  

