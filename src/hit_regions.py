import pandas as pd
import numpy as np
from collections import Counter
import copy
import sys

MIN_DISTANCE_BETWEEN_REGIONS = 10000
print("Reading in pvals / loci...")
chrom = sys.argv[1]
with open('/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/tsv_files/%s.norm.pvals.tsv' % chrom) as my_csv:
    lines=my_csv.readlines()
loci = np.array([int(l) for l in lines[0].replace('\n', '').split(' ')])
pvals = np.array([float(l) for l in lines[1].replace('\n', '').split(' ')])
pvals_sig = loci[pvals<(.05/3000000000)]
pvals_sig = loci[pvals<(.05/3000000000)]
pvals_sig = np.array([-1e10] + list(pvals_sig) + [1e10])

print("Computing start/end loci of hits")
loners = list(pvals_sig[1:-1][(abs(pvals_sig[1:-1]-pvals_sig[:-2])>=MIN_DISTANCE_BETWEEN_REGIONS) & (abs(pvals_sig[1:-1]-pvals_sig[2:])>=MIN_DISTANCE_BETWEEN_REGIONS)])
starts = list(pvals_sig[1:-1][(abs(pvals_sig[1:-1]-pvals_sig[:-2])>=MIN_DISTANCE_BETWEEN_REGIONS) & (abs(pvals_sig[1:-1]-pvals_sig[2:])<MIN_DISTANCE_BETWEEN_REGIONS)]) + loners
ends = list(pvals_sig[1:-1][(abs(pvals_sig[1:-1]-pvals_sig[:-2])<MIN_DISTANCE_BETWEEN_REGIONS) & (abs(pvals_sig[1:-1]-pvals_sig[2:])>=MIN_DISTANCE_BETWEEN_REGIONS)]) + loners
loners = np.array(loners)
starts = np.array(starts)
ends = np.array(ends)

hits_df = pd.DataFrame([[chrom for _ in starts], starts, ends, ends-starts+1]).transpose()
hits_df.columns = ['chrom', 'start', 'end', 'length']
loci_select = np.concatenate([np.array(range(int(start), int(end))) for start, end in zip(hits_df['start'].values, hits_df['end'].values)])


pvals_sig = [int(i) for i in pvals_sig[1:-1]]
cluster = [np.where([((l >= start) & (l <= end)) for start, end in zip(hits_df['start'].values, hits_df['end'].values)])[0][0] for l in loci_select]
clusters_df = pd.DataFrame([loci_select, cluster]).transpose()
clusters_df.columns = ['loci', 'cluster']
clusters_df.index = [int(i) for i in clusters_df['loci']]
clusters_df.cluster = [int(i) for i in clusters_df.cluster.values]
hits_df['n_sig'] = [len(set(clusters_df[clusters_df.cluster==cluster_num].loci.values.astype('int')).intersection(set(pvals_sig)))+1 for cluster_num in range(len(hits_df))]
hits_df['perc_sig'] = hits_df.n_sig/hits_df.length
hits_df.to_csv(
    '/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/hits_stats_%s.csv' % chrom,
    sep='\t', index=None, header=None)

# Create csv file for location.
df = pd.DataFrame([[int(i) for i in hits_df['start'].values],
              [int(i) for i in hits_df['end'].values]]).transpose()
df['chrom'] = chrom
df.columns = ['start', 'end', 'chrom']
df[['chrom', 'start', 'end']].to_csv(
    '/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/hits_locations_%s.csv' % chrom,
    sep='\t', index=None, header=None)

# Create csv file for all hits.
df = pd.DataFrame(pvals_sig)
df['chrom'] = chrom
df.columns = ['loci', 'chrom']
df.to_csv(
    '/scratch/groups/dpwall/personal/briannac/unmapped_reads/pileups/results/sig_pvals/loci_locations_%s.csv' % chrom,
    sep='\t', index=None, header=None)

