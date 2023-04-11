
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

workdir="$OUTPUT_DIR_SCRATCH123"oe2/
group="macromapsqtl"
conds_py=$(bash_list_to_python_list "${conds[@]}")
snakemake -j 200 -p --config conds="${conds_py}" realigned_bam_dir="${realigned_bam_dir}" junc_dir="${junc_output_dir}" --directory "${workdir}" --cluster "mkdir -p logs/cluster/{rule}; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"{rule}.{wildcards}\" -G ${group} -o logs/cluster/{rule}/{rule}.{wildcards}.out -e logs/cluster/{rule}/{rule}.{wildcards}.err"


#bsub -I -R"rusage[mem=2000] select[mem>2000]" -n500 -M 2000 -m "modern_hardware" -q long
