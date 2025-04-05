import pandas as pd
import sys
from sqtlhelpers.funcs import parse_tabix,snp_pos_to_region,region_to_chr_s_e,chr_s_e_to_region,window_left_boundary,window_right_boundary

input_f=sys.argv[1]
regions_list_f=sys.argv[2]
pheno=sys.argv[3]
output_config_file=sys.argv[4]
thresh=0.00000005
regions=pd.read_csv(regions_list_f,sep='\t',header=None)[0].tolist()
input_files=[input_f for _ in range(len(regions))]
phenos=[pheno for _ in range(len(regions))]
configs=pd.DataFrame({0:phenos, 1: regions,2:input_files})



pval_col=3
gw_sig_configs=pd.DataFrame()
for idx,row in configs.iterrows():
    gwas_input_f=row[2]
    gwas_region=row[1]
    gwas_dat=parse_tabix(gwas_input_f,gwas_region,header=None,remove_chr=False)

    if gwas_dat.shape[0] == 0:
        continue
    if (gwas_dat[pval_col] <= thresh).any():
        gw_sig_configs=gw_sig_configs.append(row)
        # print(gw_sig_configs)
        # print('Found GW hit!')
gw_sig_configs.to_csv(output_config_file,sep='\t',header=False,index=False)
