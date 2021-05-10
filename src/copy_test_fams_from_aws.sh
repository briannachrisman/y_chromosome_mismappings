#!/bin/bash
#SBATCH --job-name=copy_test_fams_from_aws
#SBATCH --partition=dpwall
#SBATCH --array=1-95%10
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/copy_test_fams_from_aws.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/copy_test_fams_from_aws.err
#SBATCH --time=5:00:00
#SBATCH --mem=30GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu


### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/src/copy_test_fams_from_aws.sh

## Family 1 (with sib MH0143018 already uploaded.)
#for HOST in MH0143008 MH0143009 MH0143013 MH0143018
#do
#    aws s3 cp s3://ihart-hg38/cram/$HOST.final.cram.crai  /scratch/groups/dpwall/DATA/iHART/bam/$HOST.final.cram.crai
#    aws s3 cp s3://ihart-hg38/cram/$HOST.final.cram  /scratch/groups/dpwall/DATA/iHART/bam/$HOST.final.cram
    
#done

# Family 2
#for HOST in 02C10540 02C10541 02C10542 02C10543
#do
#    aws s3 cp s3://ihart-hg38/cram/$HOST.final.cram  /scratch/groups/dpwall/DATA/iHART/bam/$HOST.final.cram
#    aws s3 cp s3://ihart-hg38/cram/$HOST.final.cram.crai  /scratch/groups/dpwall/DATA/iHART/bam/$HOST.final.cram.crai
#done


# Family 3 -- same batch as family 1 (but LCL instead of WB)
#for HOST in 03C16794 03C16795 03C16796 03C16797 03C16798 
#do
#    echo $HOST
#    aws s3 cp s3://ihart-hg38/cram/$HOST.final.cram  /scratch/groups/dpwall/DATA/iHART/bam/$HOST.final.cram
#    aws s3 cp s3://ihart-hg38/cram/$HOST.final.cram.crai  /scratch/groups/dpwall/DATA/iHART/bam/$HOST.final.cram.crai
#done

### BATCH 00027
batch_00027="03C14328 03C15416 03C15417 03C15418 03C15419 03C15790 03C15791 03C15962 03C15963 03C16097 03C16098 03C16794 03C16795 03C16796 03C16797 03C16798 10C102514 10C102515 10C102516 10C102517 10C103890 10C103891 10C103892 10C103893 10C104027 10C104028 10C104029 10C104030 10C104031 10C105023 10C110447 10C110448 10C110449 10C110450 10C110451 10C110758 10C110759 10C110760 10C110761 10C112856 10C112857 10C112858 10C112859 10C112904 11C120670 11C120671 11C120680 11C120681 11C120684 11C120729 11C120730 11C120731 11C120732 11C122939 11C122940 11C122941 11C122942 11C123571 11C123572 11C123573 11C123574 11C123749 11C123777 11C123778 11C125629 11C125630 11C125631 11C125632 11C125633 11C125634 11C125860 11C125861 11C125862 11C125875 11C125876 MH0131344 MH0131348 MH0131365 MH0135248 MH0137425 MH0137426 MH0137427 MH0137428 MH0137429 MH0138049 MH0138050 MH0138051 MH0138052 MH0138054 MH0138055 MH0143008 MH0143009 MH0143013 MH0143018 MH0143019"
#SLURM_ARRAY_TASK_ID=3
arr=($batch_00027)
HOST=${arr[SLURM_ARRAY_TASK_ID-1]}
echo $HOST
head -
HOST=$A
echo $HOST
aws s3 cp s3://ihart-hg38/cram/$HOST.final.cram  /scratch/groups/dpwall/DATA/iHART/bam/$HOST.final.cram #### YOU MIGHT WANT TO CHANGE
aws s3 cp s3://ihart-hg38/cram/$HOST.final.cram.crai  /scratch/groups/dpwall/DATA/iHART/bam/$HOST.final.cram.crai #### YOU MIGHT WANT TO CHANGE