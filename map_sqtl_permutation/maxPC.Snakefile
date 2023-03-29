


from pathlib import Path
import glob


cov_dir=config['cov_dir']
sqtl_output_dir=config['sqtl_output_dir']
window_name=config['window_name']
vcf=config['vcf']
qtltools_binary=config['qtltools_binary']
seed=config['seed']
window=config['window']
prepared_sqtl_input_dir=config['prepared_sqtl_input_dir']
permutations=config['permutations']

conds=config['conds'].split(' ')
PCs=config['PCs'].split(' ')
num_chunks=config['chunks']

fdr_sig_script=config['fdr_sig_script']
fdr=config['fdr']
cond_pc_num_file=config['cond_pc_num_file']
max_cond_pc_num_file=config['max_cond_pc_num_file']

chunks=[i for i in range(1,num_chunks+1)]



rule all:
    input:
        cond_pc_num_file,max_cond_pc_num_file
rule countSigSqtl:
    input:
        expand(sqtl_output_dir+"{cond}/"+window_name+"_{cond}_{PC}_PCs.output.FDR.0.05.txt",cond=conds,PC=PCs)
    output:
        cond_pc_num_file,max_cond_pc_num_file
    params:
        conds=conds,
        PCs=PCs
    run:
        import pandas as pd
        from pathlib import Path
        dat=[]
        for f in input:
            p=Path(f).name.split('.')[0]
            _,cond,time,PC,_=p.split('_')
            num_sig_sqtl=pd.read_csv(f,sep=' ',header=None).shape[0]
            dat.append([cond+'_'+time,PC,num_sig_sqtl])
        dat=pd.DataFrame(dat)
        max_pc_dat=dat.loc[dat.groupby(0)[2].idxmax(),:]
        dat.to_csv(output[0],sep='\t',header=False,index=False)
        max_pc_dat.to_csv(output[1],sep='\t',header=False,index=False)
