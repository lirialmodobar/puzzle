WD=/home/santoro-lab/liri/teste_dir #sets the working directory
INFOS_TXT=$WD/infos_txt
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
    output_file=$WD/$label_lower/comp_"$label_lower"_hg38_chrs_start_end.txt
	if [ ! -s "$output_file" ]; then
            echo -e "chr\tfirst_bp_gap\tlast_bp_gap\t1st_dist_start_hg38_2nd_dist_hg38_end" > "$output_file"	
	fi
    for chr in {1..22}; do
    CHRS_FILE=$WD/$label_lower/chr_info_filt/chr_"${chr}"_"${label_lower}"_sort_filt_size_gap.txt
        if [[ -s "$CHRS_FILE" ]]; then
			if [[ -v chr_pos["chr$chr"] ]]; then
				initial_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | awk '{print $1}')
				final_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | awk '{print $2}')
				initial_pos_chr=$(awk 'NR==1{print $3}' "$WD/$label_lower/chr_${chr}_${label_lower}_sort_filt_size_gap.txt")
				final_pos_chr=$(awk 'END{print $4}' "$WD/$label_lower/chr_${chr}_${label_lower}_sort_filt_size_gap.txt")
				dist_ini_chr_hg38=$(awk -v initial_pos_chr=$initial_pos_chr -v initial_pos_hg38=$initial_pos_hg38 'BEGIN {(initial_pos_chr - initial_pos_hg38)}')
				dist_final_hg38_chr=$(awk -v final_pos_hg38=$final_pos_hg38 -v final_pos_chr=$final_pos_chr 'BEGIN {(final_pos_hg38 - final_pos_chr)}')
				echo -e "$chr\t$initial_pos_hg38\t$initial_pos_chr\t$dist_ini_chr_hg38\n$chr\t$final_pos_chr\t$final_pos_hg38\t$dist_final_hg38_chr" >> "$output_file" 
			fi
		fi
	done
done
