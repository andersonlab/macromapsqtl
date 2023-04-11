library(tidyverse)
library(mashr)
library(ashr)



#Loading model and computing correlation structure
# random_summstat_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/summstats/random.all.txt'
m_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/models/Ctrl_24_baseline_model.Rds'
leadsnp_summstat_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/summstats/leadsnp/leadsnp.all.txt'

m <- readRDS(m_f)


###########################################
########LOADING QUERY EFFECTS #############
###########################################
#ALL LEAD_SNP EFFECTS
rename_list <- c('gene_intron'='V1','condition_name'='V2','lead_snp'='V3','beta'='V4','se'='V5')
effect_dat <- read.csv(leadsnp_summstat_f,sep='\t',header=F) %>% dplyr::rename(rename_list)
effect_dat <- effect_dat %>% separate('gene_intron',into=c('gene','_','intron'),sep='[.|]',extra='drop') %>% select(-c('_')) %>% unite('gene_intron',c('gene','intron'),sep="|")
leadsnp_effect_dat <- effect_dat 


leadsnp_bhat_dat <- leadsnp_effect_dat %>% select(c(gene_intron,condition_name,lead_snp,beta)) %>% spread('condition_name','beta') %>% unite('gene_intron_leadsnp',c('gene_intron','lead_snp'),sep='|') %>% column_to_rownames('gene_intron_leadsnp') 
leadsnp_shat_dat <- leadsnp_effect_dat %>% select(c(gene_intron,condition_name,lead_snp,se)) %>% spread('condition_name','se') %>% unite('gene_intron_leadsnp',c('gene_intron','lead_snp'),sep='|') %>% column_to_rownames('gene_intron_leadsnp') 

data.leadsnp = mash_set_data(as.matrix(leadsnp_bhat_dat),as.matrix(leadsnp_shat_dat))
data.leadsnp = mash_update_data(data.leadsnp ,ref=3)

m.leadsnp = mash(data.leadsnp, g=get_fitted_g(m), fixg=TRUE)

# #COLOC EFFECTS
# rename_list <- c('gene_intron'='V1','condition_name'='V2','lead_snp'='V3','beta'='V4','se'='V5')
# effect_dat <- read.csv('/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/summstats/coloc75/coloc.all.txt',sep='\t',header=F) %>% dplyr::rename(rename_list)
# effect_dat <- effect_dat %>% separate('gene_intron',into=c('gene','_','intron'),sep='[.|]',extra='drop') %>% select(-c('_')) %>% unite('gene_intron',c('gene','intron'),sep="|")
# coloc_effect_dat <- effect_dat 
# 
# 
# coloc_bhat_dat <- coloc_effect_dat %>% select(c(gene_intron,condition_name,lead_snp,beta)) %>% spread('condition_name','beta') %>% unite('gene_intron_leadsnp',c('gene_intron','lead_snp'),sep='|') %>% column_to_rownames('gene_intron_leadsnp') 
# coloc_shat_dat <- coloc_effect_dat %>% select(c(gene_intron,condition_name,lead_snp,se)) %>% spread('condition_name','se') %>% unite('gene_intron_leadsnp',c('gene_intron','lead_snp'),sep='|') %>% column_to_rownames('gene_intron_leadsnp') 
# 
# data.coloc = mash_set_data(as.matrix(coloc_bhat_dat),as.matrix(coloc_shat_dat))
# data.coloc = mash_update_data(data.coloc ,ref=3)
# 
# m.coloc = mash(data.coloc, g=get_fitted_g(m), fixg=TRUE)
# 
# 
# #FDR SIG EFFECTS
# rename_list <- c('gene_intron'='V1','condition_name'='V2','lead_snp'='V3','beta'='V4','se'='V5')
# effect_dat <- read.csv('/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/summstats/sig/sig.all.txt',sep='\t',header=F) %>% dplyr::rename(rename_list)
# effect_dat <- effect_dat %>% separate('gene_intron',into=c('gene','_','intron'),sep='[.|]',extra='drop') %>% select(-c('_')) %>% unite('gene_intron',c('gene','intron'),sep="|")
# sig_effect_dat <- effect_dat 
# 
# 
# sig_bhat_dat <- sig_effect_dat %>% select(c(gene_intron,condition_name,lead_snp,beta)) %>% spread('condition_name','beta') %>% unite('gene_intron_leadsnp',c('gene_intron','lead_snp'),sep='|') %>% column_to_rownames('gene_intron_leadsnp') 
# sig_shat_dat <- sig_effect_dat %>% select(c(gene_intron,condition_name,lead_snp,se)) %>% spread('condition_name','se') %>% unite('gene_intron_leadsnp',c('gene_intron','lead_snp'),sep='|') %>% column_to_rownames('gene_intron_leadsnp') 
# 
# data.sig = mash_set_data(as.matrix(sig_bhat_dat),as.matrix(sig_shat_dat))
# data.sig = mash_update_data(data.sig ,ref=3)
# 
# m.sig = mash(data.sig, g=get_fitted_g(m), fixg=TRUE)


####
#Saving fitted models
# fitted_coloc_output_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/models/fitted_coloc.Rds'
# fitted_sig_output_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/models/fitted_sig.Rds'
fitted_leadsnp_output_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/models/fitted_leadsnp.Rds'
# 
# saveRDS(m.coloc,file=fitted_coloc_output_f)
# saveRDS(m.sig,file=fitted_sig_output_f)
saveRDS(m.leadsnp,file=fitted_leadsnp_output_f)


