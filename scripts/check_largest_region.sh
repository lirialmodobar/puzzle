WD=/scratch/unifesp/pgt/liriel.almodobar/puzzle #set working dir
INFOS=$WD/infos
anc="nat" #change this last one to the anc you wanna check
states=("rs" "sp")
for state in "${states[@]}"; do
	ANC_DIR=$WD/$state/$anc
	#for chr in {1..22}; do
		chr=1
		awk '{print $2,$3,$4,$5}' $ANC_DIR/chr_info_filt/chr_"${chr}"_"${anc}"_"${state}"_filt.txt >> $WD/"$anc"_chr_sizes.txt
        	sort -k4,4nb -o $WD/"$anc"_chr_sizes.txt $WD/"$anc"_chr_sizes.txt
		awk 'NR==1 {print; largest_frag = $4; next} {if ($4 == largest_frag) {print $0}}' $WD/"$anc"_chr_sizes.txt > $INFOS/smallest_"$anc"_"$state"_frag.txt
        	rm $WD/"$anc"_chr_sizes.txt
	#done
done
