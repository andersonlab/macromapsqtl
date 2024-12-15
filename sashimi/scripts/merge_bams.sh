#!/usr/bin/bash

###########
#Usage: bash merge_bams.sh ${GTE_MAP} 0 rs2640906 chr1 77944055 77979110 clu_6995_+ $intron_counts_file $tmp_output_dir /path/to/rnaseq/ $rnaseq_bam_prefix $rnaseq_bam_suffix=
###########
GTE_MAP=$1 #Tab-seaprated file, no headers, with genotype sample ID in the first column and RNA-seq sample id in the second column
seek_genotype=$2
snp=$3
gene_chr=$4
gene_start=$5
gene_end=$6
clus=($7)
intron_counts_file=$8
tmp_output_dir="${9}"
rnaseq_bam_prefix="${10}" #Used to construct the RNA-seq BAM file path (RNA-seq sample name comes between suffix and prefix)
rnaseq_bam_suffix="${11}" #Used to construct RNA-seq BAM file path (RNA-seq sample name comes between suffix and prefix)
region_str="$gene_chr":"$gene_start"-"$gene_end"


#Genotype files
vcf_output_file="$tmp_output_dir""$snp".txt
gene_file="$tmp_output_dir""$gene".bed

#BAM files
sliced_bams_dir="$tmp_output_dir"
merged_bam_dir="$tmp_output_dir"
merged_bam_file="${merged_bam_dir}${snp}_${gene_chr}_${gene_start}_${gene_end}_${seek_genotype}.bam"

#Merged BAM and BigWig files
merged_coverage_bedgraph_file="${merged_bam_dir}${snp}_${gene_chr}_${gene_start}_${gene_end}_${seek_genotype}.bg"
averaged_coverage_bedgraph_file="${merged_bam_dir}${snp}_${gene_chr}_${gene_start}_${gene_end}_${seek_genotype}.avg.bg"
averaged_coverage_bw_file="${merged_bam_dir}${snp}_${gene_chr}_${gene_start}_${gene_end}_${seek_genotype}.avg.bw"

#Links files
output_links_file="${tmp_output_dir}${snp}_${gene_chr}_${gene_start}_${gene_end}_${seek_genotype}.links"


mkdir -p "$tmp_output_dir"
mkdir -p "$sliced_bams_dir"
###########


#1.Obtaining the relevant genotype IDs from the VCF output from the previous step
genotype_samples=($(awk -v seek_genotype=$seek_genotype 'BEGIN{FS="\t"}{if($2==seek_genotype)print $1}' $vcf_output_file))
n="${#genotype_samples[@]}"


#2.Getting RNA-seq samples from genotype samples using the GTE map file (in case they are the same this step may be redundant)
rnaseq_samples=""
rnaseq_samples=$(python -c "import pandas as pd;\
gte_dat=pd.read_csv('${GTE_MAP}',sep='\t',header=None); \
genotype_samples='${genotype_samples[*]}'.split(' '); \
rnaseq_samples=gte_dat.loc[ (gte_dat[0].isin(genotype_samples)),1].tolist(); \
print(' '.join(rnaseq_samples))")
rnaseq_samples=($rnaseq_samples)

#3.Getting BAM files
bam_files=""
for rnaseq_sample in "${rnaseq_samples[@]}"; do
  sample_bam_file="${rnaseq_bam_prefix}${rnaseq_sample}${rnaseq_bam_suffix}"
  bam_files="${sample_bam_file} ${bam_files}"
done;
bam_files=($bam_files)


#4.Sliceing BAM files
sliced_bam_files=""
sliced_bai_files=""
echo ============================================
echo ===========SLICING BAM FILES================
echo ============================================
for (( i=0; i<${#rnaseq_samples[*]}; ++i)); do
  rnaseq_sample="${rnaseq_samples[$i]}"
  bam_file="${bam_files[$i]}"
  if [ ! -f "${bam_file}" ]; then echo "File ${bam_file} not found!"; exit 1; fi

  #Declaring output sliced file
  sliced_f="$sliced_bams_dir""$rnaseq_sample"."$snp"_"$gene_chr"_"$gene_start"_"$gene_end".bam
  sliced_bam_files="${sliced_f} ${sliced_bam_files}"
  sliced_bai_files="${sliced_f}.bai ${sliced_bai_files}"
  #Outputting sliced BAMs
  samtools view -b "$bam_file" "$region_str" > "$sliced_f"
  samtools index "$sliced_f"

  printf "File %s sliced into (region %s): %s\n" "$bam_file" "$region_str" "$sliced_f"
done;
echo ============================================

echo ============================================
echo ===========MERGING BAM FILES================
echo ============================================
#Merging/averaging coverage for BAM files
echo "${sliced_bam_files}"
samtools merge -f -R $region_str $merged_bam_file $sliced_bam_files
rm $sliced_bam_files
rm $sliced_bai_files
samtools index $merged_bam_file
printf "Merged and indexed BAM files into: %s...\n" "$merged_bam_file"
echo ============================================

echo =============================================
echo ===========COMPUTING COVERAGE================
echo =============================================
bamCoverage -b $merged_bam_file -o $merged_coverage_bedgraph_file -of bedgraph -r "${gene_chr}:${gene_start}:${gene_end}" -bs 10
printf "Computed BAM coverage...\n"
awk -v n=$n 'BEGIN{FS="\t";OFS="\t"}{printf "%s\t%s\t%s\t%.2f\n",$1,$2,$3,$4/n}' $merged_coverage_bedgraph_file | sort -k1,1 -k2,2n > $averaged_coverage_bedgraph_file
printf "Average BAM coverage by %s...\n" "$n"
rm $merged_coverage_bedgraph_file
bedGraphToBigWig $averaged_coverage_bedgraph_file data/hg38.chrom.sizes $averaged_coverage_bw_file
printf "Converted BedGraph to BigWig...\n"
echo =============================================

echo ========================================
echo ===========GETTING LINKS================
echo ========================================
#STEP 2: links files
python ./get_links.py --counts-file "$intron_counts_file" --region-chr "$gene_chr" --region-s "$gene_start" --region-e "$gene_end" --output-f "$output_links_file" --samples "${genotype_samples[@]}" --clusters "${clus[@]}"
echo ========================================
