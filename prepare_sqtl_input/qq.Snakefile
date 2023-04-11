from pathlib import Path
import glob
shell.prefix("set +o pipefail;")



somatic_chr=config['chrom']
localrules: copyClustCounts,createIntronList,addChr
#RULES
rule all:
    input:
        expand(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr.gz.tbi",cond=config['conds']),expand(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.PCs_renamed",cond=config['conds']),        expand(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr.std",cond=config['conds'])
rule copyClustCounts:
    input:
        config['intron_clustering_output_dir']+"{cond}/{cond}_perind.counts.gz"
    output:
        temp(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz")
    shell:
        "cp {input} {output}; cond={wildcards.cond}; python -c \"import pandas as pd; dat=pd.read_csv('{output}',sep=' ');dat['chrom']=dat['chrom'].str[3:]+'_$cond';dat.to_csv('{output}',sep=' ',index=False,compression='gzip')\""
rule preparePhenotypeTable:
    input:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz"
    output:
        temp(expand(config['prepared_sqtl_input_dir']+"{{cond}}/{{cond}}_perind.counts.gz.qqnorm_chr{chr}",chr=somatic_chr)),temp(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.PCs")
    params:
        prepare_sqtl_input_script=config['prepare_sqtl_input_script'],
        PC=config['PC']
    resources:
        mem_mb=4000
    shell:
        "python2 {params.prepare_sqtl_input_script} {input} -p {params.PC}"
rule createIntronList:
    input:
        expand(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz",cond=config['conds'])
    output:
        config['intron_list_file']
    resources:
        mem_mb=4000
    shell:
        "printf '' > {output}; for f in {input}; do zcat $f | awk 'BEGIN{{FS=\" \"}}{{if(NR > 1) print $1}}' >> {output}; done;"
rule createExonsFile:
    input:
        config['gencode_gtf_file']
    output:
        config['exons_file']
    params:
        gtf_to_exons_script=config['gtf_to_exons_script']
    resources:
        mem_mb=4000
    shell:
        "Rscript {params.gtf_to_exons_script} {input} {output}"
rule mapClustersToGenes:
    input:
        exons_file=config['exons_file'],intron_list_file=config['intron_list_file']
    output:
        config['intron_to_gene_map']
    params:
        map_clusters_to_genes_script=config['map_clusters_to_genes_script'],
        geneid_file=config['geneid_file']
    resources:
        mem_mb=4000
    shell:
        "Rscript {params.map_clusters_to_genes_script} {input.exons_file} {input.intron_list_file} {params.geneid_file} {output}"

rule annotateQQFiles:
    input:
        qq_file=config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chr{chr}",intron_to_gene_map=config['intron_to_gene_map']
    output:
        temp(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chr{chr}_annotated")
    params:
        annotate_qq_files_script=config['annotate_qq_files_script']
    resources:
        mem_mb=2000
    shell:
        "Rscript {params.annotate_qq_files_script} {input.qq_file} {input.intron_to_gene_map} {output}"

rule aggregateQQFiles:
    input:
        expand(config['prepared_sqtl_input_dir']+"{{cond}}/{{cond}}_perind.counts.gz.qqnorm_chr{chr}_annotated",chr=somatic_chr)
    output:
        temp(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted")
    params:
        aggergate_per_chrom_qq_files_script=config['aggergate_per_chrom_qq_files_script'],
        prefix=config['prepared_sqtl_input_dir']+"{cond}/{cond}"
    resources:
        mem_mb=2000
    shell:
        "bash {params.aggergate_per_chrom_qq_files_script} {params.prefix}"
rule renameQQFiles:
    input:
        qq_file=config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted",pc_file=config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.PCs"
    output:
        renamed_qq_file=temp(config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed"),renamed_pc_file=config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.PCs_renamed"
    resources:
        mem_mb=2000
    params:
        rename_samples_script=config['rename_samples_script']
    shell:
        "bash {params.rename_samples_script} {wildcards.cond} {input.qq_file} {output.renamed_qq_file}; bash {params.rename_samples_script} {wildcards.cond} {input.pc_file} {output.renamed_pc_file}"
rule addChr:
    input:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed"
    output:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr"
    run:
        import pandas as pd
        qq_dat=pd.read_csv(input[0],sep='\t')
        qq_dat['#Chr']='chr'+qq_dat['#Chr'].astype(str)
        qq_dat.to_csv(output[0],sep='\t',index=False)


rule tabixQQFiles:
    input:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr"
    output:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr.gz",config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr.gz.tbi"
    resources:
        mem_mb=4000
    shell:
        "bgzip -f {input}; tabix -p bed {input}.gz;"
rule sdY:
    input:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr.gz"
    output:
        config['prepared_sqtl_input_dir']+"{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr.std"
    resources:
        mem_mb=4000
    run:
        import pandas as pd
        dat=pd.read_csv(input[0],sep='\t')
        output_dat=dat.loc[:,['gid','pid']]
        std_dat=dat.drop(columns=['pid','gid','#Chr','start','end','strand']).std(axis=1)
        output_dat.loc[:,'std']=std_dat
        output_dat.to_csv(output[0],sep='\t',index=False,header=False)

# rule calculateSd:
#     input:
#         config['preapred_sqtl_input_dir']+"{cond}/{cond}_perind.counts.{cond}.txt.gz.qqnorm_chrALL_sorted.gz"
#     output:
#         config['preapred_sqtl_input_dir']+"{cond}/{cond}_perind.counts.{cond}.std"
#     shell:
#         "python -c \"import pandas as pd; dat=pd.read_csv({input},sep='\t');output_dat=dat.loc[:,['pid','gid']];std_dat=dat.drop(columns=['pid','gid','#Chr','start','end','strand']).std(axis=1);output_dat.loc[:,'std']=std_dat; output_dat.to_csv({output},sep='\t',index=False,header=False)\""
