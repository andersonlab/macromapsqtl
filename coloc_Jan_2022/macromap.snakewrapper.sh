#!/usr/local/bin/bash
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;



#Setting up needed variables

gwas_names=("$1")
gwas_formats=("$2")
workdir=$3


group="macromapsqtl"

conda_env_path=/software/team152/oe2/anaconda3/envs/gtex
gene_map_f="${GENCODE_GENEID_FILE}"
tmp_coloc_output_dir="$TMP_OUTPUT_DIR"macromap_coloc/
coloc_res_output_dir="$MACROMAP_COLOC_OUTPUT_DIR"
gwas_output_dir="$GWAS_PROCESSED_SUMMSTAT_DIR"
scripts_dir="${SCRIPTS_DIR}"coloc_Jan_2022/

chunks=50
padding=1000000

for cond in "${conds[@]}" ; do mkdir -p "${tmp_coloc_output_dir}${cond}/";done;
for cond in "${conds[@]}" ; do mkdir -p "${coloc_res_output_dir}${cond}/";done;
mkdir -p "${workdir}"

#MEM=16000 ; bsub -I -R "rusage[mem=${MEM}] select[mem>${MEM} && model=Intel_Platinum]" -M "$MEM" -m "modern_hardware"

snakemake -F -j 1000 --until all --latency-wait 90 -p --keep-going --config gwas_names="${gwas_names[*]}" gwas_formats="${gwas_formats[*]}" tmp_coloc_output_dir="${tmp_coloc_output_dir}" gwas_output_dir="${gwas_output_dir}" coloc_res_output_dir="${coloc_res_output_dir}" padding="${padding}" chunks="${chunks}" gene_map_f="${gene_map_f}" conds="${max_conds[*]}" PCs="${max_PCs[*]}" sqtl_output_dir="${SQTL_NOMINAL_OUTPUT_DIR}" scripts_dir="${scripts_dir}" chrom_size_f="${CHROM_SIZES_HG38}" --directory "${workdir}" --use-conda --conda-prefix "${conda_env_path}" --cluster "rm logs/cluster/macromap_{rule}/{wildcards.cond}/{rule}.{wildcards}.out logs/cluster/macromap_{rule}/{wildcards.cond}/{rule}.{wildcards}.err ; mkdir -p logs/cluster/macromap_{rule}/{wildcards.cond}; bsub -R \"rusage[mem={resources.mem_mb}] select[model==Intel_Platinum && mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"macromap_{rule}.{wildcards}\" -G ${group} -o logs/cluster/macromap_{rule}/{wildcards.cond}/{rule}.{wildcards}.out -e logs/cluster/macromap_{rule}/{wildcards.cond}/{rule}.{wildcards}.err" -s macromap.Snakefile
