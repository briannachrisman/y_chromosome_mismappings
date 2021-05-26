#!/bin/sh
#SBATCH --job-name=move_from_oak_to_scratch
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/move_from_oak_to_scratch.out
#SBATCH --error=/scratch/users/briannac/logs/move_from_oak_to_scratch.err
#SBATCH --time=40:00:00
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/move_from_oak_to_scratch.sh

mv $MY_HOME/y_chromosome_mismappings/results/coverages/all/coverages.all.*.tsv.gz  /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/concat/all