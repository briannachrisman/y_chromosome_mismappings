import pandas as pd
from glob import glob
import sys

pairtype = sys.argv[1]

files = glob('/home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/covWAS/*.%s.done' % pairtype)
files = [f.split('/')[-1].replace('.done', '') for f in files]

starts_all = pd.read_table('/home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/chrom_start_stops_intervals.tsv', index_col=0)
unfinished = starts_all.loc[[i for i in starts_all.index if i not in files]]
print(len(unfinished), ' unfinished samples')
unfinished.to_csv(
    '/home/groups/dpwall/briannac/y_chromosome_mismappings/intermediate_files/coverages/chrom_start_stops_intervals_unfinished.tsv',
    sep='\t')