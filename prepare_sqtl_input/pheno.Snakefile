from pathlib import Path
import glob
shell.prefix("set +o pipefail;")



somatic_chr=config['chrom']
#RULES
rule all:
    input:
        expand(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.phen_chrALL_renamed",cond=config['conds'])

rule aggregatePhenFiles:
    input:
        expand(config['prepared_sqtl_input_dir']+"{{cond}}/{{cond}}_perind.counts.gz.phen_chr{chr}",chr=somatic_chr)
    output:
        temp(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.phen_chrALL")
    resources:
        mem_mb=2000
    run:
        import pandas as pd
        agg_dat=pd.concat([pd.read_csv(f,sep='\t') for f in input],ignore_index=True).drop(columns=['#Chr','start','end']).rename(columns={'ID':'intron'})
        agg_dat.to_csv(output[0],sep='\t',index=False)

rule renamePhenFiles:
    input:
        phen_file=config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.phen_chrALL"
    output:
        renamed_phen_file=config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.phen_chrALL_renamed"
    resources:
        mem_mb=2000
    params:
        rename_samples_script=config['rename_samples_script']
    shell:
        "bash {params.rename_samples_script} {wildcards.cond} {input.phen_file} {output.renamed_phen_file}"




# rule calculateSd:
#     input:
#         config['preapred_sqtl_input_dir']+"{cond}/{cond}_perind.counts.{cond}.txt.gz.qqnorm_chrALL_sorted.gz"
#     output:
#         config['preapred_sqtl_input_dir']+"{cond}/{cond}_perind.counts.{cond}.std"
#     shell:
#         "python -c \"import pandas as pd; dat=pd.read_csv({input},sep='\t');output_dat=dat.loc[:,['pid','gid']];std_dat=dat.drop(columns=['pid','gid','#Chr','start','end','strand']).std(axis=1);output_dat.loc[:,'std']=std_dat; output_dat.to_csv({output},sep='\t',index=False,header=False)\""
