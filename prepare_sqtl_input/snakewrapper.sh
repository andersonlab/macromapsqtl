
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;
source /nfs/team152/oe2/sqtl/scripts/funcs.sh;



#Setting up needed variables


chrom=($(seq 1 22))
group="macromapsqtl"
conds_py=$(bash_list_to_python_list "${conds[@]}")
chrom_py=$(bash_list_to_python_list "${chrom[@]}")
PCs_py=$(bash_list_to_python_list "${PCs[@]}")

workdir="$OUTPUT_DIR_SCRATCH123"oe2/
prepare_sqtl_input_script="$SCRIPTS_DIR"leafcutter_July_2021/leafcutter/scripts/prepare_phenotype_table.py
PC=100

intron_list_file="$MISC_OUTPUT_DIR"all_introns.list
intron_to_gene_map="$MISC_OUTPUT_DIR"intron_to_gene_map.txt
annotate_qq_files_script=/nfs/team152/oe2/sqtl/scripts/prepare_sqtl_input/annotate_qq_files.R
map_clusters_to_genes_script=/nfs/team152/oe2/sqtl/scripts/misc/create_cluster_to_gene_mapping.R
aggergate_per_chrom_qq_files_script=/nfs/team152/oe2/sqtl/scripts/prepare_sqtl_input/aggregate_per_chrom_qq_files.sh
rename_samples_script=/nfs/team152/oe2/sqtl/scripts/prepare_sqtl_input/rename_samples.sh



# snakemake -j 24 -np --config conds="${conds_py}" PCs="${PCs_py}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" cov_dir="${COV_DIR}" --directory "${workdir}" --cluster "rm -r logs/cluster/prepare_phenotype_{rule}; mkdir -p logs/cluster/prepare_phenotype_{rule}; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"prepare_phenotype_{rule}.{wildcards}\" -G ${group} -o logs/cluster/prepare_phenotype_{rule}/{rule}.{wildcards}.out -e logs/cluster/prepare_phenotype_{rule}/{rule}.{wildcards}.err" -s cov.Snakefile

snakemake -j 24 -p --config conds="${conds_py}" chrom="${chrom_py}"  intron_clustering_output_dir="${INTRON_CLUSTERING_OUTPUT_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" PC="${PC}" prepare_sqtl_input_script="${prepare_sqtl_input_script}" rename_samples_script="${rename_samples_script}" exons_file="${GENCODE_EXONS_FILE}" geneid_file="${GENECODE_GENEID_FILE}" intron_to_gene_map="${intron_to_gene_map}" intron_list_file="${intron_list_file}" annotate_qq_files_script="${annotate_qq_files_script}" map_clusters_to_genes_script="${map_clusters_to_genes_script}" aggergate_per_chrom_qq_files_script="${aggergate_per_chrom_qq_files_script}" gencode_gtf_file="${GENCODE_GTF_FILE}" gtf_to_exons_script="${GTF_TO_EXONS_SCRIPT}" --directory "${workdir}" --cluster "rm -r logs/cluster/prepare_phenotype_{rule}; mkdir -p logs/cluster/prepare_phenotype_{rule}; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"prepare_phenotype_{rule}.{wildcards}\" -G ${group} -o logs/cluster/prepare_phenotype_{rule}/{rule}.{wildcards}.out -e logs/cluster/prepare_phenotype_{rule}/{rule}.{wildcards}.err" -s qq.Snakefile

# snakemake -j 24 -R all aggregatePhenFiles renamePhenFiles -np --config conds="${conds_py}" chrom="${chrom_py}"  intron_clustering_output_dir="${INTRON_CLUSTERING_OUTPUT_DIR}" prepared_sqtl_input_dir="${PREPARED_SQTL_INPUT_DIR}" PC="${PC}" prepare_sqtl_input_script="${prepare_sqtl_input_script}" rename_samples_script="${rename_samples_script}" exons_file="${GENCODE_EXONS_FILE}" geneid_file="${GENECODE_GENEID_FILE}" intron_to_gene_map="${intron_to_gene_map}" intron_list_file="${intron_list_file}" annotate_qq_files_script="${annotate_qq_files_script}" map_clusters_to_genes_script="${map_clusters_to_genes_script}" aggergate_per_chrom_qq_files_script="${aggergate_per_chrom_qq_files_script}" gencode_gtf_file="${GENCODE_GTF_FILE}" gtf_to_exons_script="${GTF_TO_EXONS_SCRIPT}" --directory "${workdir}" --cluster "rm -r logs/cluster/prepare_phenotype_{rule}; mkdir -p logs/cluster/prepare_phenotype_{rule}; bsub -R \"rusage[mem={resources.mem_mb}] select[mem>{resources.mem_mb}] span[hosts=1]\" -M {resources.mem_mb} -m \"modern_hardware\" -n {threads} -J \"prepare_phenotype_{rule}.{wildcards}\" -G ${group} -o logs/cluster/prepare_phenotype_{rule}/{rule}.{wildcards}.out -e logs/cluster/prepare_phenotype_{rule}/{rule}.{wildcards}.err" -s pheno.Snakefile


#bsub -I -R"rusage[mem=2000] select[mem>2000]" -n25 -M 2000 -m "modern_hardware" -q long
