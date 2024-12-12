#!/usr/bin/bash

#USAGE: bash ./plot_sqtl.sh 1200 20 0.01 ENSG00000175354.18 chr18 12812365 12832944 rs80262450 chr18:12818923 "clu_13508_-" $GTE_MAP "/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/realignedBam/" "_CIL_24.Aligned.sortedByCoord.waspFiltered.out.bam" "/lustre/scratch123/hgi/projects/macromapsqtl/oe2/output/tmp/sashimi/"



######################################################
##########Checking required software##################
######################################################
# Function to check if a command exists
check_command() {
  local cmd="$1"
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required program '$cmd' is not installed or not in PATH."
    exit 1
  fi
}

# Check for required programs
check_command "samtools"
check_command "bamCoverage"
check_command "bedGraphToBigWig"
check_command "pyGenomeTracks"
check_command "bcftools"
######################################################
##########Checking command-line arguments#############
######################################################
# Check if the required number of arguments is provided
if [ "$#" -lt 13 ]; then
  echo "Error: Missing arguments."
  echo "Usage: $0 <num_bins> <ylim_max> <scale_line_height> <gene> <chr> <s> <e> <snp> <clus> <gte_map> <rnaseq_bam_prefix> <rnaseq_bam_suffix> <output_dir>"
  exit 1
fi

# Assign command-line arguments to variables
num_bins="$1"
ylim_max="$2"
scale_line_height="$3"
gene="$4"
chr="$5"
s="$6"
e="$7"
snp="$8"
snp_pos="$9"
$vcf_input_file="$10"
clus=("${11}")
gte_map="${12}"
rnaseq_bam_prefix="${13}"
rnaseq_bam_suffix="${14}"
output_dir="${15}"




# Function to check if a variable is empty
check_empty_arg() {
  local var_name="$1"
  local var_value="$2"
  if [ -z "$var_value" ]; then
    echo "Error: Missing value for argument: $var_name"
    exit 1
  fi
}

# Check each argument
check_empty_arg "num_bins" "$num_bins"
check_empty_arg "ylim_max" "$ylim_max"
check_empty_arg "scale_line_height" "$scale_line_height"
check_empty_arg "gene" "$gene"
check_empty_arg "chr" "$chr"
check_empty_arg "s" "$s"
check_empty_arg "e" "$e"
check_empty_arg "snp" "$snp"
check_empty_arg "snp_pos" "$snp_pos"
check_empty_arg "vcf_input_file" "$vcf_input_file"
check_empty_arg "clus" "${clus[*]}"
check_empty_arg "gte_map" "$gte_map"
check_empty_arg "rnaseq_bam_prefix" "$rnaseq_bam_prefix"
check_empty_arg "rnaseq_bam_suffix" "$rnaseq_bam_suffix"
check_empty_arg "output_dir" "$output_dir"

# Display the values (optional for debugging)
echo "num_bins: $num_bins"
echo "ylim_max: $ylim_max"
echo "scale_line_height: $scale_line_height"
echo "gene: $gene"
echo "chr: $chr"
echo "s: $s"
echo "e: $e"
echo "snp: $snp"
echo "snp_pos: $snp_pos"
echo "vcf_input_file: $vcf_input_file"
echo "clus: ${clus[*]}"
echo "gte_map: $gte_map"
echo "rnaseq_bam_prefix: $rnaseq_bam_prefix"
echo "rnaseq_bam_suffix: $rnaseq_bam_suffix"
echo "output_dir: $output_dir"

######################################################
######################################################
######################################################


region_length=$(($e-$s))
mkdir -p "$output_dir"

#1.Getting genotypes
vcf_output_file="$output_dir""$snp".txt
bash ./get_genotypes.sh "$snp" "$snp_pos" "$vcf_input_file" "$vcf_output_file"
echo Got genotypes...

#2.Merging bams for each genotype group
gs=(0 1 2); for g in "${gs[@]}"; do bash ./merge_bams.sh "${gte_map}" "$g" "$snp" "$chr" "$s" "$e" "${clus[@]}" "$output_dir" ${rnaseq_bam_prefix} ${rnaseq_bam_suffix}; done;


#3.Generating track files (bigwig and links) for each genotype group (0,1,2)
bash ./generate_track_file.sh "${output_dir}${snp}_${chr}_${s}_${e}_0.avg" "${output_dir}${snp}_${chr}_${s}_${e}_0.avg.bw" "${output_dir}${snp}_${chr}_${s}_${e}_0.links""${links_suffix}" "${output_dir}${snp}_${chr}_${s}_${e}_1.avg" "${output_dir}${snp}_${chr}_${s}_${e}_1.avg.bw" "${output_dir}${snp}_${chr}_${s}_${e}_1.links""${links_suffix}" "${output_dir}${snp}_${chr}_${s}_${e}_2.avg" "${output_dir}${snp}_${chr}_${s}_${e}_2.avg.bw" "${output_dir}${snp}_${chr}_${s}_${e}_2.links""${links_suffix}" "GENCODE" "$GENCODE_GTF_FILE" "$num_bins" "${ylim_max}" "${scale_line_height}" > "$output_dir""${snp}_${chr}_${s}_${e}".ini "${region_length}"
echo "Track file $output_dir${snp}_${chr}_${s}_${e}.ini"


#4.Creating plot
output_f="$output_dir""${gene}_${snp}_${chr}_${s}_${e}".pdf
plot_cmd="pyGenomeTracks --tracks ${output_dir}${snp}_${chr}_${s}_${e}.ini --region ${chr}:${s}-${e} -t \"${chr}:${s}-${e} (sQTL = ${snp})\" --width 16 --trackLabelFraction 0.01 -out ${output_f} --fontSize 6"
echo $plot_cmd
printf "===========\nYou will find the pdf at:\n %s\n" "$output_f"
