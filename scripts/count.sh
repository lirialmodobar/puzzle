#!/bin/bash

WD=/mnt/genetica_1/liriel/liri_dell/teste_dir
COLLAPSE=$WD/output_collapse
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
    while read -r _ chr initial_pos final_pos _ _ _; do
        # Search for matching positions in bim file
        vars=$(awk -v chr="$chr" -v ip="$initial_pos" -v fp="$final_pos" '$1 == chr && $4 > ip && $4 < fp { vals = (length(vals) > 0) ? vals "," $2 : $2 } END { print vals }' "$bim_file")
        # Write the result to the output file
        echo -e "$chr\t$initial_pos\t$final_pos\t$vars" >> "$output_file"
    done < "$pos_file"
}

# Define an array of labels
labels=("EUR" "NAT" "AFR" "UNK")

# Process each label and each chromosome (1 to 22) for both file types
for label in "${labels[@]}"; do

    ## Convert label to lowercase
    label_lower="${label,,}"

   ##Create necessary dirs for future steps
        if [ ! -d "$WD/${label_lower}/$CHRS_UNFILT/count_info" ]; then
        mkdir "$WD/${label_lower}/$CHRS_UNFILT/count_info"

        fi

    for chr in {1..2}; do
    ##Get number of vars per gap/chr/label

	###Generate file with gap infos per label
	awk -F'\t' '$6 == 1 {print prev; print} {prev=$0}' "$WD/${label_lower}/$CHRS_FILT/chr_${chr}_${label_lower}_sort_filt_size_gap.txt"  >> "$WD/$label_lower/$CHRS_FILT/info_gap_filt_frags_${label_lower}.txt"
	awk -F'\t' -v chr="$chr" '($2 == chr) && !found {start=$4; found=1; next} ($2 == chr) {end=$3; printf "%d\t%d\t%d\n", chr, start, end; start=$4}' "$WD/$label_lower/$CHRS_FILT/info_gap_filt_frags_${label_lower}.txt" >> "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt"
	awk -v chr="$chr" '{if ($1 == chr) {printf "%d\t%d\t%d\n", $1,$2,$3}}' $WD/$label_lower/$CHRS_FILT/filt_"$label_lower"_comp_hg38.txt >> "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt"

	###Get vars in gaps
	find_vars_within_pos_range "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt" "$WD/infos/BHRC_Probands_filt.bim" "$WD/$label_lower/$CHRS_FILT/gap_var_range_info_${label_lower}.txt"

	###Count vars in gaps
        awk -F'\t' -v OFS="\t" '{ n_vars = split($4, vars, ","); print $1, $2, $3, $4, n_vars }' "$WD/$label_lower/$CHRS_FILT/gap_var_range_info_${label_lower}.txt" > "$WD/$label_lower/$CHRS_FILT/n_vars_in_gap_${label_lower}.txt"

    ##Count the occurrences of each var in the entire output file and save the result
	echo "creating file with vars within range" > $WD/infos/log_count.txt
	find_vars_within_pos_range "$WD/$label_lower/$CHRS_UNFILT/chr_1_${label_lower}_sort_unfilt_size_gap.txt" "$WD/infos/BHRC_Probands_filt.bim" "$WD/$label_lower/$CHRS_UNFILT/chr_1_var_range_info_${label_lower}.txt"
        echo "getting vars to search in bim and count the occurences" >> $WD/infos/log_count.txt
	cut -f 4 "$WD/${label_lower}/$CHRS_UNFILT/chr_1_var_range_info_${label_lower}.txt" | sed 's/,/\n/g' | grep -v vars | sort -b | uniq > "$WD/var_info_entrada.txt"
	echo "counting occurrences" >> $WD/infos/log_count.txt
	while read var; do
        	count=$(grep -w "$var" "$WD/${label_lower}/chr_info_unfilt/chr_1_var_range_info_${label_lower}.txt" | wc -l)
		echo "counting" "$var" >> $WD/infos/log_count.txt
        	awk -v chr=1 -v var="$var" -v count="$count" -v OFS="\t" '{ if ($1 == chr && $2 == var) {print var, $1, $4, count}}' "$WD/infos/BHRC_Probands_filt.bim" >> "$WD/${label_lower}/$CHRS_UNFILT/count_info/count_pos_chr_1_${label_lower}.txt"
		echo "finished counting" "$var" >> $WD/infos/log_count.txt
	done < "$WD/var_info_entrada.txt"
	echo "finished counting all vars" $label_lower >> $WD/infos/log_count.txt
	rm "$WD/$label_lower/$CHRS_UNFILT/chr_1_var_range_info_${label_lower}.txt" 
	sort -k 1b,1 "$WD/${label_lower}/$CHRS_UNFILT/count_info/count_pos_chr_1_${label_lower}.txt" | uniq > "$WD/${label_lower}/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_${label_lower}.txt"
	rm "$WD/${label_lower}/$CHRS_UNFILT/count_info/count_pos_chr_1_${label_lower}.txt"
	rm "$WD/var_info_entrada.txt"
    done
done

##Total occurences per chr across all labels
echo "calculating total occurences" >> $INFOS/log_count.txt

join_and_sum_pairwise() {
    join -a 1 -a 2 -e 0 -o 1.1 1.2 1.3 2.1 2.2 2.3 1.4 2.4 "$1" "$2" > merge_temp
    sed -i 's/0 0 0 //1' merge_temp
    awk 'NF == 8 { print $4, $5, $6, ($7+$8) } NF == 5 { print $1, $2, $3, ($4+$5) }' merge_temp > "$3"
    rm merge_temp
}

for chr in {1..2}; do
	join_and_sum_pairwise "$WD/eur/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_eur.txt" "$WD/nat/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_nat.txt"  "$INFOS/sort_pos_count_chr_1_eur_nat.txt"
	join_and_sum_pairwise "$WD/afr/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_afr.txt" "$WD/unk/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_unk.txt"  "$INFOS/count_info/sort_pos_count_chr_1_afr_unk.txt"
	join_and_sum_pairwise "$INFOS/sort_pos_count_chr_1_eur_nat.txt" "$INFOS/sort_pos_count_chr_1_afr_unk.txt" "$INFOS/sort_pos_count_chr_1_all.txt"
	sort -k 3,3nb -o "$INFOS/sort_pos_count_chr_1_all.txt" "$INFOS/sort_pos_count_chr_1_all.txt"
	rm "$INFOS/sort_pos_count_chr_1_eur_nat.txt"
	rm "$INFOS/sort_pos_count_chr_1_afr_unk.txt"
done
echo "done" >> $INFOS/log_count.txt
