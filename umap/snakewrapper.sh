
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;




#Setting up needed variables


group="macromapsqtl"
workdir="$OUTPUT_DIR_SCRATCH123"oe2/
max_conds_py=$(bash_list_to_python_list "${!max_cond_PC[@]}")
max_PCs_py=$(bash_list_to_python_list "${max_cond_PC[@]}")

umap_output_dir="${OUTPUT_DIR_SCRATCH123}"oe2/output/umap/

snakemake -j 24 -p --config conds="${max_conds_py}" max_PCs="${max_PCs_py}"  umap_output_dir="${umap_output_dir}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" --directory "${workdir}" --cluster "rm -r logs/cluster/umap_{rule}; mkdir -p logs/cluster/umap_{rule}; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"map_sqtl_permutation_{rule}.{wildcards}\" -G ${group} -o logs/cluster/umap_{rule}/{rule}.{wildcards}.out -e logs/cluster/umap_{rule}/{rule}.{wildcards}.err" -s correctcov.Snakefile
