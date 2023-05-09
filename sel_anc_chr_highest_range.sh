INPUT_FILES=/home/santoro-lab/teste_dir/simulados
WD=/home/santoro-lab/teste_dir #sets the working directory
ls $INPUT_FILES  > $WD/collapse_results.txt
while read collapse; do
	FILE_NAME=$(echo $collapse | head -n 1)
	cut -f1-4 $INPUT_FILES/$collapse | cat | sed "s/^/$FILE_NAME\t/"  >> $WD/all_anc_all_chr.txt
done < $WD/collapse_results.txt
labels=("NAT" "EUR" "AFR" "UNK")
for label in "${labels[@]}"; do
	label_lower="${label,,}"
	if [ ! -d $WD/$label_lower ]; then
		 mkdir $WD/$label_lower
	fi
    	grep -w "$label" $WD/all_anc_all_chr.txt > $WD/$label_lower/"$label_lower"_all.txt
	for chr in {1..22}; do
		CHRS=$(awk -v chr=$chr '{ if ($2 == chr) {print}}' $WD/$label_lower/"$label_lower"_all.txt | sort -n -k 3,3 -k 4,4r | awk '!seen[$3]++')
		if [ -n "$CHRS" ]; then
        	echo "$CHRS" | awk '{print $1, $2, $3, $4, $4-$3, $5}' > $WD/$label_lower/chr_"${chr}"_"${label_lower}"_sort_filt_size.txt
    		fi
	done
done
rm $WD/collapse_results.txt
