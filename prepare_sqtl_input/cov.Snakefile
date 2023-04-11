from pathlib import Path
import glob
shell.prefix("set +o pipefail;")


cov_dir=config['cov_dir']
prepared_sqtl_input_dir=config['prepared_sqtl_input_dir']

conds=config['conds']
PCs=config['PCs']
#RULES



rule all:
    input:
        expand(cov_dir+"{cond}_{PC}_PCs.cov",PC=PCs,cond=conds)
rule collectCovars:
    input:
        pop_pcs_file="/lustre/scratch119/realdata/mdt3/teams/gaffney/np12/MacroMap/Analysis/eQTLs/Macromap_fds/{cond}/covariates/{cond}.pop_3_PCs",leafcutter_pcs_file=prepared_sqtl_input_dir+"{cond}/{cond}_perind.counts.gz.PCs_renamed"
    output:
        cov_dir+"{cond}_{PC}_PCs.cov"
    run:
        import pandas as pd
        pop_pc_dat=pd.read_csv(input.pop_pcs_file,sep='\t').rename(columns={'PCs':'id'})
        leafcutter_pc_dat=pd.read_csv(input.leafcutter_pcs_file,sep='\t').iloc[0:wildcards.PC,:]
        cov_dat=pd.concat([leafcutter_pc_dat,pop_pc_dat],ignore_index=True)
        cov_dat.to_csv(input.cov_file,sep='\t',index=False)
