import pandas as pd
import numpy as np
from scipy import stats
import sys
import multiprocessing
import tqdm
import time 
import csv


cpus = multiprocessing.cpu_count()
print("num cpus: ", cpus)
prefix = sys.argv[1]
#prefix = '/scratch/groups/dpwall/personal/briannac/unmapped_reads/results/pileups/1kg/21.improper'
num_loci = sum(1 for line in open(prefix + '.tsv'))-1

bam_mappings = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/data/1kg_hg38_metadata.tsv', sep='\t')
bam_mappings.index = bam_mappings['Sample name']

pvals = np.zeros(num_loci) + np.nan



first_chunk = True
for chunk in tqdm.tqdm(pd.read_csv(prefix + '.tsv', chunksize=1000000, sep='\t')):
    t=time.time()  
    if first_chunk:    
        ids = bam_mappings.loc[set(chunk.columns).intersection(set(bam_mappings.index))]
        males = ids[ids.Sex=='male'].index
        females = ids[ids.Sex=='female'].index
        first_chunk = False
    chunk = chunk[chunk.sum(axis=1)>0]
    if len(chunk)==0: continue
    print(len(chunk), 'pvals to compute')
    pvals[list(chunk.index)] = stats.ttest_ind(chunk[males].transpose(), chunk[females].transpose()).pvalue
    print(time.time()-t)
print('done computing pvals')
    
non_nan_idx = np.where(~np.isnan(pvals))[0]
towrite=[non_nan_idx, pvals[non_nan_idx]]

with open(prefix + '.pvals.tsv',"w+") as my_csv:
    csvWriter = csv.writer(my_csv,delimiter=' ')
    csvWriter.writerows(towrite)