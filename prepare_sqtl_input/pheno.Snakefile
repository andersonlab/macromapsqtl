from pathlib import Path
import glob
# shell.prefix("set +o pipefail;")


localrules: createJuncBed
somatic_chr=config['chrom']
gtf_f_v27=config['gtf_f_v27']
gtf_f_v45=config['gtf_f_v45']
ref_genome=config['ref_genome']

#RULES
rule all:
    input:
        expand(config['prepared_sqtl_input_dir']+"{cond}/{cond}_junclist_gencodev27.annot",cond=config['conds']),expand(config['prepared_sqtl_input_dir']+"{cond}/{cond}_junclist_gencodev45.annot",cond=config['conds'])
        # expand(config['prepared_sqtl_input_dir']+"{cond}/{cond}_junclist.bed",cond=config['conds'])


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

rule createJuncBed:
    input:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.phen_chrALL_renamed"
    output:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_junclist.bed"
    resources:
        mem_mb=2000
    shell:
        "cat {input} | tail -n+2 | cut -f 1 | awk -vOFS=$'\\t' 'BEGIN{{FS=\"[:_]\"}}{{s=$2;e=$3-1;print \"chr\"$1,s,e,$1\":\"$2\":\"$3\":\"$4\"_\"$5\"_\"$6,\"0\",$6,s,e,\"255,0,0\",\"2\",\"0,0\",\"0,\"e-s}}' > {output}"

rule JuncBedAnnotate:
    input:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_junclist.bed"
    output:
        output_f_v27=config['prepared_sqtl_input_dir']+"{cond}/{cond}_junclist_gencodev27.annot",output_f_v45=config['prepared_sqtl_input_dir']+"{cond}/{cond}_junclist_gencodev45.annot"
    params:
        gtf_f_v45=gtf_f_v45,
        gtf_f_v27=gtf_f_v27,
        ref_genome=ref_genome

    resources:
        mem_mb=3000
    shell:
        "regtools junctions annotate {input} {params.ref_genome} {params.gtf_f_v27} -o {output.output_f_v27}; regtools junctions annotate {input} {params.ref_genome} {params.gtf_f_v45} -o {output.output_f_v45}"

# rule calculateSd:
#     input:
#         config['preapred_sqtl_input_dir']+"{cond}/{cond}_perind.counts.{cond}.txt.gz.qqnorm_chrALL_sorted.gz"
#     output:
#         config['preapred_sqtl_input_dir']+"{cond}/{cond}_perind.counts.{cond}.std"
#     shell:
#         "python -c \"import pandas as pd; dat=pd.read_csv({input},sep='\t');output_dat=dat.loc[:,['pid','gid']];std_dat=dat.drop(columns=['pid','gid','#Chr','start','end','strand']).std(axis=1);output_dat.loc[:,'std']=std_dat; output_dat.to_csv({output},sep='\t',index=False,header=False)\""
