import numpy as np
import pandas as pd

conf_dat=pd.read_csv(snakemake.input[0],sep='\t',header=None)
conf_dat_chunked=np.array_split(conf_dat, snakemake.params['num_chunks'])
chunks=[i for i in range(snakemake.params['num_chunks'])]
for i,df in enumerate(conf_dat_chunked):
  df.to_csv(snakemake.output[i],sep='\t',header=False,index=False)
  print("Written chunk {0}".format(i))
