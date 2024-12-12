import pandas as pd
import sys
import time
from fractions import Fraction
import argparse
import re

parser = argparse.ArgumentParser(description='Find links ratio estimate and formats it for pygenometracks')
parser.add_argument('--counts-file', dest='counts_file', type=str, help='Intron Clustering counts file')
parser.add_argument('--clusters', dest='clusters', type=str,nargs='+',help='Cluster to plot')
parser.add_argument('--region-chr', dest='region_chr', required=False,type=str,help='Chr of region to plot')
parser.add_argument('--region-s', dest='region_s', type=str,help='start of region to plot')
parser.add_argument('--region-e', dest='region_e', type=str,help='end of region to plot')
parser.add_argument('--samples', dest='samples', type=str,nargs='+',help='samples')
parser.add_argument('--output-file', dest='output_file', type=str,help='output file')
args = parser.parse_args()

counts_file=args.counts_file
region_chr=args.region_chr
region_s=args.region_s
region_e=args.region_e
output_file=args.output_file
samples=args.samples
clus=args.clusters

dat=pd.read_csv(counts_file,sep='\t')



clus_no_cond=[]
if len(clus) > 0:
    clus_no_cond=[re.split('_',c) for c in clus]
    clus_no_cond=[ '_'.join(c[:3]) for c in clus_no_cond ]


#Loading intron usage ratio data


samples_cols=list(dat.columns.intersection(set(samples) ) )
print('Obtaining data for {0} sample'.format(len(samples_cols)))
dat=dat.loc[:,['intron']+samples_cols]
#Converting intron  names to coordinates
dat[['chr','s','e','clu']]=dat['intron'].str.split(':',expand=True)

#Formatting coordinate columns
dat['chr']=pd.Series([str(chr) if chr.startswith('chr') else 'chr'+str(chr) for chr in dat['chr'].astype(str).tolist()])
dat['s']=dat['s'].astype(int)
dat['e']=dat['e'].astype(int)
#Subsetting introns
#1.Select all introns within that region
for c in clus_no_cond:
    print(c)
    print(dat)
    dat=dat.loc[dat['clu']==c,:]
    if dat.empty:
        links_dat=pd.DataFrame()
        links_dat.to_csv(output_file,sep='\t',header=False,index=False )
        print('No clusters detected. Outputting empty links file..')
        exit()
#Removing samples containing '0/0'
dat=dat.loc[:, ~(dat == '0/0').any()]
remaining_samples_cols=list(dat.columns.intersection(set(samples) ) )
dat.loc[:,remaining_samples_cols]=dat.loc[:,remaining_samples_cols].applymap(lambda elem: 0 if elem == '0/0' else float(Fraction(elem)) )

#2.Averaging across samples and removing low ratio introns
dat=dat.melt(id_vars=['chr','s','e','clu','intron'],var_name='sample',value_name='intron_usage')
dat=dat.groupby(['chr','s','e','clu','intron']).agg('mean').reset_index()

#3.Creating new data frame as required by pygenometracks
links_dat=pd.DataFrame({0:dat.chr.tolist(), 1:dat.s.tolist(), 2:dat.s.tolist(), 3:dat.chr.tolist(), 4:dat.e.tolist(), 5: dat.e.tolist(), 6: dat.intron_usage.tolist()})
print('Obtained data for {0} introns'.format(links_dat.shape[0]))
links_dat.to_csv(output_file,sep='\t',header=False,index=False )
