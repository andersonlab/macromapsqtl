

from pathlib import Path
import glob
import subprocess as sp
# shell.prefix("set +o pipefail;")


sqtl_output_dir=config['sqtl_output_dir']
window_name=config['window_name']
window=config['window']

conds=config['conds'].split(' ')
PCs=config['PCs'].split(' ')
num_chunks=config['chunks']


total_chunks=num_chunks


# conds=['CIL_24']
# PCs=['9']

num_chromosomes=22
chunks=[i for i in range(1,num_chunks+1)]
chromosomes=[str(i) for i in range(1,num_chromosomes+1)]
#RULES
# localrules: indexChunks, map_introns_tss
rule all:
    input:
        expand(expand(sqtl_output_dir+"{{cond}}/chunk_"+window_name+"_{{cond}}_{{PC}}_PCs.chr{chr}.output.tab.sorted.gz",chr=chromosomes), zip, cond=conds,PC=PCs),expand(expand(sqtl_output_dir+"{{cond}}/chunk_"+window_name+"_{{cond}}_{{PC}}_PCs.chr{chr}.output.tab.sorted.gz",chr=chromosomes), zip, cond=conds,PC=PCs)
rule collect_per_chr:
    input:
        expand(sqtl_output_dir+"{{cond}}/chunk_"+window_name+"_{{cond}}_{{PC}}_PCs.{current_chunk}.output.tab.sorted.gz",current_chunk=chunks)
    output:
        temp(sqtl_output_dir+"{cond}/chunk_"+window_name+"_{cond}_{PC}_PCs.chr{chr}.output.tab.sorted")
    params:
        chunks=chunks,
        sqtl_output_dir=sqtl_output_dir
    resources:
        mem_mb=64000
    run:
        import pandas as pd
        all_chr_dat=pd.DataFrame()
        for f in input:
            dat=pd.read_csv(f,sep='\t',header=None)
            chr_dat=dat.loc[dat[10]==('chr'+str(wildcards['chr'])),:]
            all_chr_dat=pd.concat([all_chr_dat,chr_dat],ignore_index=True)

            print('Finished file: {0}...'.format(f))
        all_chr_dat=all_chr_dat.sort_values(by=[11],ascending=True)
        all_chr_dat.to_csv(output[0],sep='\t',header=False,index=False)

rule tabixchr:
    input:
        sqtl_output_dir+"{cond}/chunk_"+window_name+"_{cond}_{PC}_PCs.chr{chr}.output.tab.sorted"
    output:
        gzip_f=sqtl_output_dir+"{cond}/chunk_"+window_name+"_{cond}_{PC}_PCs.chr{chr}.output.tab.sorted.gz",tbi_f=sqtl_output_dir+"{cond}/chunk_"+window_name+"_{cond}_{PC}_PCs.chr{chr}.output.tab.sorted.gz.tbi"
    resources:
        mem_mb=8000
    shell:
        "bgzip -c {input} > {output.gzip_f}; tabix -0 -s 11 -b 12 -e 13 -f {output.gzip_f};"
