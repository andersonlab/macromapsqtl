

from pathlib import Path
import glob


cov_dir=config['cov_dir']
sqtl_output_dir=config['sqtl_output_dir']
window_name=config['window_name']
vcf=config['vcf']
qtltools_binary=config['qtltools_binary']
seed=config['seed']
window=config['window']
prepared_sqtl_input_dir=config['prepared_sqtl_input_dir']
permutations=config['permutations']

conds=config['conds'].split(' ')
PCs=config['PCs'].split(' ')
num_chunks=config['chunks']

fdr_sig_script=config['fdr_sig_script']
fdr=config['fdr']


chunks=[i for i in range(1,num_chunks+1)]



rule all:
    input:
        expand(sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.FDR.{fdr}.txt",cond=conds,PC=PCs,fdr=fdr),expand(sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.FDR.{fdr}.list",cond=conds,PC=PCs,fdr=fdr)
rule fdrList:
    input:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.FDR.{fdr}.txt"
    output:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.FDR.{fdr}.list"
    resources:
        mem_mb=1000
    run:
        import pandas as pd
        dat=pd.read_csv(input[0],sep=' ',header=None)
        output_dat=dat[0]+"|"+dat[5]
        output_dat.to_csv(output[0],sep='\t',index=False,header=False)
rule fdrCorrect:
    input:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.sorted.txt.gz"
    output:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.FDR.{fdr}.txt"
    params:
        fdr_sig_script=fdr_sig_script
    resources:
        mem_mb=1000
    shell:
        "Rscript {params.fdr_sig_script} {wildcards.cond} {wildcards.PC} {input} {output} {wildcards.fdr}"
