#!/bin/sh

zero_name=$1
zero_bw_file=$2
zero_links_file=$3

one_name=$4
one_bw_file=$5
one_links_file=$6

two_name=$7
two_bw_file=$8
two_links_file=$9

annotation_name="${10}"
annotation_file="${11}"

num_bins="${12}"
ylim_max="${13}"
scale_line_height="${14}"
# num_bins=$(($region_length / 10))
# num_bins=100
###
fontsize=6
scale_link_height="${scale_line_height}"
scale_line_width=3

###
a="[spacer]
height = 0.25

[scale]
title =
height = 0.1
#line_width = 0.4
where = right
fontsize = ${fontsize}
file_type = scalebar

[spacer]
height = 0.25

[${zero_name}]
bw_file = ${zero_bw_file}
link_file = "${zero_links_file}"
title = 0
height = 2
bw_color = darkblue
number_of_bins = ${num_bins}
max_value = ${ylim_max}
min_value = 0
nans_to_zeros = true
summary_method = mean
show_data_range = true
link_color = darkblue
line_style = solid
fontsize = ${fontsize}
#line_width = 0.4
scale_link_height = ${scale_link_height}
scale_line_width = ${scale_line_width}
file_type = sashimiBigWig
width=0.3

[spacer]
height = 0.1"
if [ $(cat $one_bw_file | wc -l) -gt 0 ]; then

a="${a}


[${one_name}]
bw_file = ${one_bw_file}
link_file = "${one_links_file}"
title = 1
height = 2
bw_color = purple
number_of_bins = ${num_bins}
max_value = ${ylim_max}
min_value = 0
nans_to_zeros = true
summary_method = mean
show_data_range = true
link_color = purple
line_style = solid
fontsize = ${fontsize}
#line_width = 0.4
scale_link_height = ${scale_link_height}
scale_line_width = ${scale_line_width}
file_type = sashimiBigWig

[spacer]
height = 0.1"
fi;

if [ $(cat $two_bw_file | wc -l) -gt 0 ]; then
a="${a}

[${two_name}]
bw_file = ${two_bw_file}
link_file = "${two_links_file}"
title = 2
height = 2
bw_color = orange
number_of_bins = ${num_bins}
max_value = ${ylim_max}
min_value = 0
nans_to_zeros = true
summary_method = mean
show_data_range = true
link_color = orange
line_style = solid
fontsize = ${fontsize}
#line_width = 0.4
scale_link_height = ${scale_link_height}
scale_line_width = ${scale_line_width}
file_type = sashimiBigWig

[spacer]
height = 0.1"
fi;

a="${a}


[${annotation_name}]
file = ${annotation_file}
title =
style = UCSC
labels = true
fontsize = 6
height = 5
file_type = gtf
arrow_length = 1000
arrow_interval = 20
all_labels_inside = false
labels_in_margin = true"

echo "$a"
