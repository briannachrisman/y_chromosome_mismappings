#!/bin/sh
#SBATCH --job-name=rename_with_correct_flags
#SBATCH --partition=owners
#SBATCH --array=397,569-627
#SBATCH --output=/scratch/users/briannac/logs/rename_with_correct_flags.out
#SBATCH --error=/scratch/users/briannac/logs/rename_with_correct_flags.err
#SBATCH --time=20:00
#SBATCH --mem=1G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/rename_with_correct_flags.sh

for I_TO_ADD in 0 1000 2000 3000 4000; do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $MY_HOME/general_data/samples_and_batches.tsv | tail -n 1 > $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE _; do
            cd /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages
            echo "running" $SAMPLE
            cd $SAMPLE
            for i in *unmapped* ; do
                mv $i ${i/unmapped/all} # Rename 'unmapped' as 'all'.
            done
            \rm *.proper*
    done < $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
done


