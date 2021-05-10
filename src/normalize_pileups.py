import sys
import numpy as np

file_name = sys.argv[1]
pileups = {}
for pileup_type in ['proper', 'improper', 'unmapped']:
    with open(file_name + pileup_type + '.txt') as f:
        lines = f.read().splitlines()
    try:
        idx = lines[0]
    except: 
        print(file_name, 'does not exist!')
    pileups[pileup_type] = np.array([int(i) for i in lines[1:]])
pileups = pileups['proper'] + pileups['improper'] + pileups['unmapped']

sum_pileups = sum(pileups)
if sum_pileups==0:
    print(file_name, " has sum 0!!!")
pileups_norm = pileups/sum_pileups*len(pileups)

with open(file_name + 'norm', 'w') as f:
    f.write(idx + '\n')
    for i,j in zip(pileups, pileups_norm):
        if i==0:
            f.write("0\n" % i)
        else:
            f.write("%.4f\n" % j)