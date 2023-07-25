#!/bin/bash
WD=/home/santoro-lab/liri/teste_dir
COLLAPSE=$WD/output_collapse
INFOS_TXT=$WD/infos_txt
CHRS_UNFILT="chr_info_unfilt"
CHRS_FILT="chr_info_filt_largest_frag"
#[ ! -f "$INFOS_TXT/individuos.txt" ] && ls "$COLLAPSE" | sed -e 's/_A.bed//g; s/_B.bed//g' | sort | uniq > "$INFOS_TXT/individuos.txt"
find_vars_within_pos_range() {
    local pos_file="$1"
    local bim_file="$2"
    local output_file="$3"

    # Create the header for the output file
    echo -e "chr\tinitial_pos\tfinal_pos\tvars" > "$output_file"

    # Process each line in pos file
    while read -r chr initial_pos final_pos; do
        # Search for matching positions in bim file
        vars=$(awk -v chr="$chr" -v ip="$initial_pos" -v fp="$final_pos" '$1 == chr && $4 > ip && $4 < fp { vals = (length(vals) > 0) ? vals "," $2 : $2 } END { print vals }' "$bim_file")
        # Write the result to the output file
        echo -e "$chr\t$initial_pos\t$final_pos\t$vars" >> "$output_file"
    done < "$pos_file"
}

# Define an array of labels
labels=("NAT" "EUR" "AFR" "UNK")

# Process each label and each chromosome (1 to 22) for both file types
for label in "${labels[@]}"; do
    ## Convert label to lowercase
    label_lower="${label,,}"

    ##Generate file with gap infos per label
    #for chr in {1..22}; do
	#awk -F'\t' '$6 == 1 {print prev; print} {prev=$0}' "$WD/${label_lower}/$CHRS_FILT/chr_${chr}_${label_lower}_sort_filt_size_gap.txt"  >> "$WD/$label_lower/$CHRS_FILT/info_gap_filt_frags_${label_lower}.txt"
	#awk -F'\t' -v chr="$chr" '($2 == chr) && !found {start=$4; found=1; next} ($2 == chr) {end=$3; printf "%d\t%d\t%d\n", chr, start, end; start=$4}' "$WD/$label_lower/$CHRS_FILT/info_gap_filt_frags_${label_lower}.txt" >> "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt"
	#awk -v chr="$chr" '{if ($1 == chr) {printf "%d\t%d\t%d\n", $1,$2,$3}}' $WD/$label_lower/$CHRS_FILT/filt_"$label_lower"_comp_hg38.txt >> "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt"
    #done
find_vars_within_pos_range "$WD/$label_lower/$CHRS_FILT/ref_${label_lower}_start_end_gap.txt" "$WD/infos_txt/para_para_teste.bim" "$WD/$label_lower/$CHRS_FILT/var_range_info_${label_lower}.txt"
#Count vars in gap
awk -F'\t' '{ n_vars = split($4, vars, ","); print $1, $2, $3, $4, n_vars }' "$WD/$label_lower/$CHRS_FILT/var_range_info_${label_lower}.txt" > "$WD/$label_lower/$CHRS_FILT/n_vars_in_gap_${label_lower}.txt"
# Count the occurrences of each var in the entire output file and save the result
awk -F'\t' -v OFS="\t" '{split($4,variants,","); for(i=2;i<=length(variants);i++) count[variants[i]]++} END {for(var in count)print var,count[var]}' "$WD/${label_lower}/$CHRS_FILT/var_range_info_${label_lower}.txt" > "$WD/$label_lower/$CHRS_FILT/var_count_${label_lower}.txt"
done
