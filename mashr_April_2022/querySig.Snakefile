

from pathlib import Path
import glob
import subprocess as sp
import pandas as pd
import numpy as np
# shell.prefix("set +o pipefail;")

conds=config['conds'].split()
PCs=config['PCs'].split()
sqtl_output_dir=config['sqtl_output_dir']
mash_scripts_dir=config['mash_scripts_dir']
mash_output_dir=config['mash_output_dir']
target_sample=config['samples_per_chunk']
num_chunks=int(config['chunks'])
seed=config['seed']
permutation_sqtl_output_dir=config['permutation_sqtl_output_dir']
coloc_output_dir=config['coloc_output_dir']
sample_effects_cond="Ctrl_24"
sample_effects_PC="6"



chunks=[str(i+1) for i in range(int(num_chunks))]


###DEBUG###
# conds=['Ctrl_6']
# PCs=['7']
######
localrules: collect_effects

#RULES
wildcard_constraints:
	chunk=r"|".join(set(chunks)),
	cond=r"|".join(set(conds)),
	PC=r"|".join(set(PCs))

rule all:
	input:
		mash_output_dir+"summstats/sig/sig.all.txt"

rule get_effects_sig:
	input:
		permutation_sqtl_output_dir+'{cond}/1mb_{cond}_{PC}_PCs.output.FDR.0.05.txt'
	output:
		mash_output_dir+'effect_lists/sig/sig_{cond}_{PC}_PCs.txt'
	params:
		mash_scripts_dir=mash_scripts_dir
	resources:
		mem_mb=4000
	run:
		import pandas as pd

		input_f=input[0]
		output_f=output[0]
		sig_dat=pd.read_csv(input_f,sep=' ',header=None)

		sig_dat=sig_dat.loc[:,[0,5,9]]
		sig_dat[0]=sig_dat[0]+"|"+sig_dat[5]
		sig_dat[0]=(sig_dat[0].str.split(':',expand=True)).loc[:,0:2].agg(':'.join,axis=1)

		effects_list=sig_dat.loc[:,[0,9]]

		effects_list.to_csv(output_f,sep='\t',header=False,index=False)

rule collect_sig_effects:
	input:
		expand(mash_output_dir+"effect_lists/sig/sig_{cond}_{PC}_PCs.txt",zip,cond=conds,PC=PCs)
	output:
		mash_output_dir+'effect_lists/sig/sig.txt'
	params:
		mash_scripts_dir=mash_scripts_dir
	resources:
		mem_mb=4000
	shell:
		"cat {input} | awk 'BEGIN{{FS=\"\\t\"}}{{if(!seen[$1,$2]++)print}}' > {output}"
rule split_effects_sig:
	input:
		effect_f=mash_output_dir+"effect_lists/sig/sig.txt",idx_f=sqtl_output_dir+"{cond}/1mb_{cond}_{PC}_PCs.output.idx"
	output:
		expand(mash_output_dir+"effect_lists/sig/sig_split_chunk_{chunk}_{{cond}}_{{PC}}_PCs.txt",chunk=chunks)
	params:
		conds=conds,
		PCs=PCs,
		chunks=chunks,
		sqtl_output_dir=sqtl_output_dir
	resources:
		mem_mb=8000
	script:
		"split_effects.py"

rule get_summstats_sig:
	input:
		effect_f=mash_output_dir+"effect_lists/sig/sig_split_chunk_{chunk}_{cond}_{PC}_PCs.txt",idx_f=sqtl_output_dir+"{cond}/1mb_{cond}_{PC}_PCs.output.idx"
	output:
		mash_output_dir+"summstats/sig/sig_chunk_{chunk}.{cond}.{PC}_PCs.txt"
	params:
		mash_scripts_dir=mash_scripts_dir
	resources:
		mem_mb=64000
	shell:
		"python {params.mash_scripts_dir}get_summstats.py {input.effect_f} {input.idx_f} {output}"

#TODO separate processing from collection as it takes time to process serially
rule collect_allchunks_summstats_sig:
	input:
		expand(mash_output_dir+"summstats/sig/sig_chunk_{chunk}.{{cond}}.{{PC}}_PCs.txt",chunk=chunks)
	output:
		mash_output_dir+"summstats/sig/sig.{cond}.{PC}_PCs.txt"
	resources:
		mem_mb=8000
	params:
		mash_scripts_dir=mash_scripts_dir
	shell:
		"python {params.mash_scripts_dir}collect_cond_summstats.py \"{input}\" {output}"
rule collect_allconds_summstats_sig:
	input:
		expand(mash_output_dir+"summstats/sig/sig.{cond}.{PC}_PCs.txt",zip,cond=conds,PC=PCs)
	output:
		mash_output_dir+"summstats/sig/sig.all.txt"
	resources:
		mem_mb=8000
	params:
		mash_scripts_dir=mash_scripts_dir
	shell:
		"cat {input} > {output}"
