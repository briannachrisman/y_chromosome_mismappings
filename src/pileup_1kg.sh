#!/bin/bash
#SBATCH --job-name=pileup_1kg
#SBATCH --partition=dpwall
#SBATCH --array=21%10
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/pileup_1kg_%a.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/pileup_1kg_%a.err
#SBATCH --time=4:00:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/pileup_1kg.sh

module load py-numpy/1.14.3_py36
module load py-scipy/1.1.0_py36
module load parallel 
parallel --citation

export chrom=$SLURM_ARRAY_TASK_ID
export pileup_dir=/scratch/groups/dpwall/personal/briannac/unmapped_reads/results/pileups/1kg


files=('ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3242773/HG01092.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3242646/HG03793.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3242946/HG02879.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3242246/HG02292.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239511/NA18613.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3241952/HG01617.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3242657/HG03829.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239713/NA19318.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3242102/HG02049.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3243044/HG03767.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239774/NA19461.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3240167/HG00180.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239592/NA19060.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239705/NA19308.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239417/NA18975.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3242617/HG03168.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3242593/HG03291.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3240095/NA19922.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239835/NA20755.final.cram' 'ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR323/ERR3239672/NA18950.final.cram')


samples=(HG01092 HG03793 HG02879 HG02292 NA18613 HG01617 HG03829 NA19318 HG02049 HG03767 NA19461 HG00180 NA19060 NA19308 NA18975 HG03168 HG03291 NA19922 NA20755 NA18950)

generate_pileups(){
    file=$1
    sample_idx=$2
    echo running ${sample_idx} on chr $chrom on file $file
    date
    
    ################### Improperly paired pileups.  ###################
    samtools view -F 0x2 -F 0x400 -F 0x100 -F 0x200 $file -b chr21 \
    | samtools mpileup  -a -A -f /oak/stanford/groups/dpwall/users/briannac/_old_unmapped_reads/data/ref_genomes/hg38/hg38.fa - |\
    awk -vsample="${sample_idx}" 'BEGIN{print sample};{print $4}'  > ${pileup_dir}/${chrom}.${sample_idx}.improper.txt
    python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/normalize_pileup.py ${pileup_dir}/${chrom}.${sample_idx}.improper.txt
    

    ################### Properly paired pileups.  ###################
    samtools view -f 0x2 -F 0x400 -F 0x100 -F 0x200 $file  -b chr21 \
    | samtools mpileup  -a -A -f /oak/stanford/groups/dpwall/users/briannac/_old_unmapped_reads/data/ref_genomes/hg38/hg38.fa -   |\
    awk -vsample="${sample_idx}" 'BEGIN{print sample};{print $4}' > ${pileup_dir}/${chrom}.${sample_idx}.proper.txt
    python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/normalize_pileup.py ${pileup_dir}/${chrom}.${sample_idx}.proper.txt
    echo finished running ${sample_idx}
    date
}

export -f generate_pileups
parallel --link -j 16 generate_pileups ::: ${files[@]} ::: ${samples[@]}

echo "Combining into tsv file and computing p vals starting at"
date
paste ${pileup_dir}/${chrom}.*.improper.txt.norm > ${pileup_dir}/${chrom}.improper.tsv
paste ${pileup_dir}/${chrom}.*.proper.txt.norm > ${pileup_dir}/${chrom}.proper.tsv

echo "Computing pvals improper"
python3 -u -W ignore /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/pileup_pvals.py ${pileup_dir}/${chrom}.improper
echo "Computing pvals proper"
python3 -u -W ignore /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/pileup_pvals.py ${pileup_dir}/${chrom}.proper
echo "Done at"
date