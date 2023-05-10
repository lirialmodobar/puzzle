INPUT_FILES=/home/santoro-lab/teste_dir/simulados
WD=/home/santoro-lab/teste_dir #sets the working directory
ls $INPUT_FILES  > $WD/collapse_results.txt
while read collapse; do
	FILE_NAME=$(echo $collapse | head -n 1 | sed "s/.bed//g")
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
        	echo "$CHRS" | awk 'NR==1 {a=$4; print $1, $2, $3, $4, ($4-$3)/1000, "NA", $5; next} {print $1, $2, $3, $4,($4-$3)/1000, ($3 <= a) ? 0 : 1, $5; a=$4}' > $WD/$label_lower/chr_"${chr}"_"${label_lower}"_sort_filt_size.txt
    		fi
	done
done
rm $WD/collapse_results.txt
#por chr: verificar se tem gap (checa se pos final da coluna x menor ou igual a pos inicial da outra, criar coluna gap e o valor do gap) - for chr 
#verificar: pos inicial e final de cada cromossomo (api e array? hg!), ai por anc o quao distante o inicio ta do inicio real e o do fim ta do fim real por anc
##e cobertura entre tds as ancs? tipo menor pos entre tds as ancs e maior pos entre tds as ancs (all_chr_all_anc) e ver quao dist ta, se inc unk vai ser chr td ue...
###mas se for sem unk, pode ser interessante ver o qto conseguimos cobrir de anc atribuida 
#verificar maior fragmento unknown (das outras anc tbm?)

