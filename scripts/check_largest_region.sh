<<<<<<< HEAD
WD=/mnt/genetica_1/liriel #set working dir
label="unk" #change to whatever label you're analysing
LABEL_DIR=$WD/unk #change to dir with the chr files of the label
INFOS=$WD/infos
for chr in {1..2}; do
	awk '{print $2,$3,$4,$5}' $LABEL_DIR/chr_info_filt/chr_"${chr}"_"${label}"_sort_filt_size_gap.txt >> $WD/"$label"_chr_sizes.txt
        sort -k4,4nbr -o $WD/"$label"_chr_sizes.txt $WD/"$label"_chr_sizes.txt
	awk 'NR==1 {print; largest_frag = $4; next} {if ($4 == largest_frag) {print $0}}' $WD/"$label"_chr_sizes.txt > $INFOS/largest_"$label"_frag_size.txt
        rm $WD/"$label"_chr_sizes.txt
done
