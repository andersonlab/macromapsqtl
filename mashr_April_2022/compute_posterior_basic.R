library(tidyverse)
library(mashr)
library(ashr)
library(ComplexHeatmap)
library(circlize)

#Loading model and computing correlation structure
random_summstat_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/summstats/random.all.txt'
m_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/models/basic_model.Rds'
m <- readRDS(m_f)
#Estimating null correlations
random_summstat_dat <- read.csv(random_summstat_f,sep='\t',header=F)

bhat_random <- random_summstat_dat %>% select(V1,V2,V3,V4) %>% unite("V1",c('V1','V3'),sep='|',remove=T) %>% spread(V2,V4) %>% column_to_rownames('V1')
shat_random <- random_summstat_dat %>% select(V1,V2,V3,V5) %>% unite("V1",c('V1','V3'),sep='|',remove=T) %>% spread(V2,V5) %>% column_to_rownames('V1')

data.temp = mash_set_data(as.matrix(bhat_random) , as.matrix(shat_random))
data.temp = mash_update_data(data.temp)

Vhat = estimate_null_correlation_simple(data.temp)
rm(data.temp)

#Loading all coloc effects
rename_list <- c('gene_intron'='V1','condition_name'='V2','lead_snp'='V3','beta'='V4','se'='V5')
effect_dat <- read.csv('/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/mashr_April_2022/summstats/coloc75/coloc.all.txt',sep='\t',header=F) %>% dplyr::rename(rename_list)
effect_dat <- effect_dat %>% separate('gene_intron',into=c('gene','_','intron'),sep='[.|]',extra='drop') %>% select(-c('_')) %>% unite('gene_intron',c('gene','intron'),sep="|")
coloc_effect_dat <- effect_dat 

#Preparing input for posterior computation
coloc_bhat_dat <- coloc_effect_dat %>% select(c(gene_intron,condition_name,lead_snp,beta)) %>% spread('condition_name','beta') %>% unite('gene_intron_leadsnp',c('gene_intron','lead_snp'),sep='|') %>% column_to_rownames('gene_intron_leadsnp') 
coloc_shat_dat <- coloc_effect_dat %>% select(c(gene_intron,condition_name,lead_snp,se)) %>% spread('condition_name','se') %>% unite('gene_intron_leadsnp',c('gene_intron','lead_snp'),sep='|') %>% column_to_rownames('gene_intron_leadsnp') 
data.coloc = mash_set_data(as.matrix(coloc_bhat_dat),as.matrix(coloc_shat_dat))
data.coloc  = mash_update_data(data.coloc,V=Vhat)
#Performing posterior computations
m2 = mash(data.coloc, g=get_fitted_g(m), fixg=TRUE)

coloc_beta_posterior <- mash_compute_posterior_matrices(m2,data.coloc) %>% as.data.frame()  %>% rownames_to_column('gene_intron_leadsnp') %>% separate('gene_intron_leadsnp',into=c('gene','intron','leadsnp'),sep='\\|') 

#LFSR heatmap
lfsr_dat <- get_lfsr(m2) %>% as.data.frame() 
highlight_group_one <- which((lfsr_dat %>% rename_with(~ sapply(str_split(.x,'-'),'[',1)) %>% colnames()) %in% c('LIL10_6','CIL_6','sLPS_6'))
highlight_group_two <- which((lfsr_dat %>% rename_with(~ sapply(str_split(.x,'-'),'[',1)) %>% colnames()) %in% c('Prec_D2','Ctrl_6','IL4_24','IL4_6'))
groupings <- rep('DEFAULT',24)
# groupings[highlight_group_one] <- 'UP'
# groupings[highlight_group_two] <- 'DOWN'
groupings <- factor(groupings,levels=c('UP','DEFAULT','DOWN'))
#Visualize LFSR
library(circlize); col_fun = colorRamp2(c(0,0.05,0.06), c("#FEDA75", "#082567","#082567")) ; 
n <- (lfsr_dat %>% dim())[1] ; 

#####TODO: Fix this####
prop <- lfsr_dat %>% rownames_to_column('effect') %>% gather('cond','lfsr',-effect) %>% mutate(response=ifelse(lfsr < 0.05,T,F)) %>% group_by(cond) %>% summarise(n=round((sum(response)/n)*1,digits = 2));
column_ha <- HeatmapAnnotation(`Proportion \nof re-sQTLs`=anno_barplot(prop$n,ylim=c(0,1)));
ht <- lfsr_dat %>%
  filter(if_any(!starts_with('Ctrl'), ~ . < 0.05)) %>% 
  filter(if_all(starts_with('Ctrl'), ~ . >= 0.05)) %>% 
  as.matrix() %>%
  ComplexHeatmap::Heatmap(show_row_names = F,
                        
                          cluster_rows = T,
                          name='LFSR',
                          column_split = groupings,
                          column_title = NULL,
                          row_title = NULL,
                          show_row_dend = F,
                          top_annotation=column_ha,
                          heatmap_legend_param = list(direction='vertical',title_position = "topcenter"))

draw(ht,padding=unit('1.5','cm'))
