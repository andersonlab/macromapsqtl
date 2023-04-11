import pandas as pd
import sys


#List of intron idx files
intron_list_fs=sys.argv[1].split()
output_f=sys.argv[2]
# intron_list_fs=['/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/sqtl_nominal_output_April_2022/CIL_24/1mb_CIL_24_9_PCs.output.idx','/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/sqtl_nominal_output_April_2022/sLPS_24/1mb_sLPS_24_3_PCs.output.idx']
# output_f='/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/allowed_introns.txt'

#Extracting introns in the format gene|chr:s:e
intron_sets=[pd.read_csv(f,sep='\t',header=None) for f in intron_list_fs]
intron_sets=[df[0].str.split(':',expand=True) for df in intron_sets]
intron_sets=[df.loc[:,0:2].agg(':'.join,axis=1) for df in intron_sets]
intron_sets=[set(s.tolist()) for s in intron_sets]

#Finding intersections of gene|chr:s:e in all conditions
allowed_introns=list(set.intersection(*intron_sets))

allowed_introns_df=pd.DataFrame(allowed_introns)
allowed_introns_df.to_csv(output_f,sep='\t',header=False,index=False)
# allowed_introns_df[[0,1]]=allowed_introns_df[0].str.split('|',expand=True)
# print(allowed_introns_df)
# intron_dfs=[pd.read_csv(f,sep='\t',header=None) for f in intron_list_fs]
# allowed_intron_dfs=[]
# for df in intron_dfs:
#     df[['gene_c','s','e','clu']]=df[0].str.split(':',expand=True)
#     df['gene_intron']=df.loc[:,['gene_c','s','e']].agg(':'.join,axis=1)
#     allowed_intron_df=df.loc[df['gene_intron'].isin(allowed_introns),['gene_intron',1]]
#     allowed_intron_df['gene_intron']=allowed_intron_df['gene_intron']+":"+df['clu']
#     allowed_intron_df=allowed_intron_df.reset_index(drop=True)
#     allowed_intron_dfs.append(allowed_intron_df)
# for a in allowed_intron_dfs:
#     print(a)
