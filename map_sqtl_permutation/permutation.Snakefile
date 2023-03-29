

from pathlib import Path
import glob
shell.prefix("set +o pipefail;")


cov_dir=config['cov_dir']
sqtl_output_dir=config['sqtl_output_dir']
window_name=config['window_name']
vcf=config['vcf']
qtltools_binary=config['qtltools_binary']
seed=config['seed']
window=config['window']
prepared_sqtl_input_dir=config['prepared_sqtl_input_dir']
permutations=config['permutations']

conds=config['conds'].split()
PCs=config['PCs'].split()
num_chunks=config['chunks']




chunks=[i for i in range(1,num_chunks+1)]


#RULES
# localrules: collectChunks


rule all:
    input:
        expand(sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.txt",cond=conds,PC=PCs)

rule collectChunks:
    input:
        expand(sqtl_output_dir+"{{cond}}/chunk_"+window_name+"_{{cond}}_{{PC}}_PCs.{current_chunk}.output.txt",current_chunk=chunks)
    output:
        sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.txt"
    resources:
        mem_mb=8000
    shell:
        "cat {input} > {output}"
rule mapSqtl:
    input:
        cov=cov_dir+"{cond}_{PC}_PCs.cov",qq_file=prepared_sqtl_input_dir+'{cond}/{cond}_perind.counts.gz.qqnorm_chrALL_annotated_sorted_renamed_chr.gz'
    output:
        out=sqtl_output_dir+"{cond}/chunk_"+window_name+"_{cond}_{PC}_PCs.{current_chunk}.output.txt",log=sqtl_output_dir+"{cond}/chunk_"+window_name+"_{cond}_{PC}_PCs.{current_chunk}.log"
    params:
        vcf=vcf,
        qtltools_binary=qtltools_binary,
        permutations=permutations,
        num_chunks=num_chunks,
        seed=seed,
        window=window
    resources:
        mem_mb=8000
    shell:
        "{params.qtltools_binary} cis --normal --vcf {params.vcf} --cov {input.cov} --bed {input.qq_file} --out {output.out} --log {output.log} --permute {params.permutations} --window {params.window} --grp-best --chunk {wildcards.current_chunk} {params.num_chunks} --seed {params.seed}"
