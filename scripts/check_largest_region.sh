WD=/home/santoro-lab/liri/teste_dir #set working dir
label="unk" #change to whatever label you're analysing
LABEL_DIR=$WD/unk #change to dir with the chr files of the label
INFOS_TXT=$WD/infos_txt
for chr in {1..22}; do
	awk '{print $2,$3,$4,$5}' $LABEL_DIR/chr_info_filt_largest_frag/chr_"${chr}"_"${label}"_sort_filt_size_gap.txt >> $WD/"$label"_chr_sizes.txt
        sort -k4,4nbr -o $WD/"$label"_chr_sizes.txt $WD/"$label"_chr_sizes.txt
	awk 'NR==1 {print; largest_frag = $4; next} {if ($4 == largest_frag) {print $0}}' $WD/"$label"_chr_sizes.txt > $INFOS_TXT/largest_"$label"_frag_size.txt
        rm $WD/"$label"_chr_sizes.txt
done
