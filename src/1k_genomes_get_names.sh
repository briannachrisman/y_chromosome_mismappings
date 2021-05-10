#!/bin/bash
#SBATCH --job-name=plot_pileup_pvals
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/plot_pileup_pvals.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/plot_pileup_pvals.err
#SBATCH --time=48:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/plot_pileup_pvals.sh

grep "[.]mapped[.].*[.]bam"  /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/20130502.phase3.low_coverage.alignment.index > \
/scratch/groups/dpwall/personal/briannac/unmapped_reads/data/20130502.phase3.low_coverage.alignment.mapped.index

samtools view ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase3/data/HG00099/alignment/HG00099.mapped.ILLUMINA.bwa.GBR.low_coverage.20130415.bam -h | head -n 1000

while read idx _ ; do
  echo $idx
  samtools view $idx | head -n 5
done <  /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/1kg_hg38_ids.txt

