import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import tqdm
import sys

print(sys.argv)
pval_file=sys.argv[1]
fig_dir=sys.argv[2]
dataset=sys.argv[3]
print(dataset)

print(pval_file)

# Compute indexes corresponding to M/F ids.
with open(pval_file.replace('.pvals', '')) as f:
    for i, line in enumerate(f):
        ids = line.replace('\n', '').split('\t')
        break

if dataset=='ihart':
    bam_mappings = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/data/bam_mappings.csv', sep='\t')
    bam_mappings.index = bam_mappings.sample_id
    male_idx = np.where(bam_mappings.loc[ids].sex_numeric.values=='1.0')[0]
    female_idx = np.where(bam_mappings.loc[ids].sex_numeric.values=='2.0')[0]
elif dataset=='1kg':
    bam_mappings = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/data/1kg_hg38_metadata.tsv', sep='\t')
    bam_mappings.index = bam_mappings['Sample name']
    
    males = np.where(bam_mappings.loc[ids].Sex.values=='male')[0]
    females = np.where(bam_mappings.loc[ids].Sex.values=='female')[0]

### Graph loci vs p-vals ###
print("Loci vs pvals")
with open(pval_file) as my_csv:
    lines=my_csv.readlines()
loci = np.array([int(l) for l in lines[0].replace('\n', '').split(' ')])
pvals = np.array([float(l) for l in lines[1].replace('\n', '').split(' ')])
plt.figure(figsize=(20,5))
plt.plot(loci, -np.log10(pvals), '.', color='#8687d1')
sig_lim=.05/len(pvals)
plt.plot(loci, loci*0-np.log10(sig_lim), '--', markersize=1, color='orange')
plt.xlabel('Loci')
plt.ylabel('-log10(p)')
plt.title(fig_dir)
plt.tight_layout()
plt.savefig('%s.pvals.png' % fig_dir)
           
    
#### Histogram of p-values ####
# expects numpy array of pvals
print("Histogram of pvalues")
plt.figure(figsize=(7, 5))
indices = ~np.isnan(pvals) #& np.all(np.sum(all_allele_counts, axis=1)>100, axis=1)
binsize=.1
a = np.power(10.0, -np.arange(12, -binsize, -binsize))
# hist
ax = plt.subplot(1, 1, 1)
n, bins, _ = plt.hist(np.clip(pvals[indices], 10.0**(-20), None), 
                      bins=a, log=True, color='#8687d1')
# theoretical - expect pvals to follow a uniform distribution between 0-1
exp = np.sum(indices)*(bins[1:]-bins[:-1])
plt.plot(10**(binsize/2) * a[:-1][exp>1], exp[exp>1], color='black', linestyle='--', linewidth=2, label='theoretical')
plt.xlabel('pvalue')
plt.ylabel('Number of Sites')
plt.title('Histogram of pvals')
plt.xscale('log')
ax.tick_params(axis='both', which='major', labelsize=14)
plt.plot([.05/len(pvals) for _ in exp[exp>1]], exp[exp>1], color='orange', linestyle='--', linewidth=2, label='bonferonni')
plt.legend()
plt.tight_layout()
plt.savefig('%s.pvals_hist.png' % fig_dir)


## Plot sample-wise heatmap of coverage ###
'''
hits = loci[pvals<sig_lim]
hits = hits[:-1][(hits[1:]-hits[:-1])>100]
if hits[-1]<(hits[-2]+100):
    hits = hits[:-1]
array = [[] for h in hits]
array_idx=0
with open('%s/%i.%s.tsv' % (pileup_dir, chrom, pileup_type)) as f:
    for i, line in tqdm.tqdm(enumerate(f)):
        if i+1==hits[array_idx]:
            array[array_idx]=[float(f) for f in line.replace('\n', '').split('\t')]
            array_idx=array_idx+1
        if array_idx==len(hits):break

plt.figure(figsize=(10,10))
pileup_df = pd.DataFrame(array)
pileup_df = pd.concat([pileup_df[male_idx], pileup_df[female_idx]], axis=1)
pileup_df.index = hits
pileup_df_norm = pileup_df.apply(lambda x: x/max(x), axis=1)
sns.heatmap(pileup_df_norm, cmap='inferno')
plt.vlines(x=len(male_idx), ymin=0, ymax=len(pileup_df_norm), colors='gold')
plt.xlabel('Person')
plt.ylabel('Loci')
plt.title('Normalized Coverage for Chr%i %s hits' % (chrom, pileup_type))
plt.tight_layout()
plt.savefig('%s/%i.%s.coverage_heatmap.png' % (fig_dir, chrom, pileup_type))
'''