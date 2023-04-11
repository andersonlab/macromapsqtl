source /nfs/team152/oe2/sqtl/scripts/paths.sh;
source /nfs/team152/oe2/sqtl/scripts/configs.sh;


for cond in "${conds[@]}"; do
	mkdir -p "$BAM_DIR""$cond"/
	for bam in "$UNALIGNED_BAMS_DIR""$cond"/*.bam; do
		target_bam="$BAM_DIR""$cond"/"${bam##*/}"
		
		ln -s "$bam" "$target_bam"
        done;
done;
