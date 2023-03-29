

source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;



#Setting up needed variables



group="macromapsqtl"
workdir="$OUTPUT_DIR_SCRATCH123"oe2/snakemake_sqtlpermutation_workdir/
fdr=(1 0.05)
conds_py=$(bash_list_to_python_list "${conds[@]}")
PCs_py=$(bash_list_to_python_list "${PCs[@]}")
fdr_py=$(bash_list_to_python_list "${fdr[@]}")

qtltools_binary="${QTLTOOLS_BINARY}"
chunks=50


mkdir -p "$COV_DIR"
mkdir -p "${workdir}"
# snakemake -j 24 -p --config conds="${conds[*]}" PCs="${PCs[*]}" cov_dir="${COV_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" --directory "${workdir}" -s cov.Snakefile

mkdir -p "$SQTL_PERMUTATION_OUTPUT_DIR"
# snakemake -j 1000 --rerun-incomplete -p --config conds="${conds[*]}" PCs="${PCs[*]}" cov_dir="${COV_DIR}" window_name="${WINDOW_NAME}" window="${WINDOW}" chunks="${chunks}" vcf="${VCF}" qtltools_binary="${QTLTOOLS_BINARY}" seed="${SEED}" sqtl_output_dir="${SQTL_PERMUTATION_OUTPUT_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" permutations="${PERMUTATIONS}" --directory "${workdir}" --cluster "rm logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.out logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.err ; mkdir -p logs/cluster/map_sqtl_permutation_{rule} ; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"map_sqtl_permutation_{rule}.{wildcards}\" -G ${group} -o logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.out -e logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.err" -s permutation.Snakefile

# snakemake -j 200 -p --config conds="${conds[*]}" PCs="${PCs[*]}" cov_dir="${COV_DIR}" window_name="${WINDOW_NAME}" window="${WINDOW}" chunks="${chunks}" vcf="${VCF}" qtltools_binary="${QTLTOOLS_BINARY}" seed="${SEED}" sqtl_output_dir="${SQTL_PERMUTATION_OUTPUT_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" permutations="${PERMUTATIONS}" --directory "${workdir}"  --cluster "rm logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.out logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.err ; mkdir -p logs/cluster/map_sqtl_permutation_{rule} ; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"map_sqtl_permutation_{rule}.{wildcards}\" -G ${group} -o logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.out -e logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.err" -s tabix.Snakefile

# snakemake -j 200 -p --config conds="${conds[*]}" PCs="${PCs[*]}" cov_dir="${COV_DIR}" window_name="${WINDOW_NAME}" window="${WINDOW}" chunks="${chunks}" vcf="${VCF}" qtltools_binary="${QTLTOOLS_BINARY}" seed="${SEED}" sqtl_output_dir="${SQTL_PERMUTATION_OUTPUT_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" permutations="${PERMUTATIONS}" fdr_sig_script="${SQTL_PERMUTATION_SCRIPTS_DIR}output_sig_fdr.R" fdr="${fdr_py}" --directory "${workdir}" --cluster "rm logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.out logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.err ; mkdir -p logs/cluster/map_sqtl_permutation_{rule} ; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"map_sqtl_permutation_{rule}.{wildcards}\" -G ${group} -o logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.out -e logs/cluster/map_sqtl_permutation_{rule}/{rule}.{wildcards}.err" -s fdr.Snakefile


snakemake -j 200 -p --config conds="${conds[*]}" PCs="${PCs[*]}" cov_dir="${COV_DIR}" window_name="${WINDOW_NAME}" window="${WINDOW}" chunks="${chunks}" vcf="${VCF}" qtltools_binary="${QTLTOOLS_BINARY}" seed="${SEED}" sqtl_output_dir="${SQTL_PERMUTATION_OUTPUT_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" permutations="${PERMUTATIONS}" fdr_sig_script="${SQTL_PERMUTATION_SCRIPTS_DIR}output_sig_fdr.R" fdr="${fdr_py}" cond_pc_num_file="${COND_PC_NUM_FILE}" max_cond_pc_num_file="${MAX_COND_PC_NUM_FILE}" --directory "${workdir}" -s maxPC.Snakefile

#bsub -I -R"rusage[mem=2000] select[mem>2000]" -n25 -M 2000 -m "modern_hardware" -q long
