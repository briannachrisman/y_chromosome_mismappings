#!/bin/bash
#SBATCH --job-name=pileup_ref_pos
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/pileup_ref_pos.err
#SBATCH --time=5:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

# File at $MY_SCRATCH/unmapped_reads/pileups/src/pileup_ref_pos.sh

module load py-numpy/1.14.3_py36
module load py-scipy/1.1.0_py36
SAMPLE=$(cut -f1 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_ihart_dataset.csv | head -n 1 | tail -n 1)
FILE=$(cut -f2 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_ihart_dataset.csv | head -n 1 | tail -n 1)
hg38=/oak/stanford/groups/dpwall/users/briannac/_old_unmapped_reads/data/ref_genomes/hg38/hg38.fa

samtools view $FILE -h | head -n 100000 | samtools view -b |  \
samtools mpileup  -a -a -A -f ${hg38} - | awk -vsample="${SAMPLE}" '{print $1,$2}'  > /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/pileup_references.tsv

#done