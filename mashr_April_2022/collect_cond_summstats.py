import pandas as pd
import sys
from pathlib import Path

input_fs=sys.argv[1].split(' ')
output_f=sys.argv[2]

collected_dat=pd.DataFrame()
for f in input_fs:
    if Path(f).stat().st_size > 0:
        dat=pd.read_csv(f,sep='\t',header=None)
        dat['cond']=(dat[0].str.split('_',expand=True)).loc[:,[3,4]].agg('_'.join,axis=1)
        dat[0]=(dat[0].str.split(':',expand=True)).loc[:,0:2].agg(':'.join,axis=1)
        dat=dat.loc[:,[0,'cond',1,2,3]]
        collected_dat=collected_dat.append(dat,ignore_index=True)

collected_dat.to_csv(output_f,sep='\t',header=False,index=False)
