#!/bin/bash
#SBATCH --job-name=make_batch1_microbe_and_alt_hap_counts
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/make_batch1_microbe_and_alt_hap_counts.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/make_batch1_microbe_and_alt_hap_counts.err
#SBATCH --time=5:00:00
#SBATCH --mem=100GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu


### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/make_batch1_microbe_and_alt_hap_counts.sh

module load py-numpy/1.14.3_py36
module load py-scipy/1.1.0_py36


bam_dir=/scratch/groups/dpwall/personal/chloehe/unmapped_reads/bam/batch_00514
python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/make_batch1_microbe_and_alt_hap_counts.py $bam_dir

echo "done with" $bam_dir

bam_dir=/scratch/users/chloehe/unmapped_reads/bam/batch_00009
python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/make_batch1_microbe_and_alt_hap_counts.py $bam_dir

echo "done with" $bam_dir

bam_dir=/scratch/users/chloehe/unmapped_reads/bam/batch_00010
python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/make_batch1_microbe_and_alt_hap_counts.py $bam_dir

echo "done with" $bam_dir

bam_dir=/scratch/users/chloehe/unmapped_reads/bam/batch_01013
python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/make_batch1_microbe_and_alt_hap_counts.py $bam_dir
