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
    
    while read chrom start end  ######## For each sex-associated region ########
    do

        echo $chrom $start $end ${parent_dir}/${sample_idx}

        ######## Subset bam file to reads within current region. ########
        samtools view $file  $chrom:$start-$end -b > ${parent_dir}/${sample_idx}.tmp.bam
        echo "Finished subsetting bam file for " $sample_idx $chrom$start-$end

        ######## Compute median MAPQ and AS for hit on sample and add to sample.MAPQ_medians and sample.AS_median files. ########
        
        # Median MAPQ
        samtools view -F 0x100 ${parent_dir}/${sample_idx}.tmp.bam \
        | awk '{sum+=$5;a[x++]=$5;}END{print 0 a[int((x-1)/2)]}'  >> ${parent_dir}/${sample_idx}.MAPQ_median.txt # Median of MAPQ 

        # Median AS
        samtools view -F 0x100 ${parent_dir}/${sample_idx}.tmp.bam \
        | grep -o -P '(?<=AS:i:).*(?=\tXS)' | awk '{sum+=$1;a[x++]=$1;}END{print 0 a[int((x-1)/2)]}' >> ${sample_idx}.AS_median.txt
        
        # Mates
        samtools view -F 0x100 ${parent_dir}/${sample_idx}.tmp.bam \
        | cut -f7 |  paste -sd, >> ${sample_idx}.mates.txt
        
        # Flags
        samtools view -F 0x100 ${parent_dir}/${sample_idx}.tmp.bam \
        | cut -f2 |  paste -sd, >> ${sample_idx}.flags.txt
        
        # Depths
        samtools view -F 0x100 ${parent_dir}/${sample_idx}.tmp.bam \
        | wc -l >> ${sample_idx}.depths.txt
        
        echo "Finished computing median MAPQ/AS for " $sample_idx $chrom$start-$end

        ######## Remember read IDs for later use. ########
        samtools view ${parent_dir}/${sample_idx}.tmp.bam |  awk {'print $1'}  >> ${parent_dir}/${sample_idx}.ids.txt

    done < /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/hits_locations.csv
    
fi