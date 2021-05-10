#!/bin/bash
#SBATCH --job-name=coverage_GWAS_alt
#SBATCH --partition=bigmem
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/coverage_GWAS_alt.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/coverage_GWAS_alt.err
#SBATCH --time=20:00:00
#SBATCH --mem=500GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/coverage_GWAS_alt.sh
module load py-numpy/1.18.1_py36
module load parallel 
parallel --citation

export chrom=ALT
export bed_file=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/alt_chroms.bed
export pileup_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/tsv_files
export normalize=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/normalize_pileups.py
export pvals=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/coverage_sex_pvals.py

fig_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/figs

samples=($(cut -f1 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_children_ihart.csv ))

cd /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams

generate_pileups(){
    sample_idx=$1
    file=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram
    echo running ${sample_idx} on chr $chrom
    
    prefix=${pileup_dir}/${chrom}.${sample_idx}
    hg38=/oak/stanford/groups/dpwall/users/briannac/_old_unmapped_reads/data/ref_genomes/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa
    
    # If file already exists, skip.
    if [[ $(wc -l <${prefix}.norm) -ge 40000000 ]]
    then
        echo ${prefix} already exists
    else
    
        ################### Properly paired pileups.  ###################
        samtools view -f 0x2 -F 0x400 -F 0x100 -F 0x200 -L ${bed_file} $file -b \
        | samtools mpileup -aa  -A -f ${hg38}  -   | \
        awk -vsample="${sample_idx}" 'BEGIN{print sample};{print $4}'  | tail -n 129060516  > ${prefix}.proper.txt    


        ################### Improperly paired pileups.  ###################
        samtools view -F 0x2 -F 0x8 -F 0x400 -F 0x100 -F 0x200 -L ${bed_file} $file -b  \
        | samtools mpileup -aa -A -f ${hg38}  - | \
        awk -vsample="${sample_idx}" 'BEGIN{print sample};{print $4}' | tail -n  129060516 > ${prefix}.improper.txt


        ################### Unmapped paired pileups.  ###################
        samtools view  -f 0x8 -F 0x400 -F 0x100 -F 0x200 -L ${bed_file} $file -b  \
        | samtools mpileup -aa  -A -f ${hg38} - | \
        awk -vsample="${sample_idx}" 'BEGIN{print sample};{print $4}' | tail -n  129060516 > ${prefix}.unmapped.txt

        python3 -u $normalize ${prefix}.
    fi
}

export -f generate_pileups
parallel -j 16 generate_pileups ::: ${samples[@]}

echo Concatenate
for pileup_type in proper unmapped improper; do
    echo Concatening ${pileup_type}
    paste ${pileup_dir}/${chrom}.${pileup_type}.txt > ${pileup_dir}/${chrom}.${pileup_type}.tsv
    #\rm ${pileup_dir}/${chrom}.${pileup_type}.txt*
done

echo Concatening normed
paste ${pileup_dir}/${chrom}.*.norm > ${pileup_dir}/${chrom}.norm.tsv

echo Computing P values
python3 -u -W ignore $pvals ${pileup_dir}/${chrom}.norm ihart
    
echo Plotting P values ${pileup_type}
python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/plot_manhattan_and_pdist.py \
${pileup_dir}/${chrom}.norm.pvals.tsv ${fig_dir}/${chrom}.norm ihart

