#!/bin/sh
#SBATCH --job-name=move_coverages
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/move_coverages.out
#SBATCH --error=/scratch/users/briannac/logs/move_coverages.err
#SBATCH --time=20:00:00
#SBATCH --mem=20G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/move.sh


### Before running, do: python3.6 /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/get_unfinshed_chrom_coverages.py

ml parallel 
mv /scratch/users/briannac/y_chromosome_mismappings/intermediate_files/coverages/* /scratch/groups/dpwall/personal/briannac/y_chromosome_mismappings/intermediate_files/coverages -v