
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;



#Setting up needed variables




group="macromapsqtl"
workdir="$OUTPUT_DIR_SCRATCH123"oe2/snakemake_sqtlnominalchunktochr_workdir/
chunks="$nominal_chunks"
queue=normal

#######DEBUG#######
# SQTL_NOMINAL_OUTPUT_DIR=/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/sqtl_nominal_debug/
# workdir="$OUTPUT_DIR_SCRATCH123"oe2/snakemake_sqtlnominal_workdir_debug/
# max_cond_PC=([CIL_24]="9" [P3C_24]="1")
###################


# mkdir -p "$COV_DIR"
# snakemake -j 24 -p --config conds="${conds_py}" PCs="${PCs_py}" cov_dir="${COV_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" --directory "${workdir}" -s cov.Snakefile

mkdir -p "$workdir"
snakemake -j 240 --latency-wait 90 -p --until all --use-conda --keep-going --config conds="${!max_cond_PC[*]}" PCs="${max_cond_PC[*]}" window_name="${WINDOW_NAME}" window="${WINDOW}" chunks="${chunks}" sqtl_output_dir="${SQTL_NOMINAL_OUTPUT_DIR}" --directory "${workdir}" --cluster "rm logs/cluster/sqtlnominalchunktochr_{rule}/{rule}.{wildcards}.out logs/cluster/sqtlnominalchunktochr_{rule}/{rule}.{wildcards}.err ; mkdir -p logs/cluster/sqtlnominalchunktochr_{rule};bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"sqtlnominalchunktochr_{rule}.{wildcards}\" -G ${group} -o logs/cluster/sqtlnominalchunktochr_{rule}/{rule}.{wildcards}.out -e logs/cluster/sqtlnominalchunktochr_{rule}/{rule}.{wildcards}.err" -s chunktochr.Snakefile
