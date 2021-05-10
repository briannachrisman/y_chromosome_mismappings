#!/bin/sh
#SBATCH --job-name=split_coverages
#SBATCH --partition=owners
#SBATCH --array=1-100
#SBATCH --output=/scratch/users/briannac/logs/split_coverages_%a.out
#SBATCH --error=/scratch/users/briannac/logs/split_coverages_%a.err
#SBATCH --time=40:00:00
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/split_coverages.sh


cd /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/

ml parallel 
split_func() {
    #gunzip $1 # Note: We already did gunzip in another script.
    echo $1
    txtfile=${1/.txt.gz/.txt}
    sample=${txtfile/.unmapped.txt/}
    if [ $(sed -n "1{/^$sample/p};q" $txtfile) ]; then
        echo "deleting first line"
        tail -n +2 "$txtfile" > "$txtfile.tmp" && mv "$txtfile.tmp" "$txtfile" # Remove first line of file (sample name), shouldn't have added this in the first place.
    fi

    
    echo "splitting file"
    split -l 1000000 -d -a 4 --additional-suffix=.txt $txtfile ${txtfile/.txt/.} # Split into many 1M line files.
        
    
    # Add sample name to start of all files.
    echo "Adding sample name to split files"
    for f in ${sample}.unmapped.*.txt; do 
        echo $f
        sed  -i "1i $sample" $f
    done
    
    echo "zipping back up to save space"
    gzip $txtfile # Zip back up to save some space.
}

export -f split_func

N=$((SLURM_ARRAY_TASK_ID -1))
N=$(printf "%02g" $N)
#parallel -j $SLURM_CPUS_PER_TASK split_func ::: *$N.unmapped.txt
for f in *$N.unmapped.txt; do
    split_func $f
done

# Note after all arrays have finished do (for _LCL or _reprep samples): parallel -j 20 split_func ::: *$N.unmapped.txt
# do ls /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/*.unmapped.txt.gz | wc -l to see how many have completed