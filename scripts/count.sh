#!/bin/bash
WD=/mnt/genetica_1/liriel/liri_dell/teste_dir
COLLAPSE=$WD/output_collapse
INFOS_TXT=$WD/infos_txt
CHRS_UNFILT="chr_info_unfilt"
CHRS_FILT="chr_info_filt_largest_frag"


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


# Process each label and each chromosome (1 to 22) for both file types (filt and unfilt)
for label in "${labels[@]}"; do
    ## Convert label to lowercase
    label_lower="${label,,}"
   ##Create necessary dirs for future steps
        if [ ! -d "$WD/${label_lower}/$CHRS_UNFILT/count_info" ]; then
        mkdir "$WD/${label_lower}/$CHRS_UNFILT/count_info"
        fi
    #for chr in {1..22}; do
    ##Get the amount of vars within the gaps 
    ###Generate file with gap infos per label
        awk -F'\t' '$6 == 1 {print prev; print} {prev=$0}' "$WD/${label_lower}/$CHRS_FILT/chr_${chr}_${label_lower}_sort_filt_size_gap.txt"  >> "$WD/$label_lower/$CHRS_FILT/info_gap_filt_frags_${label_lower}.txt"
        awk -F'\t' -v chr="$chr" '($2 == chr) && !found {start=$4; found=1; next} ($2 == chr) {end=$3; printf "%d\t%d\t%d\n", chr, start, end; start=$4}' "$WD/$label_lower/$CHRS_FILT/info_gap_filt_frags_${label_lower}.txt" >> "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt"
        awk -v chr="$chr" '{if ($1 == chr) {printf "%d\t%d\t%d\n", $1,$2,$3}}' $WD/$label_lower/$CHRS_FILT/filt_"$label_lower"_comp_hg38.txt >> "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt"
    ###See which vars are in the gap
    ####obs - if graph, put in chr loop (check if graph is going to be necessary)
        find_vars_within_pos_range "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt" "$WD/infos_txt/BHRC_Probands_filt.bim" "$WD/$label_lower/$CHRS_FILT/gap_var_range_info_${label_lower}.txt"
    ###Count vars in gap
        awk -F'\t' -v OFS="\t" '{ n_vars = split($4, vars, ","); print $1, $2, $3, $4, n_vars }' "$WD/$label_lower/$CHRS_FILT/gap_var_range_info_${label_lower}.txt" > "$WD/$label_lower/$CHRS_FILT/n_vars_in_gap_${label_lower}.txt"
    ##See how many times a given var shows up since theres overlapping fragments
    ###See which vars are in each fragment
        echo "creating file with vars within range" > $WD/infos_txt/log_count.txt
        find_vars_within_pos_range "$WD/$label_lower/$CHRS_UNFILT/chr_1_${label_lower}_sort_unfilt_size_gap.txt" "$WD/infos_txt/BHRC_Probands_filt.bim" "$WD/$label_lower/$CHRS_UNFILT/chr_1_var_range_info_${label_lower}.txt"
    ###Getting vars to search in bim  
	echo "getting vars to search in bim and then count the occurences" >> $WD/infos_txt/log_count.txt
        cut -f 4 "$WD/${label_lower}/$CHRS_UNFILT/chr_1_var_range_info_${label_lower}.txt" | sed 's/,/\n/g' | grep -v vars | sort -b | uniq > "$WD/var_info_entrada.txt"
    ###Count occurences (meaning how many times the var shows up)	
	echo "counting occurrences" >> $WD/infos_txt/log_count.txt
        while read var; do
                count=$(grep -w "$var" "$WD/${label_lower}/chr_info_unfilt/chr_1_var_range_info_${label_lower}.txt" | wc -l)
                echo "counting" "$var" >> $WD/infos_txt/log_count.txt
                awk -v chr=1 -v var="$var" -v count="$count" -v OFS="\t" '{ if ($1 == chr && $2 == var) {print var, $1, $4, count}}' "$WD/infos_txt/BHRC_Probands_filt.bim" >> "$WD/${label_lower}/$CHRS_UNFILT/count_info/count_pos_chr_1_${label_lower}.txt"
                echo "finished counting" "$var" "for chr" "$chr">> $WD/infos_txt/log_count.txt
        done < "$WD/var_info_entrada.txt"
        echo "finished counting all vars" $label_lower >> $WD/infos_txt/log_count.txt
        rm "$WD/var_info_entrada.txt"
    #done
done
#Total occurences per chr across all labels
echo "calculating total occurences" >> $WD/infos_txt/log_count.txt
join_and_sum_pairwise() {
    join -a 1 -a 2 -e 0 -o 1.1 1.2 1.3 2.1 2.2 2.3 1.4 2.4 "$1" "$2" > merge_temp
    sed -i 's/0 0 0 //1' merge_temp
    awk 'NF == 8 { print $4, $5, $6, ($7+$8) } NF == 5 { print $1, $2, $3, ($4+$5) }' merge_temp > "$3"
    rm merge_temp
}
##Total occurences per chr across all labels
echo "calculating total occurences" >> $WD/infos_txt/log_count.txt
join_and_sum_pairwise() {
    join -a 1 -a 2 -e 0 -o 1.1 1.2 1.3 2.1 2.2 2.3 1.4 2.4 "$1" "$2" > merge_temp
    sed -i 's/0 0 0 //1' merge_temp
    awk 'NF == 8 { print $4, $5, $6, ($7+$8) } NF == 5 { print $1, $2, $3, ($4+$5) }' merge_temp > "$3"
    rm merge_temp
}
#for chr in {1..22}; do
        join_and_sum_pairwise "$WD/eur/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_eur.txt" "$WD/nat/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_nat.txt"  "$INFOS_TXT/sort_pos_count_chr_1_eur_nat.txt"
        join_and_sum_pairwise "$WD/afr/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_afr.txt" "$WD/unk/$CHRS_UNFILT/count_info/sort_pos_count_chr_1_unk.txt"  "$INFOS_TXT/count_info/sort_pos_count_chr_1_afr_unk.txt"
        join_and_sum_pairwise "$INFOS_TXT/sort_pos_count_chr_1_eur_nat.txt" "$INFOS_TXT/sort_pos_count_chr_1_afr_unk.txt" "$INFOS_TXT/sort_pos_count_chr_1_all.txt"
        sort -k 3,3nb -o "$INFOS_TXT/sort_pos_count_chr_1_all.txt" "$INFOS_TXT/sort_pos_count_chr_1_all.txt"
        rm "$INFOS_TXT/sort_pos_count_chr_1_eur_nat.txt"
        rm "$INFOS_TXT/sort_pos_count_chr_1_afr_unk.txt"
#done
echo "done" >> $WD/infos_txt/log_count.txt
