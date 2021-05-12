#!/bin/sh
#SBATCH --job-name=organize_directories_covWAS
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/organize_directories_covWAS.out
#SBATCH --error=/scratch/users/briannac/logs/organize_directories_covWAS.err
#SBATCH --time=40:00:00
#SBATCH --mem=1G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/organize_directories.sh

cd /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages
while read SAMPLE _; do
    echo "running" $SAMPLE
    mkdir $SAMPLE
    mv $SAMPLE.unmapped.txt.gz $SAMPLE/$SAMPLE.unmapped.txt.gz
    mv $SAMPLE.unmapped.txt $SAMPLE/$SAMPLE.unmapped.txt
    mv $SAMPLE.improper.txt.gz $SAMPLE/$SAMPLE.improper.txt.gz
    mv $SAMPLE.improper.txt $SAMPLE/$SAMPLE.improper.txt
    mv $SAMPLE.proper.txt.gz $SAMPLE/$SAMPLE.proper.txt.gz
    mv $SAMPLE.proper.txt $SAMPLE/$SAMPLE.proper.txt
    for i in {0..3217}; do
        N=$(printf "%04g" $i)
        mv $SAMPLE.unmapped.$N.txt $SAMPLE/$SAMPLE.unmapped.$N.txt
        mv $SAMPLE.unmapped.$N.txt.gz $SAMPLE/$SAMPLE.unmapped.$N.txt.gz
    done
done < $MY_HOME/general_data/samples_and_batches.tsv


