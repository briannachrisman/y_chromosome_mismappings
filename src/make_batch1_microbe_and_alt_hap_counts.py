import pandas as pd
from collections import Counter
import numpy as np
from Bio import SeqIO
import matplotlib.pyplot as plt
import glob
import sys


bam_dir=sys.argv[1]
#'/scratch/groups/dpwall/personal/chloehe/unmapped_reads/bam'
bam_mappings = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/data/bam_mappings.csv', sep='\t')
bam_mappings.index = bam_mappings.sample_id
samples = [a.split('/')[-2] for a in glob.glob(bam_dir +'/*/')]
print(samples)

def make_alignment_table(idx, mapq_thresh=40):
    print(idx)
    df = pd.read_csv(bam_dir + '/%s/%s.final_alignment_table.csv' % (idx,idx))
    df['name'] = idx
    df.loc[df.R1_MAPQ<mapq_thresh,'R1_ref'] = 'lowmapq'
    df.loc[df.R2_MAPQ<mapq_thresh,'R2_ref'] = 'lowmapq'
    df = df.groupby(['R1_ref', 'R2_ref', 'is_proper_pair', 'name']).count()
    alignments_no_index = df.reset_index()
    alignments = alignments_no_index.sort_values(
        'Unnamed: 0', ascending=False)
    return alignments
alignments = [make_alignment_table(idx) for idx in samples[:10]]
alignments = pd.concat(alignments)
alignments = alignments.drop(['R1_start', 'R1_MAPQ', 'R1_is_reverse', 'R2_start', 'R2_MAPQ', 'R2_is_reverse'], axis=1)
alignments.columns = ['R1_ref', 'R2_ref', 'is_proper_pair', 'sample_id', 'count']
alignments = alignments.sort_values('count', ascending=False)
alignments.to_csv(
    '/scratch/groups/dpwall/personal/briannac/unmapped_reads/results/microbes/batch_'+ bam_dir.split('batch_')[-1] +'_alignment_counts.csv')

'''



def make_microbe_alignment_table(idx, mapq_thresh=40, batch='00514'):
    print(idx)
    df = pd.read_csv(bam_dir + '/batch_%s/%s/%s.final_alignment_table.csv' % (batch, idx,idx))
    df['name'] = idx
    df.loc[df.R1_MAPQ<mapq_thresh,'R1_ref'] = 'lowmapq'
    df.loc[df.R2_MAPQ<mapq_thresh,'R2_ref'] = 'lowmapq'
    df = df.groupby(['R1_ref', 'R2_ref', 'is_proper_pair', 'name']).count()
    alignments_no_index = df.reset_index()
    alignments = alignments_no_index[[(((a[:2]!='MH') & (a[:3]!='chr') & (a!='unmapped') & (a[:3]!='HLA')) | 
                                       ((b[:2]!='MH') & (b[:3]!='chr') & (b!='unmapped') & (b[:3]!='HLA'))) for a,b in zip(
        alignments_no_index.R1_ref,alignments_no_index.R2_ref)]].sort_values(
        'Unnamed: 0', ascending=False)
    return alignments
batch='01013'
alignments_microbe = [make_microbe_alignment_table(idx, batch=batch) for idx in samples]
alignments_microbe = pd.concat(alignments_microbe)
alignments_microbe = alignments_microbe.drop(['R1_start', 'R1_MAPQ', 'R1_is_reverse', 'R2_start', 'R2_MAPQ', #'R2_is_reverse'], axis=1)
alignments_microbe.columns = ['R1_ref', 'R2_ref', 'is_proper_pair', 'sample_id', 'count']
alignments_microbe = alignments_microbe.sort_values('count', ascending=False)
alignments_microbe.to_csv(
    '/scratch/groups/dpwall/personal/briannac/unmapped_reads/results/microbes/batch_'+ batch +'_microbe_counts.csv')



### Alt. haplotypes

def make_NUI_alignment_table(idx, mapq_thresh=40, batch='00514'):
    print(idx)
    df = pd.read_csv(bam_dir + '/batch_%s/%s/%s.final_alignment_table.csv' % (batch, idx,idx))
    df['name'] = idx
    df.loc[df.R1_MAPQ<mapq_thresh,'R1_ref'] = 'lowmapq'
    df.loc[df.R2_MAPQ<mapq_thresh,'R2_ref'] = 'lowmapq'
    df = df.groupby(['R1_ref', 'R2_ref', 'is_proper_pair', 'name']).count()
    alignments_no_index = df.reset_index()
    alt_haps = alignments_no_index[[(a[:2]=='MH') | (b[:2]=='MH') for a,b in zip(
        alignments_no_index.R1_ref,alignments_no_index.R2_ref)]].sort_values(
        'Unnamed: 0', ascending=False)
    return alt_haps

alignments_alt = [make_NUI_alignment_table(idx, batch=batch) for idx in samples]
alignments_alt = pd.concat(alignments_alt)
#alignments_alt = alignments_alt[0]
alignments_alt = alignments_alt.drop(['R1_start', 'R1_MAPQ', 'R1_is_reverse', 'R2_start', 'R2_MAPQ', 'R2_is_reverse'], axis=1)
alignments_alt.columns = ['R1_ref', 'R2_ref', 'is_proper_pair', 'sample_id', 'count']
alignments_alt = alignments_alt.sort_values('count', ascending=False)

alignments_alt.to_csv(
    '/scratch/groups/dpwall/personal/briannac/unmapped_reads/results/alt_haplotypes/batch_'+ batch +'_alt_hap_counts.csv')


def make_NUI_alignment_table(idx, mapq_thresh=40, batch='00514'):
    print(idx)
    df = pd.read_csv(bam_dir + '/batch_%s/%s/%s.final_alignment_table.csv' % (batch, idx,idx))
    df['name'] = idx
    df.loc[df.R1_MAPQ<mapq_thresh,'R1_ref'] = 'lowmapq'
    df.loc[df.R2_MAPQ<mapq_thresh,'R2_ref'] = 'lowmapq'
    df = df.groupby(['R1_ref', 'R2_ref', 'is_proper_pair', 'name']).count()
    alignments_no_index = df.reset_index()
    alt_haps = alignments_no_index[[(a[:3]=='chr') | (b[:3]=='chr') for a,b in zip(
        alignments_no_index.R1_ref,alignments_no_index.R2_ref)]].sort_values(
        'Unnamed: 0', ascending=False)
    return alt_haps

alignments_improper = [make_NUI_alignment_table(idx, batch=batch) for idx in samples]
alignments_improper = pd.concat(alignments_improper)
#alignments_alt = alignments_alt[0]
alignments_improper = alignments_improper.drop(['R1_start', 'R1_MAPQ', 'R1_is_reverse', 'R2_start', 'R2_MAPQ', 'R2_is_reverse'], axis=1)
alignments_improper.columns = ['R1_ref', 'R2_ref', 'is_proper_pair', 'sample_id', 'count']
alignments_improper = alignments_improper.sort_values('count', ascending=False)

alignments_improper.to_csv(
    '/scratch/groups/dpwall/personal/briannac/unmapped_reads/results/alt_haplotypes/batch_'+ batch +'_alt_hap_counts.csv')
'''
                                              