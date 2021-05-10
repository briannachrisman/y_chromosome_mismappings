#!/bin/sh
#SBATCH --job-name=get_finished_samples
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/get_finished_samples.out
#SBATCH --error=/scratch/users/briannac/logs/get_finished_samples.err
#SBATCH --time=40:00:00
#SBATCH --mem=128GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/y_chromosome_mismappings/src/covWAS/get_finished_samples.sh

ml parallel 

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


parallel -j 20 check_done_unmapped ::: $MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/*.unmapped.txt.gz

parallel -j 20 check_done_proper ::: $MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/*.proper.txt.gz

parallel -j 20 check_done_improper ::: $MY_HOME/y_chromosome_mismappings/intermediate_files/coverages/*.improper.txt.gz