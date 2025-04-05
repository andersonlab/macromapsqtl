

from pathlib import Path
import glob
import subprocess as sp
import pandas as pd
import numpy as np
# shell.prefix("set +o pipefail;")


num_chunks=int(config['chunks'])
padding=config['padding']




tmp_coloc_output_dir=config['tmp_coloc_output_dir']
coloc_res_output_dir=config['coloc_res_output_dir']
sqtl_output_dir=config['sqtl_output_dir']
gene_map_f=config['gene_map_f']
conds=config['conds'].split()
PCs=config['PCs'].split()
gwas_names=config['gwas_names'].split()
# gwas_fs=config['gwas_fs'].split()
gwas_formats=config['gwas_formats'].split()

gwas_output_dir=config['gwas_output_dir']
scripts_dir=config['scripts_dir']
chrom_size_f=config['chrom_size_f']


chunks=[str(i) for i in range(num_chunks)]

# localrules: make_sqtl_config_file, make_gwas_config_file, merge_config_files,split_merged_config_file

#RULES
wildcard_constraints:
	PC=r"|".join(set([str(PC) for PC in PCs])),
	cond = r"|".join(set(conds)),
	GWAS = r"|".join(set(gwas_names)),
	chunk=r"|".join(set(chunks))

rule all:
	input:
		expand(expand(coloc_res_output_dir+"{cond}/{{GWAS}}.{cond}.{PC}_PCs.coloc",zip,cond=conds,PC=PCs),GWAS=gwas_names)


rule make_sqtl_config_file:
	input:
		idx_f=sqtl_output_dir+"{cond}/1mb_{cond}_{PC}_PCs.output.idx",pos_f=sqtl_output_dir+"{cond}/1mb_{cond}_{PC}_PCs.output.tss"
	output:
		sqtl_config_file=tmp_coloc_output_dir+"{cond}/sqtl_coloc_phenotypes.{cond}.{PC}_PCs.txt",
		region_list=tmp_coloc_output_dir+"{cond}/coloc_regions.{cond}.{PC}_PCs.list"
	params:
		padding=padding,
		chrom_size_f=chrom_size_f,
		scripts_dir=scripts_dir
	resources:
		mem_mb=4000
	shell:
		"python {params.scripts_dir}make_gene_list_v2.py -p {input.idx_f} -f {input.pos_f} -c {params.chrom_size_f} -pa {params.padding} -o {output.sqtl_config_file} ; awk 'BEGIN{{FS=\"\\t\"}}{{if(!seen[$2]++)print $2}}' {output.sqtl_config_file} > {output.region_list}"
rule make_gwas_config_file:
	input:
		region_list=tmp_coloc_output_dir+"{cond}/coloc_regions.{cond}.{PC}_PCs.list",gwas_f=gwas_output_dir+"{GWAS}.formatted.sorted.tsv.gz"
	output:
		tmp_coloc_output_dir+"{cond}/gwas_coloc_phenotypes.{GWAS}.{cond}.{PC}_PCs.txt"
	params:
		tmp_coloc_output_dir=tmp_coloc_output_dir,
		scripts_dir=scripts_dir
	resources:
		mem_mb=4000
	shell:
		"python {params.scripts_dir}make_locus_list.py {input.gwas_f} {input.region_list} {wildcards.GWAS} {output}"

rule merge_config_files:
	input:
		tmp_coloc_output_dir+"{cond}/gwas_coloc_phenotypes.{GWAS}.{cond}.{PC}_PCs.txt",tmp_coloc_output_dir+"{cond}/sqtl_coloc_phenotypes.{cond}.{PC}_PCs.txt"

	output:
		tmp_coloc_output_dir+"{cond}/merged_config.{GWAS}.{cond}.{PC}_PCs.txt"
	resources:
		mem_mb=4000
	params:
		tmp_coloc_output_dir=tmp_coloc_output_dir,
		scripts_dir=scripts_dir
	script:
		"merge_config_file.py"
rule split_merged_config_file:
	input:
		tmp_coloc_output_dir+'{cond}/merged_config.{GWAS}.{cond}.{PC}_PCs.txt'
	output:
		expand(tmp_coloc_output_dir+"{{cond}}/merged_config.{{GWAS}}.{{cond}}.{{PC}}_PCs.chunk_{chunk}.txt",chunk=chunks)
	resources:
		mem_mb=4000
	params:
		tmp_coloc_output_dir=tmp_coloc_output_dir,
		num_chunks=num_chunks
	script:
		"split_merged_config_file.py"
#rule create_yaml:
#	output:
#		tmp_coloc_output_dir+'macromap_gwas.yaml'
#	resources:
#		mem_mb=500
#	run:
#		import yaml
#		tr_types=['cc','quant']
#		tr_val_cols=[[5,6,2,3,4],[11, 12, 16, 17, 14, 19, 20]]
#		tr_id_cols=[[10],[1,6]]
#
#		config_dat={'default':{'type': tr_types, 'tr_id_cols':tr_id_cols,'tr_val_cols':tr_val_cols}  }
#
#		with open(output[0],'w') as f:
#			yaml.dump(config_dat,f,default_flow_style=None)
rule run_coloc:
	input:
		config_f=tmp_coloc_output_dir+"{cond}/merged_config.{GWAS}.{cond}.{PC}_PCs.chunk_{chunk}.txt",yaml_f=tmp_coloc_output_dir+'macromap_gwas.yaml'
	output:
		coloc_res_output_dir+"{cond}/{GWAS}.{cond}.{PC}_PCs.chunk_{chunk}.coloc"
	resources:
		mem_mb=32000
	params:
		scripts_dir=scripts_dir
	shell:
		"Rscript {params.scripts_dir}run_coloc.R {input.config_f} {input.yaml_f} {output}"
rule collect_coloc_chunks:
	input:
		expand(coloc_res_output_dir+"{{cond}}/{{GWAS}}.{{cond}}.{{PC}}_PCs.chunk_{chunk}.coloc",chunk=chunks)
	output:
		coloc_res_output_dir+"{cond}/{GWAS}.{cond}.{PC}_PCs.coloc"
	resources:
		mem_mb=2000
	shell:
		"cat {input} > {output}"
