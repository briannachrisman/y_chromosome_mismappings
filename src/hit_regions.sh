#!/bin/bash
#SBATCH --job-name=hit_regions
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/hit_regions.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/hit_regions.err
#SBATCH --time=5:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/hit_regions.sh

module load py-numpy/1.18.1_py36

# Create "hits" data frame for chromsome.
for i in {10..22}
do
    echo chr$i
    python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/hit_regions.py chr$i
done

# Concatenate hits across all chromsomes.

cat /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/hits_locations_*.csv > /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/hits_locations.csv

cat /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/loci_locations_*.csv > /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/loci_locations.csv

cat /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/hits_stats_*.csv > /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/hits_stats.csv