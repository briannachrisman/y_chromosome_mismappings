import sys
import numpy as np
from skbio.stats.composition import clr

file_name = sys.argv[1]
#norm_depth = int(sys.argv[2])

with open(file_name) as f:
    lines = f.read().splitlines()

try:
    idx = lines[0]
except: 
    print(file_name, 'bad')
print(len(lines))
pileups = np.array([int(i) for i in lines[1:]])
pileups_norm = clr(pileups) #pileups/(sum(pileups))*len(pileups)
print(len(pileups), sum(pileups))
#norm = len(pileups)/norm_depth

with open(file_name + '.norm', 'w') as f:
    f.write(idx + '\n')
    for i,j in zip(pileups, pileups_norm):
        if pileups==0:
            f.write("0f\n" % i)
        else:
            f.write("%.10f\n" % j)
        
