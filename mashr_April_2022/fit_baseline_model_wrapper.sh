#!/usr/local/bin/bash
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;

MASH_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/mashr_April_2022/
mash_scripts_dir="${SCRIPTS_DIR}"mashr_April_2022/
workdir="$OUTPUT_DIR_SCRATCH123"oe2/snakemake_mash/
JOB_DIR="${workdir}"logs/cluster/macromap_fit_Ctrl_6_baseline_model/

mkdir -p "${workdir}"
mkdir -p "${MASH_OUTPUT_DIR}effect_lists/"
mkdir -p "${MASH_OUTPUT_DIR}summstats/"
mkdir -p "${MASH_OUTPUT_DIR}models/"
mkdir -p "${JOB_DIR}"

MEM=128000
QUEUE=long
JOB_NAME=macromap_fit_Ctrl_6_baseline_model
GROUP=macromapsqtl
JOB_O="${JOB_DIR}"fit_Ctrl_6_baseline_model.out
JOB_E="${JOB_DIR}"fit_Ctrl_6_baseline_model.err

JOB_C="Rscript ${mash_scripts_dir}fit_baseline_model.R ${MASH_OUTPUT_DIR}summstats/random.all.txt ${MASH_OUTPUT_DIR}summstats/strong.all.txt ${MASH_OUTPUT_DIR}models/Ctrl_6_baseline_model.Rds"

rm "$JOB_O";
rm "$JOB_E"

bsub -R "rusage[mem=${MEM}] select[model==Intel_Platinum && mem>${MEM}] span[hosts=1]" -M "${MEM}" -q "${QUEUE}" -m "modern_hardware" -n 1 -J "${JOB_NAME}" -G "${GROUP}" -o "${JOB_O}" -e "${JOB_E}" "${JOB_C}"
