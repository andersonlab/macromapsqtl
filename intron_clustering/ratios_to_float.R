library(tidyverse)

args = commandArgs(trailingOnly=TRUE)
intron_clustering_f <- args[1]
output_prefix <- args[2]

# intron_clustering_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/intron_clustering/CIL_24/CIL_24_perind.counts_renamed'

intron_clustering_dat <- read.csv(intron_clustering_f,sep='\t',stringsAsFactors = F,check.names = F)

median_cluster_coverage_dat <- intron_clustering_dat %>% 
   mutate_at(vars(contains('HPS')), ~ as.numeric(sapply(str_split(.x,pattern="/"),'[',2))) %>% 
   rowwise() %>% mutate(median_cluster_coverage=median(c_across(contains('HPS')),na.rm = T)) %>% 
   select(intron,median_cluster_coverage)

parsed_intron_clustering_dat <- intron_clustering_dat %>%
   mutate_at(vars(contains('HPS')), ~ unlist(map(., ~ eval(parse(text=as.character(.x))) ))) %>%
   rowwise()  %>% mutate(mean_iur=mean(c_across(contains('HPS')),na.rm = T)) %>% 
   rowwise()  %>% mutate(median_iur=median(c_across(contains('HPS')),na.rm = T))

parsed_intron_clustering_dat$nonzero_samples <- parsed_intron_clustering_dat %>%
  mutate_at(vars(contains('HPS')), ~ ifelse( .x > 0,T,F)) %>% 
  rowwise() %>% mutate(nonzero_samples=sum(c_across(contains('HPS')),na.rm=T)) %>%
  .$ nonzero_samples

entropy_clu_dat <- parsed_intron_clustering_dat %>% 
   mutate_at(vars(contains('HPS')),~ ((.x+1E-10)*log((.x+1E-10),2))) %>% #log transformation (with pseudocount)
   separate('intron',into=c('chr','s','e','clu'),sep=":") %>% #getting cluster info
   group_by(clu) %>% mutate(n_intron=n()) %>% #Counting number of introns in cluster
   group_by(clu) %>% mutate_at(vars(contains('HPS')), ~ -sum(.x,na.rm=T) ) %>% #summing up log-transofrmed usage ratios per individual and normalizing
   rowwise() %>% mutate(max_entropy=max(c_across(contains('HPS')),na.rm=T)) %>% #max entropy
   rowwise() %>% mutate(min_entropy=min(c_across(contains('HPS')),na.rm=T)) %>% #min entropy
   mutate_at(vars(contains('HPS')), ~ (.x-min_entropy)/(max_entropy-min_entropy) ) %>% #normalize
   rowwise() %>% mutate(mean_normalized_clu_entropy=mean(c_across(contains('HPS')),na.rm=T)) %>% #Calculating mean entropy per individuals
   distinct(clu,mean_normalized_clu_entropy,n_intron)  #Now  everything is quantified at cluster level

parsed_intron_clustering_dat <- parsed_intron_clustering_dat %>% left_join(median_cluster_coverage_dat,by="intron")

write.table(parsed_intron_clustering_dat,file=paste0(output_prefix,'_float_meaniur_medianiur_nonzerosamples_medianclucoverage'),sep='\t',quote=F,row.names=F)
write.table(entropy_clu_dat,file=paste0(output_prefix,'_cluentropy'),sep='\t',quote=F,row.names=F)
