#!/bin/sh
#SBATCH --job-name=coverage_tables_per_chrom
#SBATCH --partition=dpwall
#SBATCH --array=1
#SBATCH --output=/scratch/users/briannac/logs/coverage_tables_per_chrom_%a.out
#SBATCH --error=/scratch/users/briannac/logs/coverage_tables_per_chrom_%a.err
#SBATCH --time=20:00:00
#SBATCH --mem=128GB
#SBATCH -c 20
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/coverage_tables_per_chrom.sh


### Before running, do: python3.6 /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/get_unfinshed_chrom_coverages.py unmapped

### SLURM_ARRAY_TASK_ID=1 ### CHANGE AFTER TESTING!!!
ml parallel 
export pairtype=unmapped  ### CHANGE IF DIFFERENT TYPE.

for i in 0 # 1000 2000 3000
do
    N=$((SLURM_ARRAY_TASK_ID+i))
    head -n $((N+1)) /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/chrom_start_stops_intervals_unfinished.tsv | tail -n 1  > $SCRATCH/tmp/tmp_covWAS_$SLURM_ARRAY_TASK_ID.txt

    while read CHROM START STOP _; do
        export chrom=$CHROM
        export start=$((START+2))
        export stop=$((STOP+1))
        export stop2=$((stop+1))

        echo $chrom $start $stop

        select_regions () { 
            echo $1
            echo $1 >  /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/covWAS/${1/txt/.${chrom}.txt}
            sed -n "$start,${stop}p" $1 >> /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/covWAS/${1/txt/.${chrom}.txt}
        }

        export -f select_regions
        
        if [ ! -f /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/covWAS/${pairtype}.${chrom}.done ]; then
            echo $pairtype
            cd /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages
            parallel -j 20 select_regions ::: *.${pairtype}.txt
            cd /home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/covWAS
            paste *.${pairtype}.${chrom}.txt > ${pairtype}.${chrom}.tsv
            gzip -f ${pairtype}.${chrom}.tsv
            \rm *.${pairtype}.${chrom}.txt
            echo "done" > ${chrom}.${pairtype}.done
        fi

    done < $SCRATCH/tmp/tmp_covWAS_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_covWAS_$SLURM_ARRAY_TASK_ID.txt
done
