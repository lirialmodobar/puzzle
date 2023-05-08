INPUT_FILES=/home/santoro-lab/teste_dir/simulados
WD=/home/santoro-lab/teste_dir #sets the working directory
ls $INPUT_FILES  > $WD/collapse_results.txt
while read collapse; do
	cat $INPUT_FILES/$collapse >> $WD/all_anc_all_chr.txt
done < $WD/collapse_results.txt
labels=("NAT" "EUR" "AFR")
for label in "${labels[@]}"; do
	label_lower="${label,,}"
	if [ ! -d $WD/$label_lower ]; then
		 mkdir $WD/$label_lower
	fi
    	grep -w "$label" $WD/all_anc_all_chr.txt > $WD/$label_lower/"$label_lower"_all.txt
	for chr in {1..8}; do
		awk -v chr=$chr '{ if ($1 == chr) {print}}' $WD/$label_lower/"$label_lower"_all.txt | sort -n -k 2 > $WD/$label_lower/chr_"$chr"_"$label_lower"_sorted.txt
	done
done
