#!/usr/bin/bash

snp=$1 #SNP name e.g. rsid
pos=$2 #SNP position e.g. chr1:7654321
vcf_input_file=$3 #Path to input VCF file
vcf_output_file=$4 #Path to store output VCF file

#bcftools query -f '[%SAMPLE\t%DS\n]' --regions $pos "$vcf_input_file" | awk 'BEGIN{FS="\t";OFS="\t"}{printf "%s\t%.0f\n",$1,$2}' | sort -t $'\t' -nk 2  > "$vcf_output_file"
bcftools view -i 'ID="$snp"' --regions $pos "$vcf_input_file" | \
bcftools query -f '[%SAMPLE\t%DS\n]' | \
awk 'BEGIN{FS="\t";OFS="\t"}{printf "%s\t%.0f\n",$1,$2}' | sort -t $'\t' -nk 2  > "$vcf_output_file"
