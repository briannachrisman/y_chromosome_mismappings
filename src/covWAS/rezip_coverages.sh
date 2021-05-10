#!/bin/sh
#SBATCH --job-name=gunzip
#SBATCH --partition=owners
#SBATCH --array=1-1000
#SBATCH --output=/scratch/users/briannac/logs/gunzip%a.out
#SBATCH --error=/scratch/users/briannac/logs/gunzip%a.err
#SBATCH --time=20:00:00
#SBATCH -c 20
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/coverage_tables_per_chrom.sh


### Before running, do: python3.6 /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/get_unfinshed_chrom_coverages.py


ml parallel 
gunzip_func() {
    gzip $1
}
parallel -j 20 gunzip -c ::: *.unmapped.txt