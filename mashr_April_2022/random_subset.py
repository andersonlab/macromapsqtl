import pandas as pd
import numpy as np
import random
import sys

summstat_f=sys.argv[1]
allowed_introns_f=sys.argv[2]
target_samples_num=int(sys.argv[3])
seed=sys.argv[4]
output_f=sys.argv[5]



random.seed(seed)

# summstat_f='/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/sqtl_nominal_output_April_2022/Ctrl_24/chunk_1mb_Ctrl_24_6_PCs.31.output.tab.sorted.gz'
# output_f="/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/effect_lists/effect_list_random_chunk_31.txt"
# target_samples_num=20
allowed_introns_list=(pd.read_csv(allowed_introns_f,sep='\t',header=None))[0].tolist()

dat=pd.read_csv(summstat_f,sep='\t',header=None)
dat['gene_intron']=dat[0]+"|"+(dat[5].str.split(':',expand=True)).loc[:,0:2].agg(':'.join,axis=1)
dat=dat.loc[dat['gene_intron'].isin(allowed_introns_list),:]
num_lines=dat.shape[0]


sample_lines=random.sample([i for i in range(0,num_lines)],target_samples_num)
sampled_dat=dat.iloc[sample_lines,[0,5,9]].reset_index(drop=True)

sampled_dat[5]=(sampled_dat[5].str.split(':',expand=True)).loc[:,0:2].agg(':'.join,axis=1)
sampled_dat[5]=sampled_dat[0]+"|"+sampled_dat[5]


sampled_dat.loc[:,[5,9]].to_csv(output_f,sep='\t',header=False,index=False)
