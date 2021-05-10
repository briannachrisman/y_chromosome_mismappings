#!/bin/bash
#SBATCH --job-name=pileup_genome_concat_and_pvals
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/pileup_genome_concat_and_pvals.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/pileup_genome_concat_and_pvals.err
#SBATCH --time=40:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/pileup_genome_concat_and_pvals.sh
module load py-numpy/1.14.3_py36
module load py-scipy/1.1.0_py36

export pileup_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/tsv_files
export normalize=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/normalize.py
export pvals=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/pvals.py
export quality=0

fig_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/figs
echo running $SAMPLE on genome, file at $FILE
prefix=${pileup_dir}/$contig.q${quality}.${SAMPLE}
hg38=/oak/stanford/groups/dpwall/users/briannac/_old_unmapped_reads/data/ref_genomes/hg38/hg38.fa

for pileup_type in proper unmapped improper; do
    echo Concatening ${pileup_type}
    paste ${pileup_dir}/q${quality}*.${pileup_type}.txt.norm > ${pileup_dir}/full.q${quality}.${pileup_type}.tsv
    
    echo Computing P values ${pileup_type}
    python3 -u -W ignore $pvals ${pileup_dir}/full.q${quality}.${pileup_type} ihart
    
    echo Plotting P values ${pileup_type}
    python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/plot_pileup_pvals.py \
    ${pileup_dir}/q${quality}.${pileup_type}.pvals.tsv ${fig_dir}/full.q${quality}.${pileup_type} ihart
done

#dfne