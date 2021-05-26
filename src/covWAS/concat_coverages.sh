#!/bin/sh
#SBATCH --job-name=concat_coverages
#SBATCH --partition=owners
#SBATCH --array=1-1000
#SBATCH --output=/scratch/users/briannac/logs/concat_coverages_%a.out
#SBATCH --error=/scratch/users/briannac/logs/concat_coverages_%a.err
#SBATCH --time=40:00:00
#SBATCH --mem=5G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/concat_coverages.sh  # 3217 regions.

for i in 1000 2000 3000 ; do
    N=$((SLURM_ARRAY_TASK_ID-1+i))
    N=$(printf "%04g" $N)
    
    if [ "$N" -lt 3218 ]; then
    if [ ! -f $MY_HOME/y_chromosome_mismappings/results/coverages/all/coverages.all.$N.tsv.gz ]; then
        mkdir $MY_SCRATCH/tmp/y_chromosome_mismappings/$N
        idx=0
        while read SAMPLE BATCH; do
            idx=$((idx+1))
            file=$MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/$SAMPLE/$SAMPLE.all.$N.txt;
            echo $SAMPLE > $MY_SCRATCH/tmp/y_chromosome_mismappings/$N/$SAMPLE.all.$N.txt     
            sed "/$SAMPLE/d" $file | sed  '/[*]/d' >> $MY_SCRATCH/tmp/y_chromosome_mismappings/$N/$SAMPLE.all.$N.txt            
            echo $idx $(wc -l $MY_SCRATCH/tmp/y_chromosome_mismappings/$N/$SAMPLE.all.$N.txt)
        done < $MY_HOME/general_data/samples_and_batches.tsv
        echo "pasting..."
        paste $MY_SCRATCH/tmp/y_chromosome_mismappings/$N/*.all.$N.txt > $MY_SCRATCH/tmp/y_chromosome_mismappings/coverages/all.$N.tsv
        gzip -f $MY_SCRATCH/tmp/y_chromosome_mismappings/coverages/all.$N.tsv 
        #mv $MY_SCRATCH/tmp/y_chromosome_mismappings/coverages/all.$N.tsv.gz $MY_HOME/y_chromosome_mismappings/results/coverages/all/coverages.all.$N.tsv.gz
        mv $MY_SCRATCH/tmp/y_chromosome_mismappings/coverages/all.$N.tsv.gz   /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/concat/all/coverages.all.$N.tsv.gz
        
        \rm $MY_SCRATCH/tmp/y_chromosome_mismappings/$N -r
    fi
    fi

done

