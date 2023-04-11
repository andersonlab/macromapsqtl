
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;



#Setting up needed variables

# cond=$1
# PC=$2
#

#Dispatcher:
#bsub -I -q "long" -R "rusage[mem=16000] select[mem>16000]" -M 16000 -m "modern_hardware" -J "ds_snakemake_dispatcher" "bash snakewrapper.sh"

group="macromapsqtl"
workdir="$OUTPUT_DIR_SCRATCH123"oe2/
base_conds=($(awk 'BEGIN{FS="\t"}{print $1}' "$DS_COMPARISONS_LIST"))
comparison_conds=($(awk 'BEGIN{FS="\t"}{print $2}' "$DS_COMPARISONS_LIST"))


mkdir -p "${DS_RESULTS_OUTPUT_DIR}"
mkdir -p "${DS_GROUPINGS_OUTPUT_DIR}"
mkdir -p "${DS_COUNTS_OUTPUT_DIR}"
snakemake -j 2000 --keep-going -p --config intron_clustering_dir="${INTRON_CLUSTERING_OUTPUT_DIR}" exons_file="${GENCODE_EXONS_FILE}" ds_results_output_dir="${DS_RESULTS_OUTPUT_DIR}" ds_groupings_output_dir="${DS_GROUPINGS_OUTPUT_DIR}" ds_counts_output_dir="${DS_COUNTS_OUTPUT_DIR}" ds_output_dir="${DS_OUTPUT_DIR}" realigned_bam_dir="${REALIGNED_BAM_DIR}" ds_pipeline_dir="$DS_PIPELINE_DIR" base_conds="${base_conds[*]}" conds="${comparison_conds[*]}" leafcutter_ds_script="$DS_SCRIPT" --directory "${workdir}" --cluster "rm logs/cluster/ds_{rule}/{rule}.{wildcards}.out logs/cluster/ds_{rule}/{rule}.{wildcards}.err ; mkdir -p logs/cluster/ds_{rule}; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -q normal -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"ds_{rule}.{wildcards}\" -G ${group} -o logs/cluster/ds_{rule}/{rule}.{wildcards}.out -e logs/cluster/ds_{rule}/{rule}.{wildcards}.err" -s ds.Snakefile
#bsub -I -R "rusage[mem=16000] select[mem>16000]" -M 16000 -m "modern_hardware" -J "ds_snakemake_dispatcher" "bash snakewrapper.sh"
