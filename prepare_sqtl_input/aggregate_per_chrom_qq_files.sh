#!/usr/bin/env bash
# shellcheck disable=SC1091

source /nfs/team152/oe2/sqtl/scripts/paths.sh
source /nfs/team152/oe2/sqtl/scripts/configs.sh



prefix=$1

#Aggregating chromosome files

agg_chr_file="$prefix"_perind.counts.gz.qqnorm_chrALL_annotated
head -1 "$prefix"_perind.counts.gz.qqnorm_chr1_annotated > $agg_chr_file
for f in "$prefix"_perind.counts.gz.qqnorm_chr*_annotated; do
  if [ $f != $agg_chr_file ]; then tail -n+2 $f >> $agg_chr_file; fi;
done;

#Dropping introns that are not mapped to genes. Keeping them complicates the tabix indexing
python -c "import pandas as pd; dat=pd.read_csv('$agg_chr_file',sep='\t');dat=dat.dropna(subset=['gid']);dat.to_csv('$agg_chr_file',sep='\t',index=False)"

#Sorting the aggregated file
agg_chr_file_sorted="$agg_chr_file"_sorted
python -c "import pandas as pd; dat=pd.read_csv('$agg_chr_file',sep='\t'); dat=dat.sort_values(by=['#Chr','start'],ascending=True); dat.to_csv('$agg_chr_file_sorted',sep='\t',index=False)"

#Outputting the indexing commands
tabix_commands_file="$prefix"_perind.counts.gz_prepare.sh
printf '' > $tabix_commands_file
echo bgzip -f $agg_chr_file_sorted >> $tabix_commands_file
echo tabix -p bed "$agg_chr_file_sorted".gz >> $tabix_commands_file
# echo bgzip -f $agg_chr_file >> $tabix_commands_file


echo Aggregated and sorted all chromosomes: "$agg_chr_file_sorted"
