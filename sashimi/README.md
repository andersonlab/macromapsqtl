# Visualise splicing QTLs as sashimi plots

This is a collection of scripts that were used to generate sQTL sashimi plots for the sQTL MacroMap paper (El Garwany et al.). 

## Requirements

These scripts build on some utility tools:
 - [`deepTools`](https://deeptools.readthedocs.io/en/develop/index.html)

 - [`pygenometracks`](https://github.com/deeptools/pyGenomeTracks) 
 - [`bedGraphToBigWig`](https://www.encodeproject.org/software/bedgraphtobigwig/)
 

You should ensure that these tools are installed and are available in the `$PATH` environment variable. 

## Usage

Our pipeline consists of three steps which are written in a combination of `bash` and `python`. Internally, it performs the following steps:

 1. Subset genotypes for a query SNP from  the genotype VCF file using `get_genotypes.sh`. Note that you also need to provide a position to avoid ambiguity. As it uses only SNP ID and position, our tool cannot handle multi-allelic SNPs. 

 
 2. Averaging coverage and intron usage ratios within each genotype group using `merge_bams.sh`. This will compute mean coverage within a pre-defined window across all RNA-seq samples that have a similar genotype with regards to the query SNP. Currently, you also need to provide a tab-separated file `${GTE_MAP}` which specifies the mapping between genotype sample IDs and RNA-seq sample IDs. Unfortunately, this is currently required even if the sample names are consistent.

 




