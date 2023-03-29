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




chunks=[i for i in range(1,num_chunks+1)]


#RULES

rule all:
    input:
        # expand(sqtl_output_dir+"{cond}/chunk_"+window_name+"_{cond}_{PC}_PCs.{current_chunk}.output.txt",cond=conds,PC=PCs,current_chunk=chunks),expand(sqtl_output_dir+"{cond}/chunk_"+window_name+"_{cond}_{PC}_PCs.{current_chunk}.log",cond=conds,PC=PCs,current_chunk=chunks)
        expand(sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.sorted.txt.gz.tbi",cond=conds,PC=PCs)
rule tabixOutput:
    input:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.sorted.txt.gz"
    output:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.sorted.txt.gz.tbi"
    resources:
        mem_mb=1000
    shell:
        "tabix -0 -s 2 -b 3 -e 4 -f {input}"
rule bgzipOutput:
    input:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.sorted.txt"
    output:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.sorted.txt.gz"
    resources:
        mem_mb=1000
    shell:
        "bgzip -f {input}"

rule sortOutput:
    input:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.txt"
    output:
        temp(sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.sorted.txt")
    resources:
        mem_mb=1000
    run:
        import pandas as pd
        dat=pd.read_csv(input[0],sep=' ',header=None)
        dat[1]=dat[1].str[3:].astype(int)
        dat=dat.sort_values(by=[1,2],ascending=True)
        dat[1]='chr'+dat[1].astype(str)
        dat=dat.dropna()
        dat.to_csv(output[0],sep='\t',index=False,header=False)
