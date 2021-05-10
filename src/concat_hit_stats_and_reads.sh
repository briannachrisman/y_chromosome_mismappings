#!/bin/bash
#SBATCH --job-name=concat_hit_stats_and_reads
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/concat_hit_stats_and_reads.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/concat_hit_stats_and_reads.err
#SBATCH --time=40:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/concat_hit_stats_and_reads.sh

cd /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/hits_stats
\rm all.AS_median.txt
\rm all.MAPQ_median.txt
\rm all.mates.txt
\rm all.flags.txt
\rm all.depths.txt

paste *.AS_median.txt > all.AS_median.txt
paste *.MAPQ_median.txt > all.MAPQ_median.txt
paste *.mates.txt > all.mates.txt
paste *.flags.txt > all.flags.txt
paste *.depths.txt > all.depths.txt
