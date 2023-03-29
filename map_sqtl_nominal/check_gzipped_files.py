import pandas as pd
import sys

#Utility script to check if gzipped file that are output from the snakemake pipeline have the same content of flat files
#For some reason gzipped files were not complete and I couldn't find a quick tool to check if gzipped_file==flat_file
flat_file=sys.argv[1]
gzipped_file=sys.argv[2]

flat_dat=pd.read_csv(flat_file,sep='\t')
flat_dat_rows=flat_dat.shape[0]
gzipped_dat=pd.read_csv(gzipped_file,sep='\t')
gzipped_dat_rows=gzipped_dat.shape[0]

equal=0
if gzipped_dat_rows==flat_dat_rows:
    equal=1

print('{0}\t{1}\t{2}\t{3}\t{4}'.format(flat_file,flat_dat_rows,gzipped_file,gzipped_dat_rows,equal))
