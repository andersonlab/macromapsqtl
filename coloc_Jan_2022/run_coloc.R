library(coloc)
library(tidyverse)
library(config)
args = commandArgs(trailingOnly=TRUE)
config_f <- args[1]
yaml_f <- args[2]
output_f <- args[3]
if(length(args) > 3) {N_arg=args[4]}




#Macromap example files
# config_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/tmp/macromap_coloc/merged_config.IBD.IFNG_24.5_PCs.chunk_40.txt'
# output_f  <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/macromap_coloc/try.coloc'
# yaml_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/tmp/macromap_coloc/macromap_gwas.yaml'

#GTEx example files

# config_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/tmp/gtex_coloc/Adipose_Subcutaneous/merged_config.gwas_sqtl.UC.Adipose_Subcutaneous.chunk_5.txt'
# yaml_f <- '/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/tmp/gtex_coloc/gtex_gwas.yaml'


config_dat <- read.csv(config_f,sep='\t',header=F,stringsAsFactors = F)
num_traits <- (dim(config_dat)[[2]]-1)/2
yaml_dat <- config::get(file=yaml_f)


suffixes <- paste0('T',1:num_traits)
tr_val_cols <-setNames(yaml_dat[['tr_val_cols']],suffixes)
tr_id_cols <- setNames(yaml_dat[['tr_id_cols']],suffixes)
tr_types <- setNames(yaml_dat[['type']],suffixes)



##This is where summstats are processed##
#Building cmds dataframe#
cmds <- data.frame(row.names = 1:nrow(config_dat),stringsAsFactors = F)
alternative_cmds <- data.frame(row.names = 1:nrow(config_dat),stringsAsFactors = F)

for(i in 1:num_traits) {
  f_col <- paste0('V',3+((i-1)*2))
  new_col <- data.frame(paste('/software/team152/oe2/bin/tabix',config_dat[[f_col]],config_dat[['V1']]),stringsAsFactors = F)
  
  alternative_new_col <- data.frame(paste('/software/team152/oe2/bin/tabix',config_dat[[f_col]],config_dat %>% mutate(V1=ifelse(startsWith(as.character(V1),'chr'),str_sub(V1,4),paste0('chr',V1) )) %>% .$ V1),stringsAsFactors = F)

  cmds <- cbind(cmds,new_col)
  alternative_cmds <- cbind(alternative_cmds,alternative_new_col)
}
colnames(cmds) <- paste0('V',1:num_traits)
colnames(alternative_cmds) <- paste0('V',1:num_traits)



coloc_res <- data.frame()

#
# cmds <- cmds %>% head(1)
#
for (i in 1:nrow(cmds)) {
  # i <- 1
  skip_region <- F
  tr_ph_list <- c()
  # i <- 1
  #################################
  #START OF INNER LOOP OVER TRAITS#
  #################################
  for (j in 1:num_traits) {
          
          
          # j <- 2
          suffix <- suffixes[[j]]
          tr_type <- tr_types[[suffix]]
          
          tr_cmd <- cmds[i,paste0('V',j)]
          
          tr_ph <- config_dat[i,paste0('V',2*j)]
          tr_ph_list <- append(tr_ph_list, tr_ph)
          
          tr_dat_txt <- system(tr_cmd,intern=T)
          print(paste0('Running ', tr_cmd, '...') )
          
          
          
          
          
          if (length(tr_dat_txt) == 0) {
            
            alternative_tr_cmd <- alternative_cmds[i,paste0('V',j)]
            tr_dat_txt <- system(alternative_tr_cmd,intern=T)
            print(paste0('Running alternative command with/without "chr" ', alternative_tr_cmd, '...') )
            
            if (length(tr_dat_txt) == 0) {
              print(paste0('SKIPPED: no trait data read for ',tr_ph,'...') )
              skip_region <- T
              break
            }
          }
          
          
          
          tr_dat <- read.table(text=tr_dat_txt,sep='\t',header=F,stringsAsFactors = F)

          current_tr_id_cols <- paste0('V',tr_id_cols[[suffix]])
          tr_dat <- tr_dat %>% unite('ph',all_of(current_tr_id_cols),remove=F,sep='|') 
          tr_dat <- tr_dat %>% filter( ph %in% all_of(tr_ph) )
          
          
          if(dim(tr_dat)[1] == 0) {
            print(paste0('SKIPPED: no data read  or satisfying criteria for ',tr_ph,'...'))
            skip_region <- T
            break
          }         
          
          
          #Extracting column names. We add N/MAF id it's a quantitative trait
          snp_chr_col <- paste0('V',tr_val_cols[[suffix]][[1]])
          snp_pos_col <- paste0('V',tr_val_cols[[suffix]][[2]])
          beta_col <- paste0('V',tr_val_cols[[suffix]][[3]])
          se_col <- paste0('V',tr_val_cols[[suffix]][[4]])
          pval_col <- paste0('V',tr_val_cols[[suffix]][[5]])
          
          if(tr_type=='quant') {
            if(exists('N_arg')) {
              maf_col <- paste0('V',tr_val_cols[[suffix]][[6]])
              
            } else {
              N_col <- paste0('V',tr_val_cols[[suffix]][[6]])
              maf_col <- paste0('V',tr_val_cols[[suffix]][[7]])
              
            }
          } 
          
          #Building summstats dataframe depending on type
          if (tr_type=='quant') {
            if(exists('N_arg')) {N=N_arg}else{N=tr_dat[[N_col]]}
            maf=tr_dat[[maf_col]]
          } else {
            N=-1
            maf=-1
          }
          
          #Adding chr if it's not there
          tr_dat <- tr_dat %>% mutate("{snp_chr_col}":=ifelse(startsWith(as.character(!!rlang::sym(snp_chr_col)),'chr'),!!rlang::sym(snp_chr_col),paste0('chr',!!rlang::sym(snp_chr_col))))
          
          tr_summstat <- data.frame(snp=paste0(tr_dat[[snp_chr_col]],':',tr_dat[[snp_pos_col]]),beta=tr_dat[[beta_col]],se=tr_dat[[se_col]],pval=tr_dat[[pval_col]],N=N,maf=maf)
          colnames(tr_summstat) <- c(c('snp'),paste(c('beta','se','pval','N','maf'),j,sep='_'))
          # print(tr_summstat %>% head(20))
          #Merged summstats
          if (j > 1) {
            all_summstat <- tr_summstat %>% inner_join(all_summstat,by='snp')
            
          } else {
            all_summstat <- tr_summstat
          }
  
  }
  ###############################
  #END OF INNER LOOP OVER TRAITS#
  ###############################
  if(skip_region) {
    print(paste0('Region couldnt be processed for command: ',tr_cmd))
    next
  }
  print(paste0("Joined summstats: ",dim(all_summstat)[1]) ) 
  
  if(dim(all_summstat)[1] == 0) {
    print('SKIPPED: no joint summstats data...')
    next
  }
  
  se_cols <- all_summstat[paste('se',1:num_traits,sep='_')] %>% names()
  beta_cols <- all_summstat[paste('beta',1:num_traits,sep='_')] %>% names()
  N_cols <- all_summstat[paste('N',1:num_traits,sep='_')] %>% names()
  maf_cols <- all_summstat[paste('maf',1:num_traits,sep='_')] %>% names()
  
  #Removing all duplicated entries
  all_summstat <- all_summstat %>% filter(! (snp %in% all_summstat$snp[all_summstat$snp %>% duplicated()]))
  #Removing NA's
  all_summstat <- all_summstat %>% drop_na()
  #Removing SE=0
  all_summstat <- all_summstat %>% filter(if_all(all_of(se_cols), ~ . > 0)) %>% filter(if_all(all_of(se_cols), ~ . != Inf))  %>% filter(if_all(all_of(beta_cols), ~ . != Inf))  
  if(dim(all_summstat)[1] < 2) {
    print('SKIPPED: filtering join summstats resulted in data with less than 2 SNPs...')
    next
  }
  rownames(all_summstat) <- all_summstat$snp
  
  new_beta_cols <- suffixes
  new_se_cols <- suffixes
  new_N_cols <- suffixes
  new_maf_cols <- suffixes
  
  beta_dat <- all_summstat[beta_cols] %>% dplyr::rename(setNames(beta_cols,suffixes))
  se_dat <- all_summstat[se_cols] %>% dplyr::rename(setNames(se_cols,suffixes))
  N_dat <- all_summstat[N_cols] %>% dplyr::rename(setNames(N_cols,suffixes))
  maf_dat <- all_summstat[maf_cols] %>% dplyr::rename(setNames(maf_cols,suffixes))
  
  traits <- tr_ph_list
  rsid <- all_summstat$snp
  
  
  #Formatting output
  #COLOC
  snp_names <- as.character(all_summstat$snp)
  snp_positions <- as.integer(sapply(str_split(snp_names,pattern=":"),'[',2))
  
  beta_D1 <- beta_dat[[suffixes[[1]]]]
  varbeta_D1 <- se_dat[[suffixes[[1]]]]^2
  type_D1 <- tr_types[[suffixes[[1]]]]
  N_D1 <- N_dat[1,suffixes[[1]]]
  MAF_D1 <- maf_dat[[suffixes[[1]]]]
  
  D1 <- list(beta=setNames(beta_D1, all_summstat$snp),varbeta=setNames(varbeta_D1, all_summstat$snp),type=type_D1,snp=snp_names,position=snp_positions)
  
  if(type_D1=='quant') {D1[['N']] <- as.numeric(N_D1) ; D1[['MAF']] <- MAF_D1}
  
  beta_D2 <- beta_dat[[suffixes[[2]]]]
  varbeta_D2 <- se_dat[[suffixes[[2]]]]^2
  type_D2 <- tr_types[[suffixes[[2]]]]
  N_D2 <- N_dat[1,suffixes[[2]]]
  MAF_D2 <- maf_dat[[suffixes[[2]]]]
  
  D2 <- list(beta=setNames(beta_D2, all_summstat$snp),varbeta=setNames(varbeta_D2, all_summstat$snp),type=type_D2,snp=snp_names,position=snp_positions)
  
  if(type_D2=='quant') {D2[['N']] <- as.numeric(N_D2) ; D2[['MAF']] <- MAF_D2}

  res <- coloc.abf(dataset1=D1,dataset2=D2)

  annotated_res <- res$summary %>% t() %>% as.data.frame()
  
  
  #HyprColoc
  # res <- hyprcoloc(beta_dat %>% as.matrix(), se_dat %>% as.matrix(), trait.names=traits, snp.id=rsid,bb.alg	=F)
  # annotated_res=res$results
  # annotated_res$nsnp <- nrow(all_summstat)
  #
  
  for (j in 1:num_traits) {
    col <- paste0('trait_',j)
    annotated_res[[col]] <- tr_ph_list[[j]]
  }
  coloc_res <- rbind(coloc_res,annotated_res)

}
write.table(coloc_res,file = output_f,quote=F,col.names = F,row.names = F,sep='\t')


