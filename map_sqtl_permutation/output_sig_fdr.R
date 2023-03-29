library(qvalue)
# library(biomaRt)
library(tidyverse)


args = commandArgs(trailingOnly=TRUE)

cond <- args[1]
PC <- args[2]
sqtl_f <- args[3]
output_sig_f <- args[4]
fdr_level <- args[5]
if (length(args) < 6) {
  excluded_genes_file=NULL
} else {
  excluded_genes_file=args[6]
}

d <- read.table(sqtl_f, hea=FALSE, stringsAsFactors=FALSE)

if (!is.null(excluded_genes_file)) {
  excluded_genes <- read.csv(excluded_genes_file,sep='\t',header=F,stringsAsFactors=F)
  d <- d %>% filter(!(V1 %in% excluded_genes$V1))
}

#d$gene <- as.character(sapply(str_split(d$V1,pattern='\\.'),'[',1))

#ensembl <- useEnsembl(biomart = "ensembl", dataset = "hsapiens_gene_ensembl")
#filters <- c('ensembl_gene_id')
#atts <- c('ensembl_gene_id','gene_biotype')
#vals <- unique(d$gene)
#bm <- getBM(filters=filters,attributes=atts,values=vals,mart=ensembl)
#bm_coding_lncrna <- bm %>% filter(gene_biotype %in% c('protein_coding','lncRNA')) %>% .$ ensembl_gene_id
#d <- d %>% filter(gene %in% bm_coding_lncrna) %>% select(-c(gene))

d=d[!is.na(d$V19),]
d$qval=qvalue(d$V21)$qvalue

write.table(d[which(d$qval <= as.numeric(fdr_level) ), ], output_sig_f, quote=FALSE, row.names=FALSE,col.names=FALSE)

print(paste0("Finished condition: ",cond, " PCs ",PC, '. Output file: ',output_sig_f,'.'))

#Usage:
#Rscript output_sig_fdr.R $cond $PC $input_qtl_file $output_sig_qtl_file;




#######
