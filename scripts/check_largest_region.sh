WD=/home/liri/puzzle #set working dir
INFOS=$WD/infos
anc="unk" #change this last one to the anc you wanna check
states=("rs_sp", "rs", "sp")
for state in "${states[@]}"; do
	LABEL_DIR=$WD/$state/$anc #change this last one to the anc you wanna check
	for chr in {1..22}; do
		awk '{print $2,$3,$4,$5}' $LABEL_DIR/chr_info_filt/chr_"${chr}"_"${anc}"_"${state}"_filt.txt >> $WD/"$label"_chr_sizes.txt
        	sort -k4,4nbr -o $WD/"$label"_chr_sizes.txt $WD/"$label"_chr_sizes.txt
		awk 'NR==1 {print; largest_frag = $4; next} {if ($4 == largest_frag) {print $0}}' $WD/"$label"_chr_sizes.txt > $INFOS/largest_"$label"_"$state"_frag.txt
        	rm $WD/"$label"_chr_sizes.txt
	done
done
