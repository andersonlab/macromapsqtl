#!/usr/bin/env bash

source ../paths.sh
source ../configs.sh
#Getting the numers file filename
job_output_dir="$JOB_LOGS_DIR"ds/
prepared_ds_input_dir="$OUTPUT_DIR"prepared_ds_input/
#rm -r "$job_output_dir"rename_samples*
mkdir -p $job_output_dir
mkdir -p $prepared_ds_input_dir

all_covars_files=/lustre/scratch119/realdata/mdt3/teams/gaffney/np12/MacroMap/Analysis/eQTLs/Macromap_fds/*/covariates/covariates_*.txt

#Renaming the numers file
for cond in "${conds[@]}"; do
  numers_file="$CHUNKED_INTRON_CLUSTERING_OUTPUT_DIR"leafcutter_perind_numers.counts."$cond".txt.gz
  echo "$numers_file"
  bsub -J "rename_samples_numers_""$cond" -o "$job_output_dir"rename_samples_numers_"$cond".out -e "$job_output_dir"rename_samples_numers_"$cond".err -R "select[mem>8000] rusage[mem=8000]" -M 8000 "python \"$MISC_SCRIPTS_DIR\"rename_columns.py -i $numers_file -o $prepared_ds_input_dir -m $all_covars_files -mc SampleID HipsciID -isep ' ' -gz"
done;

#Renaming the groupings files


for base_cond in "${base_conds[@]}"; do
  for cond in "${conds[@]}"; do
    grouping_file="$GROUPING_DIR""$base_cond"_"$cond"_nocovars.grouping
    python "$MISC_SCRIPTS_DIR"rename_columns.py -i $grouping_file -o $GROUPING_DIR -m $all_covars_files -mc SampleID HipsciID -isep $'\t' -ax 0 --nocolheader
  done;
done;
