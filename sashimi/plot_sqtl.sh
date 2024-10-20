#!/usr/bin/bash
# conda activate pygenometracks
#PTPN2: bash ./plot_sqtl.sh 1200 160 1 ENSG00000175354.18 chr18 12812365 12832944 rs80262450 sLPS_6 "clu_12029_-"; bash ./plot_sqtl.sh 1200 20 0.01 ENSG00000175354.18 chr18 12812365 12832944 rs80262450 Ctrl_6 "clu_13508_-"
#TOM1:  bash ./plot_sqtl.sh 1200 40 1 ENSG00000100284.20 chr22 35332782 35334782 rs138788 CIL_6 "clu_16354_+"
#TOM1:  bash ./plot_sqtl.sh 1200 40 1 ENSG00000100284.20 chr22 35337788 35346205 rs138788 LIL10_6 "clu_17160_+"
#DENND1B bash ./plot_sqtl.sh 60000 10 0.01 ENSG00000213047.12 chr1 197710074 197778868 rs2224873 CIL_24 "clu_1143_-"
#USAGE: bsub -I -R "select[mem>8000] rusage[mem=8000]" -M 8000 -J "plot_sqtl" -m "modern_hardware" "conda activate pygenometracks ; bash ./plot_sqtl.sh 50 ENSG00000175354.18 chr18 12814365 12821944 rs80262450 sLPS_24 \"clu_12029_-\" "
#If you want to show only certain linkes:
#python filter_links.py /lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/tmp/sashimi/filter_links.CUSTOM /lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/tmp/sashimi/sLPS_6_rs80262450_chr18_12812365_12832944_0.links /lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/tmp/sashimi/sLPS_6_rs80262450_chr18_12812365_12832944_0.links.CUSTOM
# 16:50693662:50707855


num_bins=$1
ylim_max=$2
scale_line_height=$3
gene=$4
chr=$5
s=$6
e=$7
snp=$8

clus=("${9}")

output_dir="${10}"
plotting_scripts_dir="${PWD}/"

region_length=$(($e-$s))
mkdir -p "$output_dir"

#1.Getting genotypes
vcf_output_file="$output_dir""$snp".txt
bash "$plotting_scripts_dir"get_genotypes.sh "$snp" "$vcf_output_file"
echo Got genotypes...

#2.Merging bams for each genotype group
gs=(0 1 2); for g in "${gs[@]}"; do bash "$plotting_scripts_dir"merge_bams.sh "$g" "$snp" "$chr" "$s" "$e" "${clus[@]}" "$output_dir"; done;


#3.Generating track files (bigwig and links) for each genotype group (0,1,2)
bash "$plotting_scripts_dir"generate_track_file.sh "${output_dir}${snp}_${chr}_${s}_${e}_0.avg" "${output_dir}${snp}_${chr}_${s}_${e}_0.avg.bw" "${output_dir}${snp}_${chr}_${s}_${e}_0.links""${links_suffix}" "${output_dir}${snp}_${chr}_${s}_${e}_1.avg" "${output_dir}${snp}_${chr}_${s}_${e}_1.avg.bw" "${output_dir}${snp}_${chr}_${s}_${e}_1.links""${links_suffix}" "${output_dir}${snp}_${chr}_${s}_${e}_2.avg" "${output_dir}${snp}_${chr}_${s}_${e}_2.avg.bw" "${output_dir}${snp}_${chr}_${s}_${e}_2.links""${links_suffix}" "GENCODE" "$GENCODE_GTF_FILE" "$num_bins" "${ylim_max}" "${scale_line_height}" > "$output_dir""${snp}_${chr}_${s}_${e}".ini "${region_length}"
echo "Track file $output_dir${snp}_${chr}_${s}_${e}.ini"


#4.Creating plot
output_f="$output_dir""${gene}_${snp}_${chr}_${s}_${e}".pdf
plot_cmd="pyGenomeTracks --tracks ${output_dir}${snp}_${chr}_${s}_${e}.ini --region ${chr}:${s}-${e} -t \"${chr}:${s}-${e} (sQTL = ${snp})\" --width 16 --trackLabelFraction 0.01 -out ${output_f} --fontSize 6"
echo $plot_cmd
printf "===========\nYou will find the pdf at:\n %s\n" "$output_f"
