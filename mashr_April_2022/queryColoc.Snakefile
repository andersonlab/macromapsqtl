

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
		mash_output_dir+"summstats/coloc75/coloc.all.txt"

rule list_coloc_introns:
	input:
		coloc_f=coloc_output_dir+"all.sqtl.coloc",idx_f=sqtl_output_dir+"{cond}/1mb_{cond}_{PC}_PCs.output.idx"
	output:
		expand(mash_output_dir+'intron_lists/coloc75/coloc_chunk_{chunk}_{{cond}}_{{PC}}_PCs.idx',chunk=chunks)
	params:
		conds=conds,
		PCs=PCs,
		chunks=chunks,
		sqtl_output_dir=sqtl_output_dir
	resources:
		mem_mb=8000
	run:
		import pandas as pd
		import itertools

		thresh = 0.75
		coloc_intron_col=7
		coloc_PP4_col=5
		idx_intron_col=0

		splits=[ (wildcards.cond,wildcards.PC,x) for x in chunks]

		idx_dat=pd.read_csv(input['idx_f'],sep='\t',header=None)
		coloc_dat=pd.read_csv(input['coloc_f'],sep='\t',header=None)

		high_coloc_dat=coloc_dat.loc[coloc_dat[coloc_PP4_col] >= thresh,:]
		lookup_dat=high_coloc_dat.merge(idx_dat,how='inner',left_on=[coloc_intron_col],right_on=[idx_intron_col],suffixes=['_coloc','_idx'])
		# print(lookup_dat.head(10).loc[:,['1_idx']].to_csv(sep='\t'))
		for i,split in enumerate(splits):
			output_f=output[i]
			cond,PC,chunk=split
			f=params['sqtl_output_dir']+cond+"/chunk_1mb_"+cond+"_"+PC+"_PCs."+chunk+".output.tab.sorted.gz"
			chunked_coloc=lookup_dat.loc[lookup_dat['1_idx']==f,['0_idx','1_idx']]

			chunked_coloc.to_csv(output_f,sep='\t',header=False,index=False)
rule get_coloc_lead_sqtl_effects:
	input:
		mash_output_dir+'intron_lists/coloc75/coloc_chunk_{chunk}_{cond}_{PC}_PCs.idx'
	output:
		mash_output_dir+'effect_lists/coloc75/coloc_chunk_{chunk}_{cond}_{PC}_PCs.txt'
	params:
		mash_scripts_dir=mash_scripts_dir
	resources:
		mem_mb=64000
	shell:
		"python {params.mash_scripts_dir}get_lead_effects.py {input} {output}"
rule collect_effects_coloc:
	input:
		expand(expand(mash_output_dir+'effect_lists/coloc75/coloc_chunk_{chunk}_{{cond}}_{{PC}}_PCs.txt',chunk=chunks),zip,cond=conds,PC=PCs)
	output:
		mash_output_dir+'effect_lists/coloc75/coloc.txt'
	params:
		mash_scripts_dir=mash_scripts_dir
	resources:
		mem_mb=4000
	shell:
		"cat {input} | awk 'BEGIN{{FS=\"\\t\"}}{{if(!seen[$1,$2]++)print}}' > {output}"
rule split_effects_coloc:
	input:
		effect_f=mash_output_dir+"effect_lists/coloc75/coloc.txt",idx_f=sqtl_output_dir+"{cond}/1mb_{cond}_{PC}_PCs.output.idx"
	output:
		expand(mash_output_dir+"effect_lists/coloc75/coloc_split_chunk_{chunk}_{{cond}}_{{PC}}_PCs.txt",chunk=chunks)
	params:
		conds=conds,
		PCs=PCs,
		chunks=chunks,
		sqtl_output_dir=sqtl_output_dir
	resources:
		mem_mb=8000
	script:
		"split_effects.py"

rule get_summstats_coloc:
	input:
		effect_f=mash_output_dir+"effect_lists/coloc75/coloc_split_chunk_{chunk}_{cond}_{PC}_PCs.txt",idx_f=sqtl_output_dir+"{cond}/1mb_{cond}_{PC}_PCs.output.idx"
	output:
		mash_output_dir+"summstats/coloc75/coloc_chunk_{chunk}.{cond}.{PC}_PCs.txt"
	params:
		mash_scripts_dir=mash_scripts_dir
	resources:
		mem_mb=64000
	shell:
		"python {params.mash_scripts_dir}get_summstats.py {input.effect_f} {input.idx_f} {output}"

#TODO separate processing from collection as it takes time to process serially
rule collect_allchunks_summstats_coloc:
	input:
		expand(mash_output_dir+"summstats/coloc75/coloc_chunk_{chunk}.{{cond}}.{{PC}}_PCs.txt",chunk=chunks)
	output:
		mash_output_dir+"summstats/coloc75/coloc.{cond}.{PC}_PCs.txt"
	resources:
		mem_mb=8000
	params:
		mash_scripts_dir=mash_scripts_dir
	shell:
		"python {params.mash_scripts_dir}collect_cond_summstats.py \"{input}\" {output}"
rule collect_allconds_summstats_coloc:
	input:
		expand(mash_output_dir+"summstats/coloc75/coloc.{cond}.{PC}_PCs.txt",zip,cond=conds,PC=PCs)
	output:
		mash_output_dir+"summstats/coloc75/coloc.all.txt"
	resources:
		mem_mb=8000
	params:
		mash_scripts_dir=mash_scripts_dir
	shell:
		"cat {input} > {output}"
