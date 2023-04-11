library(tidyverse)

args = commandArgs(trailingOnly=TRUE)

qq_file <- args[1]
cluster_to_gene_map_file <- args[2]
output_file <- args[3]

# qq_file <- '/lustre/scratch115/teams/anderson/users/oe2/sqtl/output/prepared_sqtl_input_refined_clusters_2/Ctrl_24/leafcutter_perind.counts.Ctrl_24.txt.gz.qqnorm_chr1'
# cluster_to_gene_map_file <- '/lustre/scratch115/teams/anderson/users/oe2/sqtl/output/misc/cluster_to_gene_map.txt'
# output_file='tryqq.txt'


#Loading the table containing gene/strand information and the qq-normalized file
cluster_to_gene_map_dat <- read.csv(cluster_to_gene_map_file,stringsAsFactors = F,sep='\t')
qq_dat <- read.csv(qq_file, stringsAsFactors = F,sep='\t')


if(nrow(qq_dat) == 0) {
  warning(paste0('WARNING: qq-normalized file contains no rows. File was not annotated. Make sure to exclude it from annotation\nFile: ', qq_file))
  quit();
}

##########################
##STEP 2: Modifying Chromosome name/Filtering for only chromosomes 1-22/Creating cluster name column to be used in the left_join with the cluster_to_gene_map. This is because the cluster_to_gene_map doesn't contain intron-to-gene-mapping
##########################
#Modifying the chromosome name to match the format in the genotype file

qq_dat <- qq_dat %>% filter(`X.Chr` %in% paste0(seq(1,22)))

#Creating a cluster column to match it with the cluster column in the cluster_to_gene_map
qq_dat <- qq_dat %>% separate(ID,into=c('chr','from','to','clu'),sep=':',remove=F) %>% select(-c(chr,from,to))
qq_dat$clu <- paste0(qq_dat$X.Chr,':',qq_dat$clu)
##########################
##STEP 2: Cluster to gene mapping/Adding strand/Modifying phenotype start/end positions to TSS-1/TSS (as GTF is 0-based)/Also filtering out introns that cannot be mapped to a gene
##########################
#Joining with the cluster_to_gene_map
qq_dat_annotated <- qq_dat %>% left_join(cluster_to_gene_map_dat,by='clu')
qq_dat_annotated <- qq_dat_annotated %>% filter(!is.na(gene_id)) 
#Replacing start position of phenotype with TSS, and end position of phenotype with TSS+1
qq_dat_annotated[qq_dat_annotated$strand=='+','start'] <- qq_dat_annotated[qq_dat_annotated$strand=='+','gene_start']-1
qq_dat_annotated[qq_dat_annotated$strand=='+','end'] <- qq_dat_annotated[qq_dat_annotated$strand=='+','gene_start']

qq_dat_annotated[qq_dat_annotated$strand=='-','start'] <- qq_dat_annotated[qq_dat_annotated$strand=='-','gene_end']-1
qq_dat_annotated[qq_dat_annotated$strand=='-','end'] <- qq_dat_annotated[qq_dat_annotated$strand=='-','gene_end']
print(qq_dat_annotated %>% head())
##########################

##########################
##STEP 3: Renaming/Reordering columns to match exactly QTLtools specified BED file format as follows
#Chr start end pid gid strand 
##########################
#Renaming columns
qq_dat_annotated <- qq_dat_annotated %>% rename(pid=ID)%>% rename(gid=gene_id) %>% rename(`#Chr`=X.Chr)
#Reordering columns
qq_dat_annotated <- qq_dat_annotated %>% relocate(gid,.after='pid') %>% relocate(strand,.after='gid')

##########################
##STEP 4: Removing unneeded columns that resulted from the left_join with the cluster_to_gene_map
##########################
qq_dat_annotated <- qq_dat_annotated %>% select(-c(clu,gene_chr,gene_name,gene_start,gene_end))

##########################
##STEP 5: Writing final table to output file
##########################
write.table(qq_dat_annotated,file=output_file,quote=F, row.names=F,sep='\t')