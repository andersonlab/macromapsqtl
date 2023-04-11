library(umap)
library(tidyverse)


args = commandArgs(trailingOnly=TRUE)


input_f <- args[1]
output_f <- args[2]

# input_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/umap/all_cond_inner.qnorm.rb_int.cov_corrected.txt'
# output_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/umap/try_embedding.RData'
pseudocount <- 0.001
print(sprintf('Input: %s',input_f))
print(sprintf('Output: %s',output_f))
#Reading in data
dat <- read.csv(input_f,sep='\t',header=T,row.names=1)
#
# dat <- dat[,1:10]
#
dat[is.na(dat)] <- pseudocount

#Performing UMAP
embedding <- umap(dat)
#Labels
sample_cond <- dat %>%  rownames_to_column('sample') %>% mutate(cond=sample %>% str_split(pattern=':') %>% sapply('[',2)) %>% .$ cond
#Extracting embedding coordinates and a variety of labels
umap_coord <- embedding$layout %>% as.data.frame()
umap_coord$cond <- sample_cond
umap_coord$time_only <- str_split(umap_coord$cond,pattern="_") %>% sapply('[',2)
umap_coord$cond_only <- str_split(umap_coord$cond,pattern="_") %>% sapply('[',1)
umap_coord$stim <- ifelse(umap_coord$cond %in% c('Ctrl_6','Ctrl_24'),'Ctrl','Stim')
umap_coord$stim <- ifelse(umap_coord$cond %in% c('Prec_D0','Prec_D2'),'Prec',umap_coord$stim)
#Saving as an R object
save(umap_coord,file=output_f)

#Jobs
#bsub -R"select[mem>128000] rusage[mem=128000]" -M128000 -o umap_inner.out -e umap_inner.err -J umap_inner -m "modern_hardware" "Rscript /nfs/team152/oe2/sqtl/scripts/umap/umap_embedding.R /lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/umap/all_cond_inner.txt /lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/umap/embedding_inner.RData"

#bsub -R"select[mem>128000] rusage[mem=128000]" -M128000 -o umap_outer.out -e umap_outer.err -J umap_outer -m "modern_hardware" "Rscript /nfs/team152/oe2/sqtl/scripts/umap/umap_embedding.R /lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/umap/all_cond_outer.txt /lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/umap/embedding_outer.RData"
