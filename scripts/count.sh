#!/bin/bash
WD=/home/yuri/liri/puzzle/109_preliminar_oct23/109_17jan24
COLLAPSE=/home/yuri/puzzle/109_preliminar_oct23/output_collapse
INFOS=$WD/infos
CHRS_UNFILT="chr_info_unfilt"
CHRS_FILT="chr_info_filt"


find_vars_within_pos_range() {
    local pos_file="$1"
    local bim_file="$2"
    local output_file="$3"
    # Create the header for the output file
    echo -e "chr\tinitial_pos\tfinal_pos\tvars" > "$output_file"

    # Process each line in pos file
    while read -r _ chrom initial_pos final_pos _ _ _; do
        # Search for matching positions in bim file
        vars=$(awk -v chrom="$chrom" -v ip="$initial_pos" -v fp="$final_pos" '$1 == chrom && $4 > ip && $4 < fp { vals = (length(vals) > 0) ? vals "," $2 : $2 } END { print vals }' "$bim_file")
        # Write the result to the output file
        echo -e "$chrom\t$initial_pos\t$final_pos\t$vars" >> "$output_file"
    done < "$pos_file"
}

#Define an array of states
states=("rs_sp" "rs" "sp")

# Define an array of labels
labels=("EUR" "NAT" "AFR" "UNK")


# Process each label and each chromosome (1 to 22) for both file types (filt and unfilt)
for state in "${states[@]}"; do
	STATE_DIR=$WD/$state
	for label in "${labels[@]}"; do
    		## Convert label to lowercase
    		label_lower="${label,,}"
		ANC_DIR=$STATE_DIR/$label_lower
   		##Create necessary dirs for future steps
        	if [ ! -d "$ANC_DIR/$CHRS_UNFILT/count_info" ]; then
        		mkdir "$ANC_DIR/$CHRS_UNFILT/count_info"
        	fi
    		#for chr in {1..22}; do
			chr=1
    			##See how many times a given var shows up since theres overlapping fragments
    			###See which vars are in each fragment
        		echo "creating file with vars within range" >> $INFOS/log_count.txt
        		find_vars_within_pos_range "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_${label_lower}_${state}_unfilt.txt" "$INFOS/BHRC_Probands_filt.bim" "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_vars_${label_lower}_${state}.txt"
    			###Getting vars to search in bim
			echo "getting vars to search in bim and then count the occurences" >> $INFOS/log_count.txt
			cut -f 4 "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_vars_${label_lower}_${state}.txt" | sed 's/,/\n/g' | grep -v vars | sort -b | uniq > "$WD/var_info_entrada.txt"
    			###Count occurences (meaning how many times the var shows up)
			echo "counting occurrences" >> $INFOS/log_count.txt
        		while read var; do
                		count=$(grep -w "$var" "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_vars_${label_lower}_${state}.txt" | wc -l)
                		echo "counting" "$var" >> $INFOS/log_count.txt
                		awk -v chr=$chr -v var="$var" -v count="$count" -v OFS="\t" '{ if ($1 == chr && $2 == var) {print var, $1, $4, count}}' "$INFOS/BHRC_Probands_filt.bim" >> "$ANC_DIR/$CHRS_UNFILT/count_info/count_chr_${chr}_${label_lower}_${state}.txt"
                		echo "finished counting" "$var" "for chr" "$chr" >> $INFOS/log_count.txt
        		done < "$WD/var_info_entrada.txt"
			rm "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_vars_${label_lower}_${state}.txt"
        		rm "$WD/var_info_entrada.txt"
    			##Get the amount of vars within the gaps
    				###Generate file with gap infos per label
        			#awk -F'\t' '$6 == 1 {print prev; print} {prev=$0}' "$ANC_DIR/$CHRS_FILT/chr_${chr}_${label_lower}_${state}_filt.txt"  >> "$ANC_DIR/$CHRS_FILT/temp_pos_gap_${label_lower}_${state}.txt"
        			#awk -F'\t' -v chr="$chr" '($2 == chr) && !found {start=$4; found=1; next} ($2 == chr) {end=$3; printf "%d\t%d\t%d\n", chr, start, end; start=$4}' "$ANC_DIR/$CHRS_FILT/temp_pos_gap_${label_lower}_${state}.txt" >> "$ANC_DIR/$CHRS_FILT/pos_gap_${label_lower}_${state}.txt"
        			#awk -v chr="$chr" '{if ($1 == chr) {printf "%d\t%d\t%d\n", $1,$2,$3}}' $ANC_DIR/$CHRS_FILT/comp_$state_"$label_lower"_hg38.txt >> "$ANC_DIR/$CHRS_FILT/pos_gap_${label_lower}_${state}.txt"
				#rm "$ANC_DIR/$CHRS_FILT/temp_pos_gap_${label_lower}_${state}.txt"
    		#done
		echo "finished counting all" "$label_lower" "vars" "for" "$state" >> $INFOS/log_count.txt
    				###See which vars are in the gaps
    				####obs - if graph, put in chr loop (check if graph is going to be necessary)
        			#find_vars_within_pos_range "$ANC_DIR/$CHRS_FILT/pos_gap_${label_lower}_${state}.txt" "$INFOS/BHRC_Probands_filt.bim" "$ANC_DIR/$CHRS_FILT/vars_gap_${label_lower}_${state}.txt"
				#rm "$ANC_DIR/$CHRS_FILT/pos_gap_${label_lower}_${state}.txt"
    				###Count vars in gap
        			#awk -F'\t' -v OFS="\t" '{ n_vars = split($4, vars, ","); print $1, $2, $3, $4, n_vars }' "$ANC_DIR/$CHRS_FILT/vars_gap_${label_lower}_${state}.txt" > "$ANC_DIR/$CHRS_FILT/n_vars_gap_$state_${label_lower}.txt"
				#rm "$ANC_DIR/$CHRS_FILT/vars_gap_${label_lower}_${state}.txt"
	done
	echo "finished counting all" "$state" "vars" >> $INFOS/log_count.txt
done

#Total occurences per chr across all labels
#echo "calculating total occurences" >> $INFOS/log_count.txt
#join_and_sum_pairwise() {
 #   join -a 1 -a 2 -e 0 -o 1.1 1.2 1.3 2.1 2.2 2.3 1.4 2.4 "$1" "$2" > merge_temp
  #  sed -i 's/0 0 0 //1' merge_temp
   # awk 'NF == 8 { print $4, $5, $6, ($7+$8) } NF == 5 { print $1, $2, $3, ($4+$5) }' merge_temp > "$3"
    #rm merge_temp
#}


#for chr in {1..22}; do
 #       join_and_sum_pairwise "$WD/eur/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_eur.txt" "$WD/nat/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_nat.txt"  "$INFOS/sort_pos_count_chr_1_eur_nat.txt"
  #      join_and_sum_pairwise "$WD/afr/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_afr.txt" "$WD/unk/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_unk.txt"  "$INFOS/count_info/sort_pos_count_chr_1_afr_unk.txt"
   #     join_and_sum_pairwise "$INFOS/sort_pos_count_chr_1_eur_nat.txt" "$INFOS/sort_pos_count_chr_1_afr_unk.txt" "$INFOS/sort_pos_count_chr_1_all.txt"
    #    sort -k 3,3nb -o "$INFOS/sort_pos_count_chr_1_all.txt" "$INFOS/sort_pos_count_chr_1_all.txt"
     #   rm "$INFOS/sort_pos_count_chr_1_eur_nat.txt"
      #  rm "$INFOS/sort_pos_count_chr_1_afr_unk.txt"
#done
#echo "done" >> $INFOS/log_count.txt
