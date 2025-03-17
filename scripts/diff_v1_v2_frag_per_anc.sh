WD=/mnt/genetica_1/liriel/liri_dell/teste_dir
rm $WD/check.txt
labels=("NAT" "EUR" "AFR" "UNK" )
for label in "${labels[@]}"; do
	# Convert label to lowercase
    	label_lower="${label,,}"
	for chr in {1..22}; do
		diff $WD/teste/"$label_lower"/chr_info_unfilt/chr_"$chr"_"$label_lower"_sort_unfilt_size_gap.txt $WD/comp/"$label_lower"/chr_info_unfilt/chr_"$chr"_"$label_lower"_sort_unfilt_size_gap.txt >> $WD/check.txt
		diff $WD/teste/"$label_lower"/chr_info_filt/chr_"$chr"_"$label_lower"_sort_filt_size_gap.txt $WD/comp/"$label_lower"/chr_info_filt_largest_frag/chr_"$chr"_"$label_lower"_sort_filt_size_gap.txt >> $WD/check.txt
		echo "isso" >> $WD/check.txt
	done
done
