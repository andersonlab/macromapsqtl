import pandas as pd
import itertools



splits=[ (snakemake.wildcards['cond'],snakemake.wildcards['PC'],x) for x in snakemake.params['chunks']]

idx_dat=pd.read_csv(snakemake.input['idx_f'],sep='\t',header=None)
effect_dat=pd.read_csv(snakemake.input['effect_f'],sep='\t',header=None)
idx_dat[0]=(idx_dat[0].str.split(':',expand=True)).loc[:,0:2].agg(':'.join,axis=True)
lookup_dat=effect_dat.merge(idx_dat,how='left',left_on=[0],right_on=[0],suffixes=['_eff','_idx'])

for i,split in enumerate(splits):
  output_f=snakemake.output[i]
  cond,PC,chunk=split
  f=snakemake.params['sqtl_output_dir']+cond+"/chunk_1mb_"+cond+"_"+PC+"_PCs."+chunk+".output.tab.sorted.gz"
  chunked_eff=lookup_dat.loc[lookup_dat['1_idx']==f,[0,'1_eff']]
  chunked_eff.to_csv(output_f,sep='\t',header=False,index=False)
