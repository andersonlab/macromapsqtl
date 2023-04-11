
#Reading in raw input files
args = commandArgs(trailingOnly=TRUE)

phen_file <- args[1]#sprintf('/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/prepared_sqtl_input/%s/%s_perind.counts.gz.phen_chrALL_renamed'
output_f <- args[2]#sprintf('/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/all_cond_pca/%s/%s.quantnorm.rbint.covcorrected',cond,cond)

###
library(tidyverse)
library(preprocessCore)

#Defining functions and constants
fit_cov <- function(x,cov_df){
  df <- data.frame(y=x,r1=cov_df$RunID,r2=cov_df$Donor,r3=cov_df$Library_prep,r4=cov_df$Sex,r6=cov_df$Differentiation_media,r7=cov_df$Purity_result_per,r8=cov_df$Estimated_cell_diameter,r9=cov_df$Differentiation_time_No_Days);
  l <- residuals(lm(y~r1+r4+r6+r7+r8+r9,df));
  return(l);
}

rbint <- function(a,k,s){
  v <- (rank(a,tie="first")-k) /( s+1-(2*k))
  return(v)
}
pseudocount <- 0.001
k <- 0.5

#Loading phenotype data and filling in NAs with pseudocount
phen <- read.csv(phen_file,sep='\t',check.names = F,row.names = 1,header=T)
print('Loaded phenotype data..')

phen[is.na(phen)] <- pseudocount
intron_names <- colnames(phen)
sample_names <- rownames(phen)
print(sprintf('Filled any missing phenotype data with pseudocount:%s..',pseudocount))

#Loading covariates
cov <- readRDS('/lustre/scratch119/humgen/teams/gaffney/np12/MacroMap/Analysis/QC/RDS_expression_covariates/Macromap_final_expression/protein_coding_lincRNA/covariates_macromap_fds.rds')
cov$sample <- paste0(cov$HipsciID,":",cov$Stimulus_Hours)

#Extracting covariates only to match rows in covariates data with rows in phenotype data
cov_only <- data.frame(sample=rownames(phen)) %>% left_join(cov,on='sample') %>% column_to_rownames('sample')
print('Loaded covariate data..')



#Step 1: Quantile normalizing introns
phen <- normalize.quantiles(phen %>% as.matrix(),copy=TRUE) %>% as.data.frame() #%>% t() %>% as.data.frame()
rownames(phen) <- sample_names
colnames(phen) <- intron_names
print('Quantile normalized data..')

#Step 2: Rank-based inverse normal transformation of introns
s <- nrow(phen);
phen <- lapply( phen,  rbint, k=k,s=s) %>% lapply(qnorm) %>% as.data.frame()
rownames(phen) <- sample_names
colnames(phen) <- intron_names
print('Rank-based inverse normal transformed (rb-int) data..')

#Step 3: Fitting covariates
phen <- lapply(phen,fit_cov,cov_df=cov_only) %>% as.data.frame()
rownames(phen) <- sample_names
colnames(phen) <- intron_names
print('Fitted covariate data..')
###

#Writing file:
##Order:

##1-Quantile normalization of introns
##2-Rank-based inverse normal transformation of introns
##3-Covariate correction
write.table(phen,file = output_f,sep = '\t',quote=F)
print(sprintf('Wrote data to file %s..',output_f))
