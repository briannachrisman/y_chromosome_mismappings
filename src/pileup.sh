#!/bin/bash
#SBATCH --job-name=pileup
#SBATCH --partition=dpwall
#SBATCH --array=21%10
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/pileup_%a.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/pileup_%a.err
#SBATCH --time=10:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/pileup.sh

module load py-numpy/1.14.3_py36
module load py-scipy/1.1.0_py36
module load parallel 
parallel --citation

export chrom=$SLURM_ARRAY_TASK_ID
export pileup_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/issues/p_values/clrbalanced_ihart/clr/tsv_files
fig_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/issues/p_values/clr/figs
normalize=/scratch/groups/dpwall/personal/briannac/unmapped_reads/src/normalize_pileup_clr.py
export quality=0

samples=($(cut -f1 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_ihart_dataset.csv ))
files=($(cut -f2 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_ihart_dataset.csv ))

generate_pileups(){
    sample_idx=$1
    file=$2
    echo running ${sample_idx} on chr $chrom, file at $file
    prefix=${pileup_dir}/${chrom}.q${quality}.${sample_idx}
    hg38=/oak/stanford/groups/dpwall/users/briannac/_old_unmapped_reads/data/ref_genomes/hg38/hg38.fa
    ################### Properly paired pileups.  ###################
    samtools view -q $quality -f 0x2 -F 0x400 -F 0x100 -F 0x200 $file -b chr${chrom}\
    | samtools mpileup  -a -A -f ${hg38} -   |\
    awk -vsample="${sample_idx}" 'BEGIN{print sample};{print $4}'  > ${prefix}.proper.txt    
    python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/normalize_pileup.py ${prefix}.proper.txt 
    
    
    ################### Improperly paired pileups.  ###################
    samtools view -q $quality -F 0x2 -F 0x8 -F 0x400 -F 0x100 -F 0x200 $file -b chr${chrom} \
    | samtools mpileup  -a -A -f ${hg38} - |\
    awk -vsample="${sample_idx}" 'BEGIN{print sample};{print $4}'   > ${prefix}.improper.txt
    python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/normalize_pileup.py ${prefix}.improper.txt 
    
    
    ################### Unmapped paired pileups.  ###################
    samtools view -q $quality -f 0x8 -F 0x400 -F 0x100 -F 0x200 $file -b chr${chrom} \
    | samtools mpileup  -a -A -f ${hg38} - |\
    awk -vsample="${sample_idx}" 'BEGIN{print sample};{print $4}'  > ${prefix}.unmapped.txt
    python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/normalize_pileup.py ${prefix}.unmapped.txt 
}

export -f generate_pileups
parallel -j 8 generate_pileups ::: ${samples[@]} :::+ ${files[@]}

for pileup_type in proper unmapped improper; do
    echo Concatening ${pileup_type}
    paste ${pileup_dir}/${chrom}.q${quality}*.${pileup_type}.txt.norm > ${pileup_dir}/${chrom}.q${quality}.${pileup_type}.tsv
    echo Computing P values ${pileup_type}
    python3 -u -W ignore /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/pileup_pvals.py ${pileup_dir}/${chrom}.q${quality}.${pileup_type} ihart
    echo Plotting P values ${pileup_type}
    python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/plot_pileup_pvals.py \
    ${pileup_dir}/${chrom}.q${quality}.${pileup_type}.pvals.tsv ${fig_dir}/${chrom}.q${quality}.${pileup_type} ihart
done


