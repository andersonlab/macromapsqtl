source /nfs/team152/oe2/sqtl/scripts/configs.sh
source /nfs/team152/oe2/sqtl/scripts/paths.sh

base_cond=$1
cond=$2
realigned_bam_dir=$3
grouping_file=$4


# grouping_file="$ds_grouping_dir""$base_cond"_"$cond"_nocovars.grouping
printf "%s" "" > $grouping_file
base_cond_bam_files="$realigned_bam_dir""$base_cond"/*.Aligned.sortedByCoord.waspFiltered.out.bam
for base_cond_bam_file in $base_cond_bam_files; do
  f_base_cond="${base_cond_bam_file##*/}"
  sample_base_cond="${f_base_cond%%.*}"
  printf "%s\t%s\n" $sample_base_cond $base_cond >> $grouping_file
done;

cond_bam_files="$realigned_bam_dir""$cond"/*.Aligned.sortedByCoord.waspFiltered.out.bam
for cond_bam_file in $cond_bam_files; do
  f_cond="${cond_bam_file##*/}"
  sample_cond="${f_cond%%.*}"
  printf "%s\t%s\n" $sample_cond $cond >> $grouping_file
done;



echo Created all grouping files for "$base_cond" vs. "$cond" with no covars in "$grouping_file"
