#!/bin/sh
#SBATCH --job-name=sample_and_split_nonproper
#SBATCH --partition=owners
#SBATCH --array=1-1000
#SBATCH --output=/scratch/users/briannac/logs/sample_and_split_nonproper_%a.out
#SBATCH --error=/scratch/users/briannac/logs/sample_and_split_nonproper_%a.err
#SBATCH --time=20:00:00
#SBATCH --mem=1GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/sample_and_split_nonproper.sh

## SLURM_ARRAY_TASK_ID=1 ### CHANGE WHEN RUNNING BATCH!!!


#module load py-numpy/1.14.3_py36
#module load py-scipy/1.1.0_py36


################
# Note: Before kicking off, run 

#find $MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/*_unmapped.txt -size 0 -print -delete

#python3.6 $MY_HOME/general_scripts/slurm_and_batch_resources/unfinished_samples.py $MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/ .done $MY_HOME/general_data/samples_and_batches.tsv $MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/sample_and_batch_unfinished.tsv
################


###############################################################################
###### Note $MY_HOME/y_chromsome_mismappings/intermediate_files/coverages/* #######
###### has NOT been archived in ____________ #######
###############################################################################



unfinished_samples_and_batches=$MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/sample_and_batch_unfinished.tsv
intermediate_dir=$MY_HOME/y_chromosome_mismappings/intermediate_files/coverages

cd $SCRATCH/tmp
for I_TO_ADD in 0 1000 2000 3000 4000; do
    
    # Figure out current sample.
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE _; do

        echo $SAMPLE 
        cd ${intermediate_dir}/$SAMPLE
        txtfile=$SAMPLE.nonproper.txt  
        ################### Properly paired pileups.  ###################
        echo "Counting properly paired..."
        if [ ! -f "$SAMPLE.nonproper.txt.gz" ]; then
        
            # Collect coverages.
            /oak/stanford/groups/dpwall/computeEnvironments/samtools-1.10/bin/samtools depth  s3://ihart-hg38/cram/${SAMPLE/_LCL/-LCL}.final.cram -aa -G 0x2 -G 0x400 -G 0x100 -G 0x200| cut -f3  >>  $txtfile

            # Split into many files.
            split -l 1000000 -d -a 4 --additional-suffix=.txt $txtfile ${txtfile/.txt/.} # Split into many 1M line files.

            # Add sample name to start of all files.
            echo "Adding sample name to split files"
            for f in ${SAMPLE}.nonproper.*.txt; do 
                echo $f
                sed  -i "1i $SAMPLE" $f
            done
    
            echo "zipping back up to save space"
            gzip $txtfile
        fi

    done < $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
done


