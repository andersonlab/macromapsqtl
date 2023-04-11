#!/usr/local/bin/bash
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;



#Setting up needed variables

MASH_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/mashr_April_2022/


group="macromapsqtl"
queue=normal

workdir="$OUTPUT_DIR_SCRATCH123"oe2/snakemake_mash/
mash_scripts_dir="${SCRIPTS_DIR}"mashr_April_2022/
mash_output_dir="${MASH_OUTPUT_DIR}"
seed="$SEED"

chunks=50
samples_per_chunk=20000
# for cond in "${conds[@]}" ; do mkdir -p "${tmp_coloc_output_dir}${cond}/";done;
# for cond in "${conds[@]}" ; do mkdir -p "${coloc_res_output_dir}${cond}/";done;
mkdir -p "${workdir}"
mkdir -p "${mash_output_dir}effect_lists/"
mkdir -p "${mash_output_dir}summstats/"

#MEM=16000 ; bsub -I -R "rusage[mem=${MEM}] select[mem>${MEM} && model=Intel_Platinum]" -M "$MEM" -m "modern_hardware"


snakemake -j 1000 --until all --latency-wait 90 -p --keep-going --config conds="${max_conds[*]}" PCs="${max_PCs[*]}" sqtl_output_dir="${SQTL_NOMINAL_OUTPUT_DIR}" mash_scripts_dir="${mash_scripts_dir}" mash_output_dir="$MASH_OUTPUT_DIR" samples_per_chunk="${samples_per_chunk}" chunks="${chunks}" seed="${seed}" permutation_sqtl_output_dir="${SQTL_PERMUTATION_OUTPUT_DIR}" --directory "${workdir}" --cluster "rm logs/cluster/macromap_{rule}/{rule}.{wildcards}.out logs/cluster/macromap_{rule}/{rule}.{wildcards}.err ; mkdir -p logs/cluster/macromap_{rule}; bsub -R \"rusage[mem={resources.mem_mb}] select[model==Intel_Platinum && mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -q ${queue} -m \"modern_hardware\" -n {threads} -J \"macromap_{rule}.{wildcards}\" -G ${group} -o logs/cluster/macromap_{rule}/{rule}.{wildcards}.out -e logs/cluster/macromap_{rule}/{rule}.{wildcards}.err" -s Snakefile
