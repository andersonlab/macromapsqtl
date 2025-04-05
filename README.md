# MacroMap splicing QTL paper code

  

This code was used in the analysis of the MacroMap sQTL paper. Many of the components are organised as [Snakemake](https://snakemake.readthedocs.io/en/stable/) files suitable for running on an HPC environment. Note that each of these pipelines are run separately per stimulation conditions. It contains the following directories:

 1. `realign_bam`: used to align FASTQ files to the genome build hg38 using STAR. 
 2. `bam2junc`: uses [regtools](https://regtools.readthedocs.io/en/latest/) to produce junction-level counts and to annotate junctions (commands `regtools junctions extract` and `regtools junction annotate`) as recommended by [Leafcutter](https://davidaknowles.github.io/leafcutter/articles/Usage.html#step-1--converting-bams-to-juncs).
 3. `intron_clustering`: uses output of `bam2junc` to identify intron clusters (see [Leafcutter](https://davidaknowles.github.io/leafcutter/articles/Usage.html#step-2--intron-clustering)).
 4. `prepare_phenotype_table`: contains three pipelines that should be run sequentially (using the `snakewrapper.sh` wrapper script):
	 * `cov.Snakefile`: prepares covariate files consisting of genotype PCs as well as progressively varying numbers of intron usage PCs.
	 * `qq.Snakefile`: prepares phenotype tables, performs quantile-quantile normalisation and maps introns to genes (phenotype preparation is based on Leafutter's `prepare_phenotype_table.py`[\[link\]](https://davidaknowles.github.io/leafcutter/articles/sQTL.html)).
	 * `pheno.Snakefile`: aggregates per-chromosome phenotype tables into a single table per condition, and produces per-junction annotation using `regtools junction annotate`.
	 
 5. `map_sql_permutation`: uses [QTLtools](https://qtltools.github.io/qtltools/pages/mode_cis_permutation.html) to map cis splicing QTLs (permutation pass). Phenotypes (introns) are grouped by gene ID. This consists of mapping a permuation pass sQTLs and FDR correction. This step is additionally used to determine how many principal components are used as covariates in the nominal pass. Briefly, the number of PCs that maximise the number of sGenes per condition is used. 
 6. `map_sqtl_nominal` uses [QTLtools](https://qtltools.github.io/qtltools/pages/mode_cis_nominal.html) to map cis splicing QTLs (nominal pass). To benefit from parallelisation available on large HPC clusters, the resulting summary statistics are divided into 100 chunks. These chunks were not merged during our analyses, but are merged and then split per chromosome in our published [data repository](ftp.sanger.ac.uk/pub/project/humgen/summary_statistics/macromap_sqtl/FTP). 

For any queries, please contact Omar El Garwany (oe2@sanger.ac.uk) or Carl A. Anderson (ca3@sanger.ac.uk)

