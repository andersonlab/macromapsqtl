
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;



#Setting up needed variables
junc_output_dir="${OUTPUT_DIR_SCRATCH123}oe2/output/junc/"
junc_lists_dir="$junc_output_dir"junc_lists/
intron_clustering_output_dir="$OUTPUT_DIR_SCRATCH123"oe2/output/intron_clustering/
intron_clustering_script="$SCRIPTS_DIR"leafcutter_July_2021/leafcutter/scripts/leafcutter_cluster_regtools_py3.py
ratios_to_float_script="$SCRIPTS_DIR"intron_clustering/ratios_to_float.R
group="macromapsqtl"
conds_py=$(bash_list_to_python_list "${conds[@]}")
workdir="$OUTPUT_DIR_SCRATCH123"oe2/intron_clustering_workdir/

#Creating junc files lists
# mkdir -p "$junc_lists_dir"
# for cond in "${conds[@]}"; do
#   junc_list_f="$junc_lists_dir""$cond"_junc.list; printf '' > "$junc_list_f";
#   for junc_f in "$junc_output_dir""$cond"/*.junc; do echo "$junc_f" >> "$junc_list_f"; done;
# done;

mkdir -p "$workdir"
snakemake -j 25 -p --until all --config conds="${conds_py}" ratios_to_float_script="${ratios_to_float_script}" intron_clustering_script="${intron_clustering_script}" junc_lists_dir="${junc_lists_dir}" intron_clustering_output_dir="${intron_clustering_output_dir}" --directory "${workdir}" --cluster "mkdir -p logs/cluster/{rule}; rm logs/cluster/{rule}/{rule}.{wildcards}.out; rm logs/cluster/{rule}/{rule}.{wildcards}.err; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -n {threads} -J \"{rule}.{wildcards}\" -G ${group} -o logs/cluster/{rule}/{rule}.{wildcards}.out -e logs/cluster/{rule}/{rule}.{wildcards}.err" -s Snakefile


#bsub -I -R"rusage[mem=2000] select[mem>2000]" -n25 -M 2000 -m "modern_hardware" -q long
