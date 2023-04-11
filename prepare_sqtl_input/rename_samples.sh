#!/usr/bin/env bash
# shellcheck disable=SC1091

source /nfs/team152/oe2/sqtl/scripts/paths.sh
source /nfs/team152/oe2/sqtl/scripts/configs.sh

cond=$1
qq_file=$2
output_qq_file=$3
all_covars_file="/lustre/scratch119/realdata/mdt3/teams/gaffney/np12/MacroMap/Analysis/eQTLs/Macromap_fds/${cond}/covariates/covariates_${cond}.txt"

python -c "import pandas as pd; qq_dat=pd.read_csv('${qq_file}',sep='\t'); covars_dat=pd.read_csv('${all_covars_file}',sep='\t'); mapping=covars_dat.loc[:,['HipsciID','SampleID']];mapping=mapping.to_dict(orient='list'); rename_dict=dict(zip(mapping['SampleID'],mapping['HipsciID'])); qq_dat=qq_dat.rename(columns=rename_dict); qq_dat=qq_dat.drop(columns=['NOMATCH'],errors='ignore') ;qq_dat.to_csv('${output_qq_file}',sep='\t',index=False)"
