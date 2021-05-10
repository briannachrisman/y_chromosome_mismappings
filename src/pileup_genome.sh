#!/bin/bash
#SBATCH --job-name=pileup_genome
#SBATCH --partition=dpwall
#SBATCH --array=1%10
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/pileup_genome%a.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/pileup_genome%a.err
#SBATCH --time=4:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/pileup_genome.sh

module load py-numpy/1.14.3_py36
module load py-scipy/1.1.0_py36
module load parallel 
parallel --citation
SLURM_ARRAY_TASK_ID=1
export SAMPLE=$(cut -f1 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_ihart_dataset.csv | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)
export FILE=$(cut -f2 /scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_ihart_dataset.csv | head -n $SLURM_ARRAY_TASK_ID | tail -n 1)
export pileup_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/tsv_files
export normalize=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/normalize.py
export pvals=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/src/pvals.py
export quality=0

fig_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/figs
echo running $SAMPLE on genome, file at $FILE
prefix=${pileup_dir}/q${quality}.${SAMPLE}
hg38=/oak/stanford/groups/dpwall/users/briannac/_old_unmapped_reads/data/ref_genomes/hg38/hg38.fa

################### Properly paired pileups.  ###################
samtools view -q $quality -f 0x2 -F 0x4 -F 0x400 -F 0x100 -F 0x200 -b $FILE   | \
samtools mpileup  -a -a -A -f ${hg38} -    | \
awk -vsample="${SAMPLE}" 'BEGIN{print sample};{print $4}'  > ${prefix}.proper.txt    
python3 -u $normalize ${prefix}.proper.txt 
    
################### Improperly paired pileups.  ###################
samtools view -q $quality -F 0x2 -F 0x4 -F 0x8 -F 0x400 -F 0x100 -F 0x200 -b $FILE    | \
samtools mpileup  -aa -A -f ${hg38} -   | \
awk -vsample="${SAMPLE}" 'BEGIN{print sample};{print $4}'   > ${prefix}.improper.txt
python3 -u $normalize ${prefix}.improper.txt 
    
################### Unmapped paired pileups.  ###################
samtools view -q $quality -f 0x8 -F 0x4 -F 0x400 -F 0x100 -F 0x200  -b $FILE   | \
samtools mpileup  -a -a -A -f ${hg38}  -  | \
awk -vsample="${SAMPLE}" 'BEGIN{print sample};{print $4}'   > ${prefix}.unmapped.txt
python3 -u $normalize ${prefix}.unmapped.txt 
    
\rm ${SAMPLE}.final.cram.crai

#done
