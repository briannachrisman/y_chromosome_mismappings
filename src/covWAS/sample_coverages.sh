#!/bin/sh
#SBATCH --job-name=sample_coverages
#SBATCH --partition=owners
#SBATCH --array=1-20
#SBATCH --output=/scratch/users/briannac/logs/sample_coverages_%a.out
#SBATCH --error=/scratch/users/briannac/logs/sample_coverages_%a.err
#SBATCH --time=20:00:00
#SBATCH --mem=1GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/sample_coverages.sh

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


check_done_unmapped () { 
    file=$1
    if [[ $(zgrep -Ec "$" $file) == 3217346918 ]]; then
        echo $file finished
    else
        \rm ${file/.unmapped.txt.gz/.done}
        echo $file not finished
    fi
}

check_done_proper () { 
    file=$1
    if [[ $(zgrep -Ec "$" $file) == 3217346918 ]]; then
        echo $file finished
    else
        \rm ${file/.proper.txt.gz/.done}
        \rm ${file/.proper./.improper.}
        echo $file not finished
    fi
}


check_done_improper () { 
    file=$1
    if [[ $(zgrep -Ec "$" $file) == 3217346918 ]]; then
        echo $file finished
    else
        \rm ${file/.improper.txt.gz/.done}
        \rm ${file/.improper./.unmapped.}
        echo $file not finished
    fi
}

export -f check_done_unmapped
export -f check_done_proper
export -f check_done_improper


unfinished_samples_and_batches=$MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/sample_and_batch_unfinished.tsv
intermediate_dir=$MY_HOME/y_chromosome_mismappings/intermediate_files/coverages

cd $SCRATCH/tmp
for I_TO_ADD in 0
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE _; do

        echo $SAMPLE
        cd $intermediate_dir/$SAMPLE
        \rm *all*
        ################### Improperly paired pileups.  ###################
        echo "Counting improperly paired..."
        #if [ ! -f "${intermediate_dir}/$SAMPLE.unmapped.txt.gz" ]; then
        #     /oak/stanford/groups/dpwall/computeEnvironments/samtools-1.10/bin/samtools depth  s3://ihart-hg38/cram/${SAMPLE/_LCL/-LCL}.final.cram -aa -G 0x2 -G 0x8 -G 0x400 -G 0x100 -G 0x200  | cut -f3  >> ${intermediate_dir}/$SAMPLE.improper.txt
        #    gzip -f ${intermediate_dir}/$SAMPLE.improper.txt
        #fi


        ################### Unmapped paired pileups.  ###################
        echo "Counting all..."
         /oak/stanford/groups/dpwall/computeEnvironments/samtools-1.10/bin/samtools depth  s3://ihart-hg38/cram/${SAMPLE/_LCL/-LCL}.final.cram  -G 0x400 -G 0x100 -G 0x200 -aa | cut -f3 > ${intermediate_dir}/$SAMPLE.all.txt
        #gzip -f ${intermediate_dir}/$SAMPLE.all.txt
        
        
        
        # When done with everything, write to done file.
        echo 'done' > ${intermediate_dir}/$SAMPLE.done
        
        #check_done_proper ${intermediate_dir}/$SAMPLE.proper.txt.gz
        #check_done_improper ${intermediate_dir}/$SAMPLE.improper.txt.gz
        #check_done_unmapped ${intermediate_dir}/$SAMPLE.all.txt.gz

        
        \rm ${intermediate_file_dir}/${SAMPLE}*tmp*
    done < $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_coverages_$SLURM_ARRAY_TASK_ID.txt
done



# Adding .done files for samples that finished.
#for file in $MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/*11.unmapped.txt.gz; do
#    if [[ $(zgrep -Ec "$" $file) == 3217346918 ]]; then
#        #echo "done "> ${file/.unmapped.txt/.done}
#        echo $file finished
#    else
#        \rm ${file/.unmapped.txt.gz/.done}
#        echo $file not finished
#    fi
#done


