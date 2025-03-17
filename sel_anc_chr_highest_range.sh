WD=./ #sets the working directory
INPUT_FILES=$WD/simulados
ls $INPUT_FILES > $WD/collapse_results.txt
if [ ! -d $WD/infos_txt ]; then
    mkdir $WD/infos_txt
fi
INFOS_TXT=$WD/infos_txt
while read collapse; do
    FILE_NAME=$(echo $collapse | head -n 1 | sed "s/.bed//g")
    cut -f1-4 $INPUT_FILES/$collapse | cat | sed "s/^/$FILE_NAME\t/" >> $INFOS_TXT/all_anc_all_chr.txt
done < $WD/collapse_results.txt
rm $WD/collapse_results.txt
if [ ! -f $INFOS_TXT/hg38_chr_start_end.txt ]; then
    curl -s "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/chromInfo.txt.gz" | gunzip | grep -E 'chr([1-9]|1[0-9]|2[0-2])\b' | sort -V | awk '{print $1"\t"1"\t"$2}' > $INFOS_TXT/hg38_chr_start_end.txt
fi
declare -A chr_pos
while read -r chr start end; do
    chr_pos[$chr]="$start $end"
done < $INFOS_TXT/hg38_chr_start_end.txt
labels=("NAT" "EUR" "AFR" "UNK")
for label in "${labels[@]}"; do
    label_lower="${label,,}"
    if [ ! -d $WD/$label_lower ]; then
        mkdir $WD/$label_lower
    fi
    grep -w "$label" $INFOS_TXT/all_anc_all_chr.txt > $WD/$label_lower/"$label_lower"_all.txt
    for chr in {1..22}; do
        CHRS=$(awk -v chr=$chr '{ if ($2 == chr) {print}}' $WD/$label_lower/"$label_lower"_all.txt | sort -n -k 3,3 -k 4,4r | awk '!seen[$3]++')
        if [ -n "$CHRS" ]; then
            echo "$CHRS" | awk 'NR==1 {a=$4; printf "%s\t%d\t%d\t%d\t%.2f\tNA\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, $5; next} {printf "%s\t%d\t%d\t%d\t%.2f\t%d\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, ($3 <= a) ? 0 : 1, $5; a=$4}' > $WD/$label_lower/chr_"${chr}"_"${label_lower}"_sort_filt_size_gap.txt
			Rscript $WD/chr_fragments_plot.R $WD/$label_lower/chr_"${chr}"_"${label_lower}"_sort_filt_size_gap.txt $WD/$label_lower/chr_"$chr"_"$label_lower"_plot_fragments
		    if [[ -v chr_pos["chr$chr"] ]]; then
                initial_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | awk '{print $1}')
                final_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | awk '{print $2}')
                initial_pos_chr=$(awk 'NR==1{print $3}' "$WD/$label_lower/chr_${chr}_${label_lower}_sort_filt_size_gap.txt")
                final_pos_chr=$(awk 'END{print $4}' "$WD/$label_lower/chr_${chr}_${label_lower}_sort_filt_size_gap.txt")
                dist_ini_chr_hg38=$(awk -v initial_pos_chr=$initial_pos_chr -v initial_pos_hg38=$initial_pos_hg38 'BEGIN { printf "%.2f", (initial_pos_chr - initial_pos_hg38) / 1000 }')
                dist_final_hg38_chr=$(awk -v final_pos_hg38=$final_pos_hg38 -v final_pos_chr=$final_pos_chr 'BEGIN { printf "%.2f", (final_pos_hg38 - final_pos_chr) / 1000 }')
                echo -e "chr$chr\t$dist_ini_chr_hg38\t$dist_final_hg38_chr" >> $WD/$label_lower/comp_"$label_lower"_hg38_chrs_start_end.txt
            fi
            if [ "$label" = "UNK" ]; then
                awk '{print $2,$3,$4,$5}' $WD/$label_lower/chr_"${chr}"_"${label_lower}"_sort_filt_size_gap.txt >> $WD/"$label_lower"_chr_sizes.txt
                sort -n -k4,4r $WD/"$label_lower"_chr_sizes.txt | awk 'NR==1 {print; biggest_size = $4; next} {if ($4 == biggest_size) {print $0}}' > $INFOS_TXT/biggest_"$label_lower"_fragment.txt
                rm $WD/"$label_lower"_chr_sizes.txt
            fi
        fi
    done
done