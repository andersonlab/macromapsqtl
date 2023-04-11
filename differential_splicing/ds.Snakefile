from pathlib import Path
import glob
import subprocess as sp
import pandas as pd
import numpy as np
import itertools
shell.prefix("set +o pipefail;")

ds_groupings_output_dir=config['ds_groupings_output_dir']
ds_counts_output_dir=config['ds_counts_output_dir']
ds_output_dir=config['ds_output_dir']
ds_pipeline_dir=config['ds_pipeline_dir']
realigned_bam_dir=config['realigned_bam_dir']
leafcutter_ds_script=config['leafcutter_ds_script']
ds_results_output_dir=config['ds_results_output_dir']
exons_file=config['exons_file']
intron_clustering_dir=config['intron_clustering_dir']
conds=config['conds'].split()
base_conds=config['base_conds'].split()
timeout_sec='900'
min_samples_per_group='50'
min_samples_per_intron='50'
min_coverage='30'
num_chunks=100
chunks=[i for i in range(num_chunks)]

# localrules: create_grouping_file,add_covariates_to_grouping_file,collect_counts_file,run_ds



wildcard_constraints:
	chunk = r"|".join(set([str(x) for x in chunks])),
	base_cond = r"|".join(set(base_conds)),
	cond = r"|".join(set(conds))

rule all:
    input:
        expand(ds_results_output_dir+'{base_cond}_vs_{cond}_timeout_'+timeout_sec+'_cluster_significance.txt',zip,base_cond=base_conds,cond=conds),expand(ds_results_output_dir+'{base_cond}_vs_{cond}_timeout_'+timeout_sec+'_effect_sizes.txt',zip,base_cond=base_conds,cond=conds)

rule create_grouping_file:
    output:
        ds_groupings_output_dir+"{base_cond}_vs_{cond}_nocovars.grouping"
    params:
        realigned_bam_dir=realigned_bam_dir,
        ds_pipeline_dir=ds_pipeline_dir
    resources:
        mem_mb=1000
    shell:
        "bash {params.ds_pipeline_dir}create_groupings_file.sh {wildcards.base_cond} {wildcards.cond} {params.realigned_bam_dir} {output}"
rule add_covariates_to_grouping_file:
    input:
        grouping_file=ds_groupings_output_dir+"{base_cond}_vs_{cond}_nocovars.grouping",base_cond_covar_file="/lustre/scratch119/realdata/mdt3/teams/gaffney/np12/MacroMap/Analysis/eQTLs/Macromap_fds/{base_cond}/covariates/covariates_{base_cond}.txt",cond_covar_file="/lustre/scratch119/realdata/mdt3/teams/gaffney/np12/MacroMap/Analysis/eQTLs/Macromap_fds/{cond}/covariates/covariates_{cond}.txt"
    output:
        ds_groupings_output_dir+"{base_cond}_vs_{cond}_withcovars.grouping"
    resources:
        mem_mb=1000
    run:
        import pandas as pd
        covars=['RunID','Donor','Library_prep','Sex','Differentiation_media','Purity_result_per','Estimated_cell_diameter','Differentiation_time_No_Days']

        #Loading file to be annotated + annotation files (covars)
        base_cond_covar_dat=pd.read_csv(input.base_cond_covar_file,sep='\t')
        cond_covar_dat=pd.read_csv(input.cond_covar_file,sep='\t')
        grouping_dat=pd.read_csv(input.grouping_file,sep='\t',header=None)

        #Creating the covar df
        all_covar_dat=pd.concat([cond_covar_dat, base_cond_covar_dat],ignore_index=True)
        all_covar_dat['RunID']='R'+all_covar_dat['RunID'].astype(str)
        all_covar_dat=all_covar_dat.replace(' ','_',regex=True)

        #Processing Grouping file sample names
        grouping_dat['SampleID']=grouping_dat[0].str.split('.',expand=True)[0]

        #Joining the two dfs
        covar_grouping_dat=grouping_dat.merge(all_covar_dat,how='left',on='SampleID')
        covar_grouping_dat=covar_grouping_dat.loc[:,[0,1]+covars]
        covar_grouping_dat.to_csv(output[0],sep='\t',index=False,header=False)
rule merge_counts_files:
    input:
        base_cond_counts_f=intron_clustering_dir+'{base_cond}/{base_cond}_perind_numers.counts.gz',cond_counts_f=intron_clustering_dir+'{cond}/{cond}_perind_numers.counts.gz'
    output:
        ds_counts_output_dir+'{base_cond}_vs_{cond}_perind_numers.counts.gz',ds_output_dir+'{base_cond}_vs_{cond}_intron_lookup.txt'
    resources:
        mem_mb=1000
    run:
        import pandas as pd
        #Loading counts data
        base_cond_counts_dat=pd.read_csv(input.base_cond_counts_f,sep=' ')
        cond_counts_dat=pd.read_csv(input.cond_counts_f,sep=' ')

        #Extracting intron boundaries
        base_cond_counts_dat=base_cond_counts_dat.reset_index();
        base_cond_counts_dat[['c','s','e','clu']]=base_cond_counts_dat['index'].str.split(':',expand=True)

        cond_counts_dat=cond_counts_dat.reset_index();
        cond_counts_dat[['c','s','e','clu']]=cond_counts_dat['index'].str.split(':',expand=True)

        #Merging both
        ds_counts_dat=base_cond_counts_dat.merge(cond_counts_dat,how='inner',on=['c','s','e'],suffixes=['_base','_cond']).fillna({'clu_base':'NA','clu_cond':'NA'})

        ds_counts_dat['index']=ds_counts_dat['c'].astype(str)+":"+ds_counts_dat['s'].astype(str)+":"+ds_counts_dat['e'].astype(str)+":"+ds_counts_dat['clu_base'].astype(str)+"."+ds_counts_dat['clu_cond'].astype(str)
        ds_intron_lookup=ds_counts_dat.loc[:,['index_base','index_cond']]

        ds_counts_dat=ds_counts_dat.drop(columns=['c','s','e','index_base','index_cond']).set_index('index')
        ds_counts_dat.index.name=None
        ds_counts_dat.to_csv(output[0],sep=' ',compression='gzip')
        ds_intron_lookup.to_csv(output[1],sep='\t',header=False,index=False)
rule split_merged_counts_files:
    input:
        ds_counts_output_dir+'{base_cond}_vs_{cond}_perind_numers.counts.gz'
    output:
        expand(ds_counts_output_dir+'{{base_cond}}_vs_{{cond}}_chunk_{chunk}_perind_numers.counts.gz',chunk=chunks)

    resources:
        mem_mb=2000
    params:
        num_chunks=num_chunks
    run:
        import numpy as np
        import pandas as pd
        dat=pd.read_csv(input[0],sep=' ',index_col=0)
        dat['combined_clu']=dat['clu_base']+'.'+dat['clu_cond']
        all_clus=list(set([x[3] for x in dat.index.str.split(':',expand=True)]))
        chunked_clus=[x for x in np.array_split(all_clus,params['num_chunks']) if len(x) > 0]


        for i,clus in enumerate(chunked_clus):
            df=dat.loc[dat['combined_clu'].isin(clus),:]
            df.drop(columns=['combined_clu']).to_csv(output[i],sep=' ',compression='gzip')
            print("Written chunk {0}".format(i))

rule run_ds:
    input:
        grouping_file=ds_groupings_output_dir+"{base_cond}_vs_{cond}_withcovars.grouping",counts_file=ds_counts_output_dir+'{base_cond}_vs_{cond}_chunk_{chunk}_perind_numers.counts.gz'
    output:
        ds_results_output_dir+"{base_cond}_vs_{cond}_chunk_{chunk}_timeout_"+timeout_sec+"_cluster_significance.txt",ds_results_output_dir+"{base_cond}_vs_{cond}_chunk_{chunk}_timeout_"+timeout_sec+"_effect_sizes.txt"
    params:
        ds_results_output_dir=ds_results_output_dir,
        leafcutter_ds_script=leafcutter_ds_script,
        exons_file=exons_file,
        timeout_sec=timeout_sec,
        min_samples_per_group=min_samples_per_group,
        min_samples_per_intron=min_samples_per_intron,
        min_coverage=min_coverage

    resources:
        mem_mb=8000,
        threads=10
    shell:
        "Rscript {params.leafcutter_ds_script} --min_samples_per_group {params.min_samples_per_group} --min_samples_per_intron {params.min_samples_per_intron} --min_coverage {params.min_coverage} --timeout {params.timeout_sec} --num_threads {resources.threads} -e {params.exons_file} -o {params.ds_results_output_dir}{wildcards.base_cond}_vs_{wildcards.cond}_chunk_{wildcards.chunk}_timeout_{params.timeout_sec} {input.counts_file} {input.grouping_file}"
rule collect_ds_chunks_sig:
    input:
        expand(ds_results_output_dir+'{{base_cond}}_vs_{{cond}}_chunk_{chunk}_timeout_'+timeout_sec+'_cluster_significance.txt',chunk=chunks)
    output:
        ds_results_output_dir+'{base_cond}_vs_{cond}_timeout_'+timeout_sec+'_cluster_significance.txt'
    resources:
        mem_mb=8000
    run:
        import pandas as pd
        all_dat=pd.concat([pd.read_csv(f,sep='\t') for f in input],ignore_index=True)
        all_dat.to_csv(output[0],sep='\t',header=True,index=False)

rule collect_ds_chunks_effsize:
	input:
		expand(ds_results_output_dir+'{{base_cond}}_vs_{{cond}}_chunk_{chunk}_timeout_'+timeout_sec+'_effect_sizes.txt',chunk=chunks)
	output:
		ds_results_output_dir+'{base_cond}_vs_{cond}_timeout_'+timeout_sec+'_effect_sizes.txt'
	resources:
		mem_mb=8000
	run:
		import pandas as pd
		all_dat=pd.concat([pd.read_csv(f,sep='\t') for f in input],ignore_index=True)
		all_dat.to_csv(output[0],sep='\t',header=True,index=False)
