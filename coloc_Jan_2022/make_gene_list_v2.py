import pandas as pd
import sys
import argparse
from sqtlhelpers.funcs import snp_pos_to_region,region_to_chr_s_e,chr_s_e_to_region,window_left_boundary,window_right_boundary,pad_region

parser = argparse.ArgumentParser(description='Makes list of genomic_feature/region/file')
parser.add_argument('--phenotype-path','-p', dest='phenotype_path_f', type=str,required=True, help='genomic_feature/path file')
parser.add_argument('--feature-map','-f', dest='gene_map_f', type=str,required=True, help='genomic_feature/pos file')
parser.add_argument('--chrom-size','-c', dest='chrom_size_f', type=str,required=True, help='chrom/size file')
parser.add_argument('--padding','-pa', dest='padding', type=int,required=True, help='padding')
parser.add_argument('--output','-o', dest='output_config_f', type=str,required=True, help='Output config file')

parser.add_argument('--filter','-fi', dest='filter_f', type=str,required=False, help='genomic features to filter by')
args = parser.parse_args()


phenotype_path_f=args.phenotype_path_f
gene_map_f=args.gene_map_f
chrom_size_f=args.chrom_size_f
padding=args.padding
output_config_f=args.output_config_f

filter_f=args.filter_f

phenotype_id_col='0'
phenotype_path_col='1'

chrpos_loc_map_col='1'
id_loc_map_col='0'

p=padding/2


#Getting chromosome size info
chrom_size_dat=pd.read_csv(chrom_size_f,sep='\t',header=None)
chrom_size_dat.columns = chrom_size_dat.columns.astype(str)
chrom_size_dict={chr:sz for chr,sz in zip(chrom_size_dat['0'].tolist(),chrom_size_dat['1'].tolist())}

#Loading relevant files
gene_map_dat=pd.read_csv(gene_map_f,sep='\t',header=None)
phenotype_path_dat=pd.read_csv(phenotype_path_f,sep='\t',header=None)

gene_map_dat.columns = gene_map_dat.columns.astype(str)
phenotype_path_dat.columns = phenotype_path_dat.columns.astype(str)

#
if filter_f != None:
    filter_pheno=pd.read_csv(filter_f,sep='\t',header=None)[0].tolist()
    phenotype_path_dat=phenotype_path_dat.loc[phenotype_path_dat[phenotype_id_col].isin(filter_pheno),:]
#Joining location and files data
configs=pd.DataFrame({'0':phenotype_path_dat[phenotype_id_col],'1':phenotype_path_dat[phenotype_path_col]})

#Merging gene/file -> center of lookaround region
configs=configs.merge(gene_map_dat,how='left',on='0',suffixes=['_phenotype','_loc_map'])
#Padding region
# print(configs['1_loc_map'])
configs['region']=configs.agg(pad_region,chrpos_col=chrpos_loc_map_col+'_loc_map',p=p,chrom_size_dict=chrom_size_dict,axis=1)


#Formatting final phenotype/region/path file
output_configs=configs.loc[:,['0','region',phenotype_path_col+'_phenotype'] ]

#Writing config file
output_configs.to_csv(output_config_f,sep='\t',header=False,index=False)


# python make_gene_list_v2.py try.idx.txt "$GENCODE_TSS_FILE" "$CHROM_SIZES_HG38" "1000000" "a.txt"
