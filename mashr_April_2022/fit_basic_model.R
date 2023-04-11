library(tidyverse)
library(ashr)
library(mashr)
library(flashr)
set.seed(1)

args = commandArgs(trailingOnly=TRUE)
random_summstat_f <- args[1]
strong_summstat_f <- args[2]
output_f <- args[3]


# random_summstat_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/summstats/random.all.txt'
# strong_summstat_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/summstats/strong.all.txt'
# output_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/models/basic_model.Rds'

#Loading random summstats
random_summstat_dat <- read.csv(random_summstat_f,sep='\t',header=F)

bhat_random <- random_summstat_dat %>% select(V1,V2,V3,V4) %>% unite("V1",c('V1','V3'),sep='|',remove=T) %>% spread(V2,V4) %>% column_to_rownames('V1') 
shat_random <- random_summstat_dat %>% select(V1,V2,V3,V5) %>% unite("V1",c('V1','V3'),sep='|',remove=T) %>% spread(V2,V5) %>% column_to_rownames('V1')

#Loading strong summstats
strong_summstat_dat <- read.csv(strong_summstat_f,sep='\t',header=F)

bhat_strong <- strong_summstat_dat %>% select(V1,V2,V3,V4) %>% unite("V1",c('V1','V3'),sep='|',remove=T) %>% spread(V2,V4) %>% column_to_rownames('V1') 
shat_strong <- strong_summstat_dat %>% select(V1,V2,V3,V5) %>% unite("V1",c('V1','V3'),sep='|',remove=T) %>% spread(V2,V5) %>% column_to_rownames('V1')


##DEBUG##

# bhat_random <- bhat_random[1:1000,]
# shat_random <- shat_random[1:1000,]
# 
# bhat_strong <- bhat_strong[1:1000,]
# shat_strong <- shat_strong[1:1000,]

########

#Correlation Structure (see https://stephenslab.github.io/mashr/articles/eQTL_outline.html)
data.temp = mash_set_data(as.matrix(bhat_random) , as.matrix(shat_random))
Vhat = estimate_null_correlation_simple(data.temp)
rm(data.temp)

data.random = mash_set_data(as.matrix(bhat_random),as.matrix(shat_random),V=Vhat,)
data.strong = mash_set_data(as.matrix(bhat_strong),as.matrix(shat_strong),V=Vhat)

#Data-Driven Covariance Matrices (Using strong set)
U.f = cov_flash(data.strong)
# U.f = cov_pca(data.strong,5)
U.ed = cov_ed(data.strong, U.f)

#Canonical Covariance Matrices (Using random set)
U.c = cov_canonical(data.random)

print('Finished covariance matrices...')

#Fit model
m = mash(data.random, Ulist = c(U.ed,U.c), outputlevel = 1)

print('Saving model...')
#Saving RDS
saveRDS(m,file=output_f)
