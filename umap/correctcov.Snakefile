from pathlib import Path
import glob


prepared_sqtl_input_dir=config['prepared_sqtl_input_dir']
umap_output_dir=config['umap_output_dir']
conds=config['conds']
max_PCs=config['max_PCs']

###
# conds=['CIL_24']
# max_PCs=['5']

###
# localrules: correct_cov_outer, correct_cov_inner
max_cond_PC={cond:PC for cond,PC in zip(conds,max_PCs)}

rule all:
    input:
        # umap_output_dir+'embedding_outer.RData',umap_output_dir+'embedding_inner.RData'
        umap_output_dir+"embedding_inner.qnorm.rb_int.cov_corrected.RData",umap_output_dir+"embedding_outer.qnorm.rb_int.cov_corrected.RData"
        # umap_output_dir+'all_cond_inner.cov_corrected.qnorm.rb_int.txt',umap_output_dir+'all_cond_outer.cov_corrected.qnorm.rb_int.txt'
rule umap_inner:
    input:
        umap_output_dir+"all_cond_inner.qnorm.rb_int.cov_corrected.txt"
    output:
        umap_output_dir+"embedding_inner.qnorm.rb_int.cov_corrected.RData"
    resources:
        mem_mb=32000
    shell:
        "conda deactivate; Rscript /nfs/team152/oe2/sqtl/scripts/umap/umap_embedding.R {input} {output}"
rule umap_outer:
    input:
        umap_output_dir+"all_cond_outer.qnorm.rb_int.cov_corrected.txt"
    output:
        umap_output_dir+"embedding_outer.qnorm.rb_int.cov_corrected.RData"
    resources:
        mem_mb=32000
    shell:
        "conda deactivate; Rscript /nfs/team152/oe2/sqtl/scripts/umap/umap_embedding.R {input} {output}"



rule correct_cov_inner:
    input:
        umap_output_dir+'all_cond_inner.txt'
    output:
        umap_output_dir+'all_cond_inner.qnorm.rb_int.cov_corrected.txt'
    resources:
        mem_mb=32000
    shell:
        "conda deactivate; Rscript /nfs/team152/oe2/sqtl/scripts/umap/normalize.R {input} {output}"

rule correct_cov_outer:
    input:
        umap_output_dir+'all_cond_outer.txt'
    output:
        umap_output_dir+'all_cond_outer.qnorm.rb_int.cov_corrected.txt'
    resources:
        mem_mb=32000
    shell:
        "conda deactivate; Rscript /nfs/team152/oe2/sqtl/scripts/umap/normalize.R {input} {output}"


rule mergeConds:
    input:
        expand(prepared_sqtl_input_dir+'{cond}/{cond}_perind.counts.gz.phen_chrALL_renamed',cond=conds)
    output:
        umap_output_dir+'all_cond_inner.txt',umap_output_dir+'all_cond_outer.txt'
    params:
        conds=conds
    resources:
        mem_mb=32000
    run:
        import pandas as pd
        import functools
        id_cols=['chr','s','e','strd']
        dat=[pd.read_csv(f,sep='\t',index_col=0) for f in input]
        for i,df in enumerate(dat):
            df=df.rename(columns={x:x+":"+params.conds[i] for x in df.columns.values})

            df['_index']=df.index
            df[['chr','s','e','_c']]=df['_index'].str.split(':',expand=True)
            df[['_clu','_clunum','strd','_cond','_time']]=df['_c'].str.split('_',expand=True)

            dat[i]=df.drop(columns=['_index','_c','_clu','_clunum','_cond','_time'])

        #Inner merge
        a=functools.reduce(lambda left,right: pd.merge(left,right,on=id_cols,how='inner'),dat)
        a['id']=a['chr'].astype(str)+":"+a['s'].astype(str)+":"+a['e'].astype(str)+":"+a['strd'].astype(str)
        a=a.drop(columns=id_cols).set_index('id').transpose()
        a.to_csv(output[0],sep='\t')
        del a
        #Outer merge
        b=functools.reduce(lambda left,right: pd.merge(left,right,on=id_cols,how='outer'),dat)
        b['id']=b['chr'].astype(str)+":"+b['s'].astype(str)+":"+b['e'].astype(str)+":"+b['strd'].astype(str)
        b=b.drop(columns=id_cols).set_index('id').transpose()
        b.to_csv(output[1],sep='\t')
