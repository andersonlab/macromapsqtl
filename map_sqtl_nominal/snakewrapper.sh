
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;



#Setting up needed variables




group="macromapsqtl"
workdir="$OUTPUT_DIR_SCRATCH123"oe2/snakemake_sqtlnominal_workdir/
tss_f="${GENCODE_TSS_FILE}"
qtltools_binary="${QTLTOOLS_BINARY}"
maf_f="$SNP_ID_POS_FILE"
sample_size_f="$SAMPLE_SIZE_FILE"
chunks="$nominal_chunks"
queue=normal

#######DEBUG#######
# SQTL_NOMINAL_OUTPUT_DIR=/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/sqtl_nominal_debug/
# workdir="$OUTPUT_DIR_SCRATCH123"oe2/snakemake_sqtlnominal_workdir_debug/
# max_cond_PC=([CIL_24]="9" [P3C_24]="1")
###################


# mkdir -p "$COV_DIR"
# snakemake -j 24 -p --config conds="${conds_py}" PCs="${PCs_py}" cov_dir="${COV_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" --directory "${workdir}" -s cov.Snakefile

mkdir -p "$SQTL_NOMINAL_OUTPUT_DIR"
mkdir -p "$workdir"
snakemake -j 240 --latency-wait 90 -p --until all --keep-going --config conds="${!max_cond_PC[*]}" PCs="${max_cond_PC[*]}" tss_f="${tss_f}" cov_dir="${COV_DIR}" window_name="${WINDOW_NAME}" window="${WINDOW}" chunks="${chunks}" vcf="${VCF}" qtltools_binary="${QTLTOOLS_BINARY}" seed="${SEED}" sqtl_output_dir="${SQTL_NOMINAL_OUTPUT_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" maf_f="$maf_f" sample_size_f="$sample_size_f" --directory "${workdir}" --cluster "rm logs/cluster/map_sqtl_nominal_{rule}/{rule}.{wildcards}.out logs/cluster/map_sqtl_nominal_{rule}/{rule}.{wildcards}.err ; mkdir -p logs/cluster/map_sqtl_nominal_{rule};bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"map_sqtl_nominal_{rule}.{wildcards}\" -G ${group} -o logs/cluster/map_sqtl_nominal_{rule}/{rule}.{wildcards}.out -e logs/cluster/map_sqtl_nominal_{rule}/{rule}.{wildcards}.err" -s Snakefile
