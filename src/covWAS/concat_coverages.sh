#!/bin/sh
#SBATCH --job-name=concat_coverages
#SBATCH --partition=owners
#SBATCH --array=1-1000
#SBATCH --output=/scratch/users/briannac/logs/concat_coverages_%a.out
#SBATCH --error=/scratch/users/briannac/logs/concat_coverages_%a.err
#SBATCH --time=1:00:00
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/concat_coverages.sh
SLURM_ARRAY_TASK_ID=1

for i in 0 1000 2000 3000; do
    N=$((SLURM_ARRAY_TASK_ID+i))
    N=$(printf "%04g" $N)
    echo "pasting..."
    
    for file in /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/*.unmapped.$N.txt; do
        sed '/[*]/d' -i $file
        echo 'cleaned up' $file
    done

    paste /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/*.unmapped.$N.txt > /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/covWAS/unmapped.$N.tsv
done