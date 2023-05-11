INPUT_FILES=/home/santoro-lab/teste_dir/simulados
WD=/home/santoro-lab/teste_dir #sets the working directory
ls $INPUT_FILES  > $WD/collapse_results.txt
while read collapse; do
	FILE_NAME=$(echo $collapse | head -n 1 | sed "s/.bed//g")
	cut -f1-4 $INPUT_FILES/$collapse | cat | sed "s/^/$FILE_NAME\t/"  >> $WD/all_anc_all_chr.txt
done < $WD/collapse_results.txt
if [ ! -f $WD/hg38_chr_start_end.txt ]; then
  curl -s "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/chromInfo.txt.gz" | gunzip | grep -E 'chr([1-9]|1[0-9]|2[0-2])\b' | sort -V | awk '{print $1,1,$2}' > $WD/hg38_chr_start_end.txt
fi
declare -A chr_pos
while read -r chr start end; do
	chr_pos[$chr]="$start $end"
done < $WD/hg38_chr_start_end.txt
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
		if [[ -v chr_pos["chr$chr"] ]]; then
		initial_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | cut -f 1)
        	final_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | cut -f 2)
		positions_chr=$(awk '{print $3, $4}' $WD/$label_lower/chr_"${chr}"_"${label_lower}"_sort_filt_size.txt)
		initial_pos_chr=$(echo "$positions_chr" | awk 'NR==1{print $1}')
        	final_pos_chr=$(echo "$positions_chr" | awk 'END{print $2}')
        	dist_ini_chr_hg38=$(echo "($initial_pos_chr - $initial_pos_hg38)/1000" | bc)
        	dist_final_hg38_chr=$(echo "($final_pos_chr - $last_val)/1000" | bc)
		echo -e "chr$chr\t$dist_ini_chr_hg38\t$dist_final_hg38_chr" >> $WD/$label_lower/comp_hg38_chrs_start_end.txt
    		fi
        done
done
rm $WD/collapse_results.txt
#verificar: pos inicial e final de cada cromossomo (api e array? hg!), ai por anc o quao distante o inicio ta do inicio real e o do fim ta do fim real por anc
##e cobertura entre tds as ancs? tipo menor pos entre tds as ancs e maior pos entre tds as ancs (all_chr_all_anc) e ver quao dist ta, se inc unk vai ser chr td ue...
###mas se for sem unk, pode ser interessante ver o qto conseguimos cobrir de anc atribuida 
#verificar maior fragmento unknown (das outras anc tbm?)

