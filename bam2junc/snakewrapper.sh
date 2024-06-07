#!/usr/local/bin/bash

source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;

#Generating bam file lists

# mkdir -p "${junc_output_dir}";
# for cond in "${conds[@]}"; do
#   junc_list_f="${junc_output_dir}${cond}_junc.list"; printf '' > "${junc_list_f}";
#   for f in "$realigned_bam_dir""$cond"/*.bam.gz; do echo "$f" >> "${junc_list_f}"; done;
# done;


#Running the pipeline to generate a junc file for each condition
realigned_bam_dir="${OUTPUT_DIR_SCRATCH123}oe2/output/realignedBam/"
junc_output_dir="${OUTPUT_DIR_SCRATCH123}oe2/output/junc/"
gtf_f="${GENCODE_GTF_FILE_UNCOMPRESSED}"
gtf_latest_version_f="${GENCODE_V45_GTF_FILE_UNCOMPRESSED}"
ref_genome="${REF_GENOME_FILE}"

workdir="$OUTPUT_DIR_SCRATCH123"oe2/snakemake_workdir/
group="macromapsqtl"


conds_py=$(bash_list_to_python_list "${conds[@]}")
snakemake -j 2000 --rerun-incomplete --keep-going -np --config ref_genome="${ref_genome}" gtf_f="${gtf_f}" gtf_latest_version_f="${gtf_latest_version_f}" conds="${conds_py}" realigned_bam_dir="${realigned_bam_dir}" junc_dir="${junc_output_dir}" --directory "${workdir}" --cluster "mkdir -p logs/cluster/{rule}; rm logs/cluster/{rule}/{rule}.{wildcards}.out; rm logs/cluster/{rule}/{rule}.{wildcards}.err; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -n {threads} -J \"{rule}.{wildcards}\" -G ${group} -o logs/cluster/{rule}/{rule}.{wildcards}.out -e logs/cluster/{rule}/{rule}.{wildcards}.err"


#bsub -I -R"rusage[mem=2000] select[mem>2000]" -n500 -M 2000 -m "modern_hardware" -q long
