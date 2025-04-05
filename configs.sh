#!/bin/bash
source /nfs/team152/oe2/sqtl/scripts/paths.sh;
conds=("CIL_24" "CIL_6" "Ctrl_24" "Ctrl_6" "IFNB_24" "IFNB_6" "IFNG_24" "IFNG_6" "IL4_24" "IL4_6" "LIL10_24" "LIL10_6" "MBP_24" "MBP_6" "P3C_24" "P3C_6" "PIC_24" "PIC_6" "Prec_D0" "Prec_D2" "R848_24" "R848_6" "sLPS_24" "sLPS_6")
base_conds=("Ctrl_6" "Ctrl_24" "Prec_D0")


SEED=1354145
PERMUTATIONS=1000
PCs=(0 1 2 3 4 5 6 7 8 9 10 20 50)
mini_PCs=(1 2 3 4 5)

id_col_qq=ID
id_col_noqq=chrom

WINDOW=1000000
WINDOW_NAME=1mb
window=1000000
window_name=1mb
#PCs with maximum number of sQTLs for each condition - outputs an associative array ["condition" => "PC"]
max_PCs=($(awk -F "\t" '{print $2}' permutation_sqtl_num_1mb_max_pc_July_2021.txt))
max_conds=($(awk -F "\t" '{print $1}' permutation_sqtl_num_1mb_max_pc_July_2021.txt))
declare -A max_cond_PC; for i in "${!max_PCs[@]}"; do max_cond_PC["${max_conds[i]}"]="${max_PCs[i]}"; done;
#To iterate over max_cond_PC in bash
#for cond in "${!max_cond_PC[@]}"; do echo $cond; echo "${max_cond_PC[$cond]}"; echo "==="; done;

#Colocs and their files
gwas_categories=(1.Autoimmune_Inflamatory_disease 2.Heart_related_diseases_traits 3.Cancer 4.Blood_related_diseases_traits 5.Neuro_related_diseases_traits 6.Other)
#gwas_names=($(for gwas_category in "${gwas_categories[@]}"; do for d in "${GWAS_DOWNLOADED_SUMMSTAT_BASEDIR}""${gwas_category}/"*; do awk 'BEGIN{FS="\t"}{print $1}' "$d"/*_gwas_files.txt; done; done;))
#REMEMBER TO REGENERATE THE $GWAS_FILES_LIST WHEN YOU UPDATE $exclude_gwas
exclude_gwas=(POS)
gwas_names=($(awk 'BEGIN{FS="\t"}{print $1}' "$GWAS_FILES_LIST"))


nominal_chunks=50
somatic_chr=($(seq 1 22))

###
#GTEx
gtex_tissues=(Adipose_Subcutaneous Adipose_Visceral_Omentum Adrenal_Gland Artery_Aorta Artery_Coronary Artery_Tibial Brain_Amygdala Brain_Anterior_cingulate_cortex_BA24 Brain_Caudate_basal_ganglia Brain_Cerebellar_Hemisphere Brain_Cerebellum Brain_Cortex Brain_Frontal_Cortex_BA9 Brain_Hippocampus Brain_Hypothalamus Brain_Nucleus_accumbens_basal_ganglia Brain_Putamen_basal_ganglia Brain_Spinal_cord_cervical_c-1 Brain_Substantia_nigra Breast_Mammary_Tissue Cells_Cultured_fibroblasts Cells_EBV-transformed_lymphocytes Colon_Sigmoid Colon_Transverse Esophagus_Gastroesophageal_Junction Esophagus_Mucosa Esophagus_Muscularis Heart_Atrial_Appendage Heart_Left_Ventricle Kidney_Cortex Liver Lung Minor_Salivary_Gland Muscle_Skeletal Nerve_Tibial Ovary Pancreas Pituitary Prostate Skin_Not_Sun_Exposed_Suprapubic Skin_Sun_Exposed_Lower_leg Small_Intestine_Terminal_Ileum Spleen Stomach Testis Thyroid Uterus Vagina Whole_Blood)


