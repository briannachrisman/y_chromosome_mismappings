#!/bin/bash
#SBATCH --job-name=plot_pileup_pvals
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/plot_pileup_pvals.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/plot_pileup_pvals.err
#SBATCH --time=00:20:00
#SBATCH --mem=15GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/plot_pileup_pvals.sh

module load py-numpy/1.14.3_py36
module load py-scipy/1.1.0_py36

python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/plot_pileup_pvals.py \
/scratch/groups/dpwall/personal/briannac/unmapped_reads/results/pileups 21 proper 

python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/plot_pileup_pvals.py \
/scratch/groups/dpwall/personal/briannac/unmapped_reads/results/pileups 21 improper 
