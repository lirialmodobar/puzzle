WD=/home/yuri/liri/puzzle/dados_sp_script_antigo
comp=/home/yuri/liri/puzzle/dados_sp_script_antigo/teste
rm $WD/check.txt
states=("sp")
labels=("NAT" "EUR" "AFR" "UNK" )
for state in "${states[@]}"; do
	for label in "${labels[@]}"; do
		# Convert label to lowercase
    		label_lower="${label,,}"
		for chr in {1..2}; do
			cut -f 1,2,3,4,5,6,7 $comp/$state/$label_lower/chr_info_unfilt/chr_"$chr"_"$label_lower"_"$state"_unfilt.txt > $WD/temp_unfilt.txt
			cut -f 1,2,3,4,5,6,7 $comp/$state/$label_lower/chr_info_filt/chr_"$chr"_"$label_lower"_"$state"_filt.txt > $WD/temp_filt.txt
			diff $WD/temp_unfilt.txt $WD/"$label_lower"/chr_info_unfilt/chr_"$chr"_"$label_lower"_sort_unfilt_size_gap.txt >> $WD/check.txt
			diff $WD/temp_filt.txt $WD/"$label_lower"/chr_info_filt/chr_"$chr"_"$label_lower"_sort_filt_size_gap.txt >> $WD/check.txt
			#rm $WD/temp_unfilt.txt
			#rm $WD/temp_filt.txt
			echo "isso" >> $WD/check.txt
		done
	done
done
