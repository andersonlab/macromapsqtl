source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;




workdir="$OUTPUT_DIR_SCRATCH123"oe2/
group="macromapsqtl"
conds_py=$(bash_list_to_python_list "${conds[@]}")
snakemake -j 500 -p --rerun-incomplete --config conds="${conds_py}" output_base_dir="${OUTPUT_DIR_SCRATCH123}oe2/output/" unaligned_bam_dir="${BAM_DIR}" vcf="${VCF}" star_index="${STAR_INDEX}" --directory "${workdir}" --cluster "mkdir -p logs/cluster/{rule}; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"{rule}.{wildcards}\" -G ${group} -o logs/cluster/{rule}/{rule}.{wildcards}.out -e logs/cluster/{rule}/{rule}.{wildcards}.err"


#bsub -I -R"rusage[mem=1000] select[mem>1000]" -n500 -M 1000 -m "modern_hardware" -q long
#Checks
