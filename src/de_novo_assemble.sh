#!/bin/bash
#SBATCH --job-name=hit_stats_and_reads
#SBATCH --partition=dpwall
#SBATCH --array=1-4%10
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/hit_stats_and_reads_%a.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/hit_stats_and_reads_%a.err
#SBATCH --time=5:00:00
#SBATCH --mem=50GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/hit_stats_and_reads.sh
module load py-numpy/1.18.1_py36
module load gatk/4.1.4.1
module load parallel 
ml biology; ml bwa

parallel --citation

SLURM_ARRAY_TASK_ID=1
sample_idx=$(cut -f1 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/parents_and_children.csv | head -n ${SLURM_ARRAY_TASK_ID} | tail -n 1 )
batch=$(cut -f3 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/parents_and_children.csv | head -n ${SLURM_ARRAY_TASK_ID} | tail -n 1 )

parent_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/hits_stats
file=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/data/crams/${sample_idx}.cram

echo $sample_idx

cd /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/hits_stats

# If file already exists, skip.
if [[ $(wc -l <${parent_dir}/${sample_idx}_assembly.fa) -ge 1 ]]
then
    ${parent_dir}/${sample_idx}
else
    #\rm ${parent_dir}/${sample_idx}*.fastq
    #\rm ${parent_dir}/${sample_idx}.tmp.bam
    #\rm ${parent_dir}/${sample_idx}.tmp.sam
    #\rm ${parent_dir}/${sample_idx}.ids.tmp.txt


    samtools view $file -H >  ${parent_dir}/${sample_idx}.tmp.sam
    echo $sample_idx > ${parent_dir}/${sample_idx}.AS_median.txt
    echo $sample_idx > ${parent_dir}/${sample_idx}.MAPQ_median.txt
    echo $sample_idx > ${parent_dir}/${sample_idx}.mates.txt
    echo $sample_idx > ${parent_dir}/${sample_idx}.depths.txt
    echo $sample_idx > ${parent_dir}/${sample_idx}.flags.txt

    echo $parent_dir/$sample_idx

    hg38=/oak/stanford/groups/dpwall/users/briannac/_old_unmapped_reads/data/ref_genomes/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa

    cd /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/hits_stats
    
    ######## Get rid of duplicate read ids. ########
    sort ${parent_dir}/${sample_idx}.ids.txt | uniq -u > ${parent_dir}/${sample_idx}.ids_sort.txt

    ######## Grep for read IDs in .cram file. Convert to fastq. ########
    echo "Filtering sam reads"
    gatk FilterSamReads --I=$file  --O=${sample_idx}.tmp.sam \
    --READ_LIST_FILE=${parent_dir}/${sample_idx}.ids_sort.txt --FILTER=includeReadList --REFERENCE_SEQUENCE=$hg38 
    samtools view -F 0x100 ${parent_dir}/${sample_idx}.tmp.sam -b | samtools sort -n | \
    samtools fastq -1 ${parent_dir}/${sample_idx}_r1.fastq -2 ${parent_dir}/${sample_idx}_r2.fastq -
    
    sed -i "s/@/@sex_associated_/"  ${parent_dir}/${sample_idx}_r1.fastq
    sed -i "s/@/@sex_associated_/"  ${parent_dir}/${sample_idx}_r2.fastq

    
    ################## Unmapped Reads ##################    
    echo "Dealing with R1 unmapped reads"
    
    unmapped_bam=s3://ihart-ms2/unmapped/$batch/${sample_idx}/${sample_idx}.final.paired.aln_all.bam
    
    # R1 for unmapped/* #   -f 0x40 -f 0x4

    samtools view $file -f 0x40 -f 0x4 -f 0x8 -F 0x100 -b > ${parent_dir}/${sample_idx}_unmapped1.tmp.bam

    # All R1.
    samtools sort -n ${parent_dir}/${sample_idx}_unmapped1.tmp.bam | samtools bam2fq - >> ${parent_dir}/${sample_idx}_r1.fastq

    echo "Dealing with R2 unmapped reads..."

    # R2 */unmapped #  -F 0x40 -f 0x4 
    samtools view $file -F 0x40 -f 0x4 -f 0x8 -F 0x100 -b > ${parent_dir}/${sample_idx}_unmapped2.tmp.bam


    # All R2.
    samtools sort -n ${parent_dir}/${sample_idx}_unmapped2.tmp.bam | samtools bam2fq - >> ${parent_dir}/${sample_idx}_r2.fastq

    # Rename reads.
    sed -i "s/@/@unmapped_/"  ${parent_dir}/${sample_idx}_r1.fastq
    sed -i "s/unmapped_sex_associated/sex_associated/"  ${parent_dir}/${sample_idx}_r1.fastq
    
    sed -i "s/@/@unmapped_/"  ${parent_dir}/${sample_idx}_r2.fastq
    sed -i "s/unmapped_sex_associated/sex_associated/"  ${parent_dir}/${sample_idx}_r2.fastq

    echo "De novo assemble"
    
    ######## De novo assemble to create contigs. ########
    /./oak/stanford/groups/dpwall/computeEnvironments/MEGAHIT/bin/megahit --min-contig-len=150 --keep-tmp-files \
    -1 ${parent_dir}/${sample_idx}_r1.fastq -2 ${parent_dir}/${sample_idx}_r2.fastq -o ${parent_dir}/${sample_idx}_assembly 
    cp ${parent_dir}/${sample_idx}_assembly/final.contigs.fa ${parent_dir}/${sample_idx}_assembly.fa
    sed -i "s/>/>${sample_idx}_/"  ${parent_dir}/${sample_idx}_assembly.fa

    bwa index ${parent_dir}/${sample_idx}_assembly.fa
    
    bwa mem ${parent_dir}/${sample_idx}_assembly.fa ${parent_dir}/${sample_idx}_r1.fastq ${parent_dir}/${sample_idx}_r2.fastq -o \
    ${parent_dir}/${sample_idx}_aligned_to_assembly.bam

    ######## Remove extra files/folders. ########
    #\rm ${parent_dir}/${sample_idx}_assembly -r
    #\rm *.tmp.*


fi