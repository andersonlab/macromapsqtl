import pandas as pd
import sys
import multiprocessing
from pathlib import Path


def find_summstat_file(effect_dat,idx_dat):
    idx_dat_noclu=idx_dat
    idx_dat_noclu['intron_gene_noclu']=(idx_dat[0].str.split(':',expand=True)).loc[:,0:2].agg(':'.join,axis=True)
    lookup_dat=effect_dat.merge(idx_dat_noclu,how='left',left_on=[0],right_on=['intron_gene_noclu'],suffixes=['_eff','_idx'])
    return lookup_dat.loc[:,['0_idx','1_eff','1_idx']]

def get_summstats_from_effect_summstat_file_dat(summstat_f,eff_summstat_file_dat):

    #Creating gene|intron column
    summstat_dat=pd.read_csv(summstat_f,sep='\t',header=None)
    summstat_dat['gene_intron']=summstat_dat[0]+"|"+summstat_dat[5]

    #Looking up effects in appropriate summstat
    eff_summstat_dat=eff_summstat_file_dat.loc[:,['0_idx','1_eff']].merge(summstat_dat,how='left',left_on=['0_idx','1_eff'],right_on=['gene_intron',9])

    #Subsetting relevant data
    beta_se_dat=eff_summstat_dat.loc[:,['0_idx','1_eff',15,16]].rename(columns={'0_idx':'gene_intron','1_eff':'snp',15:'beta',16:'se'})

    return beta_se_dat

effect_list_f=sys.argv[1]
idx_f=sys.argv[2]
output_f=sys.argv[3]

all_summstats=pd.DataFrame()
if Path(effect_list_f).stat().st_size > 0:
    effect_dat=pd.read_csv(effect_list_f,sep='\t',header=None).loc[:,[0,1]]
    idx_dat=pd.read_csv(idx_f,sep='\t',header=None).loc[:,[0,1]]

    effect_summstat_file_dat=find_summstat_file(effect_dat,idx_dat)

    all_beta_se_dat=pd.DataFrame()

    summstat_groups=list(effect_summstat_file_dat.groupby('1_idx'))

    #This was an attempt to parallelize but it doesn't make a difference in our pipeline anymore
    with multiprocessing.Pool(processes=1) as pool:
        results = pool.starmap(get_summstats_from_effect_summstat_file_dat, summstat_groups)

    all_summstats=pd.DataFrame()
    for df in results:
        all_summstats=all_summstats.append(df,ignore_index=True)
all_summstats.to_csv(output_f,sep='\t',header=False,index=False)
