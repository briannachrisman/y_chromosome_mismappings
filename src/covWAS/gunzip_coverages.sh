#!/bin/sh
#SBATCH --job-name=gunzip_coverages
#SBATCH --partition=dpwall
#SBATCH --array=1
#SBATCH --output=/scratch/users/briannac/logs/gunzip_coverages_%a.out
#SBATCH --error=/scratch/users/briannac/logs/gunzip_coverages_%a.err
#SBATCH --time=5:00:00
#SBATCH -c 20
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/gunzip_coverages.sh


cd /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/


ml parallel 
split_func() {
    #gunzip $1 # Note: We already did gunzip in another script.
    echo $1
    txtfile=${1/.txt.gz/.txt}
    sample=${txtfile/.unmapped.txt/}
    echo "deleting first line"
    tail -n +2 "$txtfile" > "$txtfile.tmp" && mv "$txtfile.tmp" "$txtfile" # Remove first line of file (sample name), shouldn't have added this in the first place.
    
    echo "splitting file"
    split -l 1000000 -d -a 4 --additional-suffix=.txt $txtfile ${txtfile/.txt/.} # Split into many 1M line files.
        
    
    # Add sample name to start of all files.
    echo "Adding sample name to split files"
    for f in ${sample}.unmapped.*.txt; do 
        echo $sample > ${sample}.tmpfile.txt
        cat $f >> ${sample}.tmpfile.txt
        mv ${sample}.tmpfile.txt $f
    done
    
    echo "zipping back up to save space"
    gzip $txtfile # Zip back up to save some space.
}

export -f split_func

N=$((SLURM_ARRAY_TASK_ID -1))
N=$(printf "%02g" $N)

parallel -j 20 split_func ::: *$N.unmapped.txt