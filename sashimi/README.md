# Visualise splicing QTLs as sashimi plots

This is a collection of scripts that were used to generate sQTL sashimi plots for the sQTL MacroMap paper (El Garwany et al.). 

## Requirements

These scripts build on some utility tools:
 - [`deepTools`](https://deeptools.readthedocs.io/en/develop/index.html)

 - [`pygenometracks`](https://github.com/deeptools/pyGenomeTracks) 
 - [`bedGraphToBigWig`](https://www.encodeproject.org/software/bedgraphtobigwig/)
 - [`samtools`](https://www.htslib.org/)
 - [`bcftools`](https://samtools.github.io/bcftools/bcftools.html)
 

You should ensure that these tools are installed and are available in the `$PATH` environment variable. 

## Usage

Our pipeline consists of three steps which are written in a combination of `bash` and `python`. Internally, it performs the following:

 1. Subset genotypes for a query SNP from  the genotype VCF file using `get_genotypes.sh`. **Note** that you also need to provide a position to avoid ambiguity. As this pipeline uses only SNP ID and position, it cannot handle multi-allelic SNPs. 

 
 2. Averaging coverage and intron usage ratios within each genotype group using `merge_bams.sh`. This will compute mean coverage within each bin defined based on a user-defined region and a user-defined number of bins. Mean coverage is calculated across all RNA-seq samples that fall in the same genotype group with respect to the query SNP. For intron counts (leafcutter output), usage ratios are averaged similarly.

### Example usage
```
bash ./plot_sqtl.sh \
 {num_bins} {ylim_max} {scale_junction_arc} \
 {gene_id} {region_chr} {region_start} {region_start}\
 {snp_id} {snp_pos} {VCF_file} \
 {intron_cluster_id} \ 
 {GTE_map} \
 {rnaseq_bam_prefix} {rnaseq_bam_suffix}\
 {output_prefix}
```
 The large number of parameters is offered to make plotting as flexible as possible. Often times, plotting parameters such as `{num_bins}`, `{ylim_max}`, `{scale_junction_arc}` can make the plot look awkward especially with very wide or very narrow regions. 


 | **Parameter**           | **Description**                                                                                                                                             |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `num_bins`              | Number of bins to divide the specified region for averaging coverage (e.g. `100`).                                                                                      |
| `ylim_max`              | Maximum value for the y-axis in the plot to control the scale of visualization (e.g.`150`).                                                                             |
| `scale_junction_arc`    | Scaling factor for the junction arc height in the plot, useful for adjusting the visual prominence of splice junctions (e.g.`0.01`).                                     |
| `gene_id`               | Gene ID for which the splicing QTL is being visualized.                                                                                                    |
| `region_chr`            | Chromosome of the region to plot.                                                                                                                          |
| `region_start`          | Start position of the region to plot.                                                                                                                      |
| `region_end`            | End position of the region to plot.                                                                                                                        |
| `snp_id`                | SNP ID for the query SNP (e.g. `rs123456`).                                                                                                                                  |
| `snp_pos`               | Position of the query SNP to ensure no ambiguity, particularly for SNPs with the same ID (e.g. `chr1:1234567`).                                                                  |
| `VCF_file`              | Path to the VCF file containing genotype information.                                                                                                      |
| `intron_cluster_id`     | ID of the intron cluster to be visualized (e.g., from leafcutter output `clu_510_-`).                                                                                   |
| `GTE_map`               | Genotype-to-sample mapping file for grouping RNA-seq samples based on genotype. Tab-separated, no headers with genotype sample labels in the first column and RNA-seq sample labels in the second column.                                                                            |
| `rnaseq_bam_prefix`     | Prefix of RNA-seq BAM files for calculating coverage and intron usage ratios. This is used to build the full BAM path along with `rnaseq_bam_suffix` (i.e. `rnaseq_bam_prefix`+`sample_id`+`rnaseq_bam_suffix`).                                                                             |
| `rnaseq_bam_suffix`     | Suffix of RNA-seq BAM files for calculating coverage and intron usage ratios. This is used to build the full BAM path along with `rnaseq_bam_prefix` (i.e. `rnaseq_bam_prefix`+`sample_id`+`rnaseq_bam_suffix`).                                                                             |
| `output_prefix`         | Prefix for output files generated by the script, including plots and intermediate data. For safety, the pipeline outputs every temporary file to this directory.                                                                 |









