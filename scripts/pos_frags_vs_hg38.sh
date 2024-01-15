WD=/home/yuri/liri/puzzle/109_preliminar_oct23/109_10jan24 #sets the working directory
INFOS=$WD/infos
if [ ! -f $INFOS/hg38_chr_start_end.txt ]; then
    curl -s "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/chromInfo.txt.gz" | gunzip | grep -E 'chr([1-9]|1[0-9]|2[0-2])\b' | sort -V | awk '{print $1"\t"1"\t"$2}' > $INFOS/hg38_chr_start_end.txt
fi

declare -A chr_pos
while read -r chr start end; do
    chr_pos[$chr]="$start $end"
done < $INFOS/hg38_chr_start_end.txt

#Define an array of states
states=("rs_sp" "rs" "sp")

labels=("NAT" "EUR" "AFR" "UNK")

# Process each state and label
for state in "${states[@]}"; do
	STATE_DIR=$WD/$state

	for label in "${labels[@]}"; do
    		label_lower="${label,,}"
		ANC_DIR="$STATE_DIR/$label_lower"
    		output_file=$ANC_DIR/comp_"$state"_"$label_lower"_hg38.txt

        	if [ ! -s "$output_file" ]; then
            		echo -e "chr\tfirst_bp_gap\tlast_bp_gap\t1st_dist_start_hg38_2nd_dist_hg38_end" > "$output_file"
        	fi
    		for chr in {1..22}; do
    			CHRS_FILE=$ANC_DIR/chr_info_filt/"chr_${chr}_${label_lower}_${state}_filt.txt"
        		if [[ -s "$CHRS_FILE" ]]; then
                        	if [[ -v chr_pos["chr$chr"] ]]; then
					if ! awk -v chr="$chr" '$1 == chr {exit 1} END {exit 0}' "$CHRS_FILE"; then
                                		initial_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | awk '{print $1}')
                                		final_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | awk '{print $2}')
                                		initial_pos_chr=$(awk 'NR==1{print $3}' "$WD/$label_lower/chr_info_filt/chr_${chr}_${label_lower}_sort_filt_size_gap.txt")
                                		final_pos_chr=$(awk 'END{print $4}' "$WD/$label_lower/chr_info_filt/chr_${chr}_${label_lower}_sort_filt_size_gap.txt")
                                		dist_ini_chr_hg38=$(awk -v initial_pos_hg38=$initial_pos_hg38 -v initial_pos_chr=$initial_pos_chr 'BEGIN {print (initial_pos_chr - initial_pos_hg38)}')
                                		dist_final_hg38_chr=$(awk -v final_pos_hg38=$final_pos_hg38 -v final_pos_chr=$final_pos_chr 'BEGIN {print (final_pos_hg38 - final_pos_chr)}')
                                		echo -e "$chr\t$initial_pos_hg38\t$initial_pos_chr\t$dist_ini_chr_hg38\n$chr\t$final_pos_chr\t$final_pos_hg38\t$dist_final_hg38_chr" >> "$output_file" 
                        		fi
				fi
                	fi
        	done
	done
done
