# CovWAS
Performs a genome-wide association test on coverage at each loci vs sex.

## Storage
- **Intermediate files**: ```MY_HOME/y_chromsome_mismappings/intermediate_files/coverages``` and ```MY_HOME/y_chromsome_mismappings/intermediate_files/covWAS```
- **Archived**: ```../intermediate_files/coverages``` and ```../intermediate_files/covWAS``` archived in gdrive.
- **Final data/results**: ```MY_HOME/y_chromsome_mismappings/results/covWAS```


## Workflow.

1. ✓ ```sample_coverages.sh```: Computes a vector of genome-wide read depths for every sample in iHART. (used ```zip_sample_coverages.sh``` to zip files before adding zipping features to ```sample_coverages.sh```) 
    - **Inputs**: AWS ihart bams.
    - **Outputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|PROPER|UNMAPPED>.txt.gz>```

2.  ✓ ```get_chromosome_line_numbers.ipynb```: Creates a table of chromsome/contig, corresponding start line #, and corresponding end line #. 
    - **Inputs**: sample AWS ihart bam.
    - **Outputs**: ```intermediate_files/coverages/chrom_start_ends.tsv```

3. For unmapped, improper, proper: ***TODO: Currently Running split_coverages on unmapped.***

   3.1.  ```split_coverages.sh```: Splits each coverage file into smaller coverage samples so they can be concatenated.
   - **Inputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|PROPER|UNMAPPED>.txt.gz>```
   - **Outputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|PROPER|UNMAPPED>.<REGIONS>.txt```

   3.2. ```concat_coverages.sh```: Concatenates together the coverages of all samples for each region of chromosome.
   - **Inputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|PROPER|UNMAPPED>.<REGION>.txt```
   - **Outputs**: ```intermediate_files/coverages/<IMPROPER|PROPER|UNMAPPED>.<REGION>.tsv.gz```


4.  ```covWAS.sh```: Runs a genome-wide (batched by chromsome) association between each loci & sex. Returns p-values and p-value related graphs.
    - **Inputs**: ```intermediate_files/coverages/<REGION>.<IMPROPER|PROPER|UNMAPPED>.tsv.gz>```
    - **Outputs**:  ```intermediate_files/coverages/<IMPROPER|PROPER|UNMAPPED>.pvals.txt>```, ```results/covWAS/<CHROMOSOME>.<IMPROPER|PROPER|UNMAPPED>.pvals_hist.svg>```, ```results/covWAS/<CHROMOSOME>.<IMPROPER|PROPER|UNMAPPED>.pvals_manhattan.svg>```
    
    
5. ```move_to_results.sh```: Move to permanent results directory.
    - ***Inputs***: ```intermediate_files/coverages/<IMPROPER|PROPER|UNMAPPED>.pvals.txt>```
    - ***Outputs***: ```results/coverages/<CHROMOSOME>.<IMPROPER|PROPER|UNMAPPED>.pvals.txt>```
    
Note: Ran ``organize_directories.sh``` to reorganize file structure a bit to make linux commands run faster.