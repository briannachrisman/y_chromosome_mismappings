import pandas as pd
import numpy as np
from scipy import stats
import sys
import multiprocessing
import tqdm
import time 
import csv
from pandarallel import pandarallel

pandarallel.initialize()


cpus = multiprocessing.cpu_count()
print("num cpus: ", cpus)
prefix = sys.argv[1]
dataset = sys.argv[2]

print(prefix + '.tsv')
with open(prefix + '.tsv') as f:
    num_loci = sum(1 for line in f)-1
pvals = np.zeros(num_loci) + np.nan
print(num_loci, " total pvalues.")

# Load metadata.
if dataset=='ihart':
    bam_mappings = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/data/bam_mappings.csv', sep='\t')
    balanced_children = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/data/balanced_children_ihart.csv', sep='\t', header=None)
    bam_mappings.index = bam_mappings.sample_id
    bam_mappings = bam_mappings.loc[list(balanced_children[0].values)]
#elif dataset=='1kg':
#    bam_mappings = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/data/1kg_hg38_metadata.tsv', sep='\t')
#    bam_mappings.index = bam_mappings['Sample name']

first_chunk = True
for chunk in tqdm.tqdm(pd.read_csv(prefix + '.tsv', chunksize=2000000, sep='\t')):
    t=time.time()  
    # Find male and female IDS
    if first_chunk:
        sample_ids_in_dataset = set(chunk.columns).intersection(set(bam_mappings.index))
        ids = bam_mappings.loc[sample_ids_in_dataset]
        print(len(sample_ids_in_dataset), ' samples (should be 236)')
        if dataset=='ihart':
            males = ids[ids.sex_numeric=='1.0'].index
            females = ids[ids.sex_numeric=='2.0'].index
        elif dataset=='1kg':
            males = ids[ids.Sex=='male'].index
            females = ids[ids.Sex=='female'].index
        first_chunk = False
    chunk = chunk[sample_ids_in_dataset]
    chunk = chunk[chunk.sum(axis=1)>0]
    if len(chunk)==0: 
        print('no pvals to compute in current chunk, moving to next')
        continue
    print(len(chunk), 'pvals to compute')
    males_sort=list(bam_mappings.loc[males].sort_values('family').index)
    females_sort = list(bam_mappings.loc[females].sort_values('family').index)
    male_df=chunk[males_sort]
    female_df=chunk[females_sort]
    
    male_df.columns = bam_mappings.loc[male_df.columns].family.values
    female_df.columns = bam_mappings.loc[female_df.columns].family.values
    diff = male_df-female_df
    print('computing pvals...')
    pvals[list(chunk.index)] = diff.parallel_apply(axis=1, func=lambda x: stats.wilcoxon(x).pvalue)
print('done computing pvals')

non_nan_idx = np.where(~np.isnan(pvals))[0]
towrite=[non_nan_idx, pvals[non_nan_idx]]

with open(prefix + '.pvals.tsv',"w+") as my_csv:
    csvWriter = csv.writer(my_csv,delimiter=' ')
    csvWriter.writerows(towrite)