#!/bin/bash
#SBATCH --job-name=copy_crams
#SBATCH --partition=dpwall
#SBATCH --array=10,16,37,65,136%10
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/copy_crams_%a.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/copy_crams_%a.err
#SBATCH --time=00:30:00
#SBATCH --mem=100GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/copy_crams.sh

cd /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/crams
sample_idx=$(head -n $SLURM_ARRAY_TASK_ID /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_children_ihart.csv | tail -n 1 | cut -f1)
file=$(head -n $SLURM_ARRAY_TASK_ID /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_children_ihart.csv | tail -n 1 | cut -f2)

echo copying $sample_idx

if [ ! -f /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram ]; then
    echo "copying" $file
    aws s3 cp $file /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram
fi

if [ ! -f /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram.crai ]; then
    aws s3 cp $file.crai /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram.crai
fi



sample_idx=$(head -n $SLURM_ARRAY_TASK_ID /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_parents_ihart.csv | tail -n 1 | cut -f1)
file=$(head -n $SLURM_ARRAY_TASK_ID /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_parents_ihart.csv | tail -n 1 | cut -f2)

echo copying $sample_idx

if [ ! -f /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram ]; then
    echo "copying" $file
    aws s3 cp $file /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram
fi

if [ ! -f /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram.crai ]; then
    aws s3 cp $file.crai /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram.crai
fi
