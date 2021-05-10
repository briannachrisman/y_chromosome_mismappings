#!/bin/sh
#SBATCH --job-name=sample_coverages_header
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/sample_coverages_header.out
#SBATCH --error=/scratch/users/briannac/logs/sample_coverages_header.err
#SBATCH --time=5:00:00
#SBATCH --mem=200MB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/sample_coverages_header.sh



intermediate_dir=$MY_HOME/y_chromosome_mismappings/intermediate_files/coverages

cd $SCRATCH/tmp
SAMPLE=02C11467
echo $SAMPLE 
        
samtools view s3://ihart-hg38/cram/$SAMPLE.final.cram -H | grep '@SQ' | cut -f1,2,3 > $intermediate_dir/chrom_lengths.tsv
