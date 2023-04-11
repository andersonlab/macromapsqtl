import pandas as pd
import sys
from pathlib import Path
idx_f=sys.argv[1]
output_f=sys.argv[2]

snp_col=9
gene_col=0
intron_col=5
pval_col=13
beta_col=15
se_col=16

all_min_effects=pd.DataFrame()
if Path(idx_f).stat().st_size > 0:

    idx_dat=pd.read_csv(idx_f,sep='\t',header=None)

    for summstat_f,df in idx_dat.groupby(1):



        summstat_dat=pd.read_csv(summstat_f,sep='\t',header=None)

        #Formatting gene/intron column
        summstat_dat.loc[:,'gene_intron']=summstat_dat[0]+"|"+summstat_dat[5]
        summstat_dat.loc[:,'gene_intron']=(summstat_dat['gene_intron'].str.split(':',expand=True)).loc[:,0:2].agg(':'.join,axis=1)

        idx_dat.loc[:,0]=(idx_dat[0].str.split(':',expand=True)).loc[:,0:2].agg(':'.join,axis=1)

        #Filtering for only query introns
        intron_summstat_file_dat=summstat_dat.loc[summstat_dat['gene_intron'].isin(idx_dat[0].tolist()),:]

        #Grouping by gene/intron and choosing top SNP
        intron_summstat_file_dat.loc[:,'min_pval']=intron_summstat_file_dat.groupby(['gene_intron'])[pval_col].transform('min')

        min_effects=intron_summstat_file_dat.loc[intron_summstat_file_dat[pval_col]==intron_summstat_file_dat['min_pval'],:]

        #Dropping duplicate rows that match the min P-value (gene/intron duplicates) and choosing only gene/intron/snp/pval columns
        min_effects=min_effects.drop_duplicates(subset=['gene_intron'])
        min_effects=min_effects.loc[:,['gene_intron',snp_col]]

        # print(min_effects)
        #Saving list
        all_min_effects=all_min_effects.append(min_effects,ignore_index=True)
        # min_effects.to_csv(output[0],sep='\t',header=False,index=False)
all_min_effects.to_csv(output_f,sep='\t',header=False,index=False)
