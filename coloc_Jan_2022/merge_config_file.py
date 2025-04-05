import pandas as pd
import numpy as np

all_conf=pd.DataFrame()
for idx,input_f in enumerate(snakemake.input):
  conf=pd.read_csv(input_f,sep='\t',header=None).rename(columns={0:'pheno',1:'region',2:'input_f'})
  if idx == 0:
    all_conf=conf
  else:
    all_conf=all_conf.merge(conf,on='region',how='inner')
cols=['region']+np.delete(all_conf.columns.values,np.where(all_conf.columns.values=='region')).tolist()
all_conf[cols].to_csv(snakemake.output[0],sep='\t',index=False,header=False)
