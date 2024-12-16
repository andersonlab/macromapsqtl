#!/bin/bash
#In this paths file, I define paths to directories and files that are used globally across the project
#USAGE: Include it in any bash script using "source paths.sh"
#or in python scripts by making the file path a command line argument and then run a wrapper around it

NFS_BASE_DIR=/nfs/team152/oe2/sqtl/
LUSTRE_BASE_DIR=/lustre/scratch115/teams/anderson/users/oe2/sqtl/

SCRIPTS_DIR="$NFS_BASE_DIR"scripts/
DATA_DIR="$NFS_BASE_DIR"data/
OUTPUT_DIR="$LUSTRE_BASE_DIR"output/
OUTPUT_DIR_SCRATCH119=/lustre/scratch119/humgen/teams/gaffney/oe2/sqtl/output/
OUTPUT_DIR_SCRATCH123=/lustre/scratch123/hgi/projects/macromapsqtl/
#Subdirectories of $OUTPUT_DIR
JUNC_DIR="$OUTPUT_DIR"junc/
JOB_LOGS_DIR="$OUTPUT_DIR"job_logs/

#Subdirectories of $DATA_DIR
UNALIGNED_BAMS_DIR=/lustre/scratch123/hgi/teams/anderson/projects/MacroMap/Bams/
BAM_DIR="$DATA_DIR"bam/
REALIGNED_BAM_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/realignedBam/

#Subdirectories of $SCRIPTS_DIR
LEAFCUTTER_SCRIPTS_DIR="$SCRIPTS_DIR"leafcutter_July_2021/
BAM2JUNC_LEAFCUTTER_SCRIPT="$LEAFCUTTER_SCRIPTS_DIR"scripts/bam2junc.sh

BAM2JUNC_SCRIPTS_DIR="$SCRIPTS_DIR"bam2junc/
BAM2JUNC_COMMANDS_FILE="$BAM2JUNC_SCRIPTS_DIR"bam2junc_commands.txt

MISC_SCRIPTS_DIR="$SCRIPTS_DIR"misc/

#Intron clustering dirs
MISC_DATA_DIR="$DATA_DIR"misc/
JUNC_FILE_LIST="$MISC_DATA_DIR"junc_files_list.txt
PRINT_JUNC_FILENAMES_SCRIPT="$SCRIPTS_DIR"intron_clustering/print_junc_filenames.py
INTRON_CLUSTERING_LEAFCUTTER_SCRIPT="$LEAFCUTTER_SCRIPTS_DIR"clustering/leafcutter_cluster.py
# INTRON_CLUSTERING_OUTPUT_DIR="$OUTPUT_DIR"intron_clustering/
INTRON_CLUSTERING_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/intron_clustering/

#Chunking intron clustering counts
POOLED_INTRON_CLUSTERING_COUNT_FILE="$INTRON_CLUSTERING_OUTPUT_DIR"leafcutter_perind.counts.gz
CHUNKED_INTRON_CLUSTERING_OUTPUT_DIR="$OUTPUT_DIR"intron_clustering_per_condition/
CHUNK_INTRON_CLUSTERING_SCRIPT="$SCRIPTS_DIR"chunk_intron_clustering_counts/chunk_intron_clustering_counts.py

#Preparing sQTL input

PREPARE_SQTL_INPUT_SCRIPT="$LEAFCUTTER_SCRIPTS_DIR"scripts/prepare_phenotype_table.py
PREPARE_SQTL_INPUT_MODIFIED_SCRIPT="$LEAFCUTTER_SCRIPTS_DIR"scripts/prepare_phenotype_table_oe2.py
PCS=100

PREPARE_SQTL_INPUT_SCRIPTS_DIR="$SCRIPTS_DIR"prepare_sqtl_input/
PREPARE_SQTL_INPUT_COMMANDS_FILE="$PREPARE_SQTL_INPUT_SCRIPTS_DIR"prepare_sqtl_input_commands_list.txt
PREPARED_SQTL_INPUT_JOB_LOGS_DIR="$JOB_LOGS_DIR"prepared_sqtl_input/


#Refine clusters paths
REFINE_CLUSTERS_SCRIPT="$SCRIPTS_DIR"refine_clusters/refine_clusters.py
REFINED_CLUSTERS_OUTPUT_DIR="$OUTPUT_DIR"refined_clusters/
# REFINED_INTRONS_LIST="$REFINED_CLUSTERS_OUTPUT_DIR"criterion_2/refined_clusters_2.list

#Differential splicing
# MISC_OUTPUT_DIR=/lustre/scratch115/teams/anderson/users/oe2/sqtl/output/misc/
MISC_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/misc/

SAMPLE_SIZE_FILE="$MISC_OUTPUT_DIR"power.conditions.txt
GENCODE_EXONS_FILE="$MISC_OUTPUT_DIR"exons.gencode.v27.annotation.gtf.gz
GTF_TO_EXONS_SCRIPT="$LEAFCUTTER_SCRIPTS_DIR"leafcutter/scripts/gtf_to_exons.R
GENCODE_GTF_FILE=/lustre/scratch126/humgen/teams/gaffney/np12/MacroMap/Annotation/gencode/gencode.v27.annotation.gtf.gz
GENCODE_GTF_FILE_UNCOMPRESSED=/lustre/scratch126/humgen/teams/gaffney/np12/MacroMap/Annotation/gencode/gencode.v27.annotation.gtf
GENCODE_V45_GTF_FILE_UNCOMPRESSED=/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/ref/gencode_v45/gencode.v45.chr_patch_hapl_scaff.annotation.gtf
SORTED_GENCODE_GTF_FILE=/lustre/scratch119/realdata/mdt3/teams/gaffney/np12/MacroMap/Annotation/gencode/gencode.v27.annotation.gtf_sorted.gtf.gz
REF_GENOME_FILE=/lustre/scratch126/humgen/teams/gaffney/np12/MacroMap/Annotation/GRCh38.primary_assembly.genome.fa
REF_GENOME_FILE=/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/ref/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna
REF_GENOME_FILE=/lustre/scratch125/humgen/resources/ref/Homo_sapiens/GRCh38_15/Homo_sapiens.GRCh38_15.fa

CLUSTER_TO_GENE_MAP="$MISC_OUTPUT_DIR"cluster_to_gene_map.txt
INTRON_TO_CLUSTER_TO_GENE_MAP="$MISC_OUTPUT_DIR"intron_to_cluster_to_gene_map.bed.gz
GENCODE_GENEID_FILE=/lustre/scratch126/humgen/teams/gaffney/np12/MacroMap/Annotation/gencode/gencode.v27.annotation_chr_pos_strand_geneid_gene_name.gtf
GENCODE_TSS_FILE="$MISC_OUTPUT_DIR"gene_tss.txt
SNP_ID_POS_FILE=/lustre/scratch126/humgen/teams/gaffney/np12/MacroMap/Data/Genotypes/vcf_hipsci_hg38/DS_Filt_M/chr_position_ID_major_minor_MAF.txt.gz
REF_ALT_FILE=/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/misc/CHROM_POS_ID_REF_ALT_MAF.txt.gz
REF_ALT_MAJOR_MINOR_FILE=/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/misc/CHROM_POS_ID_REF_ALT_MAJOR_MINOR_MAF.txt.gz

POOLED_INTRON_CLUSTERING_NUMERS_FILE="$INTRON_CLUSTERING_OUTPUT_DIR"leafcutter_perind_numers.counts.gz
PREPARED_INTRON_CLUSTERING_NUMERS_DIR="$OUTPUT_DIR"prepared_ds_input/
PREPARED_INTRON_CLUSTERING_NUMERS_FILES_POOLED="$PREPARED_INTRON_CLUSTERING_NUMERS_DIR"leafcutter_perind_numers.counts_renamed.gz

STRAND_FILE="$MISC_DATA_DIR"gencode.v27.annotation_chr_pos_strand_geneid_gene_name.gtf

#Differential splicing
DS_SCRIPT="$LEAFCUTTER_SCRIPTS_DIR"leafcutter/scripts/leafcutter_ds.R
DS_PIPELINE_DIR="$SCRIPTS_DIR"differential_splicing/

DS_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/ds/
DS_GROUPINGS_OUTPUT_DIR="$DS_OUTPUT_DIR"groupings/
DS_RESULTS_OUTPUT_DIR="$DS_OUTPUT_DIR"res/
DS_COUNTS_OUTPUT_DIR="$DS_OUTPUT_DIR"counts/
DS_COMPARISONS_LIST="$MISC_OUTPUT_DIR"ds/ds_comparisons.txt
#Prepared sqtl input directories
# PREPARED_SQTL_INPUT_DIR="$OUTPUT_DIR_SCRATCH119"prepared_sqtl_input/
PREPARED_SQTL_INPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/prepared_sqtl_input/
SQTL_COVARS_OUTPUT_DIR="$OUTPUT_DIR"sqtl_covars/
# PREPARED_SQTL_INPUT_DIR="$OUTPUT_DIR_SCRATCH119"prepared_sqtl_input_refined_clusters_3/
COV_DIR=/lustre/scratch115/teams/anderson/users/oe2/sqtl/output/sqtl_covars/
# VCF=/lustre/scratch119/realdata/mdt3/teams/gaffney/np12/MacroMap/Data/Genotypes/vcf_hipsci_hg38/DS_Filt_M/hipsci.wec.gtarray.HumanCoreExome.imputed_phased.INFO_0.4_filtered.20180102.genotypes.all_chr.hg38.sorted_unique_annotate_MAF5_filterMissing_added_DS.bcf.gz
VCF=/lustre/scratch126/humgen/teams/gaffney/np12/MacroMap/Data/Genotypes/vcf_hipsci_hg38/DS_Filt_M/hipsci.wec.gtarray.HumanCoreExome.imputed_phased.INFO_0.4_filtered.20180102.genotypes.all_chr.hg38.sorted_unique_annotate_MAF5_filterMissing_added_DS.vcf.gz

#Mappting sQTL Permutation Pass
SQTL_PERMUTATION_SCRIPTS_DIR="$SCRIPTS_DIR"map_sqtl_permutation/
SQTL_NOMINAL_SCRIPTS_DIR="$SCRIPTS_DIR"map_sqtl_nominal/

QTLTOOLS_BINARY="QTLtools"
# SQTL_PERMUTATION_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH119"sqtl_permutation_output_May_2021/
SQTL_PERMUTATION_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/sqtl_permutation_output_July_2021/
# SQTL_NOMINAL_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH119"sqtl_nominal_output_July_2021/
# SQTL_NOMINAL_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/sqtl_nominal_output_July_2021/
SQTL_NOMINAL_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/sqtl_nominal_output_April_2022/

#SQTL_NOMINAL_OUTPUT_DIR=/lustre/scratch119/humgen/teams/gaffney/oe2/sqtl/output/sqtl_output_nominal/1mb/
COV_DIR="${OUTPUT_DIR_SCRATCH123}"oe2/output/cov/
#SQTL_OUTPUT_DIR="$OUTPUT_DIR"sqtl_output/1mb/

#Plots and plots Data
# PLOT_DIR="$LUSTRE_BASE_DIR"plots/
PLOT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/plots/
COND_PC_NUM_FILE="${PLOT_DIR}"plot_data/permutation_sqtl_num_1mb_pc_July_2021.txt
MAX_COND_PC_NUM_FILE="${PLOT_DIR}"plot_data/permutation_sqtl_num_1mb_max_pc_July_2021.txt

#MASHR
MASHR_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH119"mashr_May_2021/
MASHR_JOB_LOGS_DIR="$JOB_LOGS_DIR"mashr/
MASHR_SCRIPTS_DIR="$SCRIPTS_DIR"mashr/

#WASP
STAR_INDEX=/lustre/scratch119/realdata/mdt3/teams/gaffney/np12/MacroMap/Annotation/STAR_index/
WASP_SCRIPTS_DIR="$SCRIPTS_DIR"WASP/
WASP_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH119"bamwasp/
WASP_JOB_LOGS_DIR="$JOB_LOGS_DIR"bamwasp/

#PYGENOMETRACKS
CHROM_SIZES_HG38="$MISC_OUTPUT_DIR"hg38.chrom.sizes
GTE_MAP=/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/misc/gte_mapping.txt

#COLOC
GWAS_DOWNLOADED_SUMMSTAT_BASEDIR=/nfs/users/nfs_n/np12/myscratch/MacroMap/Data/GWAS/GWAS_catalogJuly20/All_files/
GWAS_PROCESSED_SUMMSTAT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/gwas/
TMP_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/tmp/
MACROMAP_COLOC_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/macromap_coloc/
MACROMAP_EQTL_COLOC_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/macromap_coloc_eqtl/
GTEX_COLOC_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/gtex_coloc/
ALL_MACROMAP_COLOC_FILE="$MACROMAP_COLOC_OUTPUT_DIR"all.coloc
ALL_GTEX_COLOC_FILE="$GTEX_COLOC_OUTPUT_DIR"all.coloc
GWAS_FILES_LIST="$MISC_OUTPUT_DIR"gwas_files_list.txt

#GTEX
SQTL_GTEX_SUMMSTAT_DIR=/lustre/scratch118/humgen/resources/GTEx/AnalysisV8/GTEx_Analysis_v8_EUR_sQTL_all_associations/
SQTL_GTEX_PROCESSED_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/sqtl_gtex_summstat/
GENCODE_V26_GTF_FILE="$MISC_OUTPUT_DIR"gencode.v26.annotation.gtf.gz
GENCODE_V26_GENEID_FILE="$MISC_OUTPUT_DIR"gencode.v26.annotation_chr_pos_strand_geneid_gene_name.gtf
GENCODE_V26_TSS_FILE="$MISC_OUTPUT_DIR"gencode_v26.gene_tss.txt
GTEX_SAMPLE_DATA_FILE="$MISC_OUTPUT_DIR"gtex_sample_data.txt
EQTL_GTEX_SUMMSTAT_DIR=/lustre/scratch125/humgen/resources/GTEx/AnalysisV8/GTEx_processed/
EQTL_GTEX_PROCESSED_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/eqtl_gtex_summstat/
GTEX_EQTL_COLOC_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/gtex_coloc_eqtl/


#EQTL
EQTL_SUMMSTAT_DIR=/nfs/users/nfs_n/np12/myscratch/MacroMap/Analysis/eQTLs/Macromap_fds/analysis/eQTLs_per_TSS/1MB/nominal/
EQTL_PROCESSED_OUTPUT_DIR="$OUTPUT_DIR_SCRATCH123"oe2/output/eqtl_nominal/

#SNAKEMAKE UTILS
SNAKEMAKE_STATUS_SCRIPT="${SCRIPTS_DIR}"snakemake_utils/snakemake_status.py
RSCRIPT4_PATH="export R_LIBS_USER=/software/team152/oe2/R/x86_64-pc-linux-gnu-library/4.1.0;/software/R-4.1.0/bin/Rscript"
