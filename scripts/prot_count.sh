#!/bin/bash

# Define directories and variables
WD="/home/yuri/liri/puzzle/109_preliminar_oct23/109_17jan24"
COLLAPSE="/home/yuri/puzzle/109_preliminar_oct23/output_collapse"
INFOS="$WD/infos"
CHRS_UNFILT="chr_info_unfilt"
CHRS_FILT="chr_info_filt"
LOG_FILE="$INFOS/log_count.txt"

# Function to find variables within a position range
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


# Function to process label and chromosome for a given state
process_label_and_chromosome_for_state() {
    local state="$1"
    local label="$2"
    local chr="$3"
    local ANC_DIR="$WD/$state/$label"
    local chr_info_unfilt_file="$ANC_DIR/$CHRS_UNFILT/chr_${chr}_${label}_${state}_unfilt.txt"

    # Check if the chromosome file exists
    if [ ! -f "$chr_info_unfilt_file" ]; then
        echo "Error: File $chr_info_unfilt_file not found." >> "$LOG_FILE"
        return 1
    fi

    # Create necessary directories for future steps
    if [ ! -d "$ANC_DIR/$CHRS_UNFILT/count_info" ]; then
        mkdir -p "$ANC_DIR/$CHRS_UNFILT/count_info"
    fi

    # Find variables within the specified range
    echo "Processing state: $state, label: $label, chromosome: $chr, creating file with var info" >> "$LOG_FILE"
    find_vars_within_pos_range "$chr_info_unfilt_file" "$INFOS/BHRC_Probands_filt.bim" "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_vars_${label}_${state}.txt"

    # Getting variables to search in bim
    echo "getting vars to search in bim and then count the occurences" >> "$LOG_FILE"
    cut -f 4 "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_vars_${label}_${state}.txt" | sed 's/,/\n/g' | grep -v vars | sort -b | uniq > "$WD/var_info_entrada.txt"

    # Count occurrences of variables
    echo "counting occurrences" >> "$LOG_FILE"
    while read -r var; do
        count=$(grep -w "$var" "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_vars_${label}_${state}.txt" | wc -l)
        echo "Counting occurrences of $var for chromosome $chr, $state, $label" >> "$LOG_FILE"
        awk -v chr="$chr" -v var="$var" -v count="$count" -v OFS="\t" '{ if ($1 == chr && $2 == var) {print var, $1, $4, count}}' "$INFOS/BHRC_Probands_filt.bim" >> "$ANC_DIR/$CHRS_UNFILT/count_info/count_chr_${chr}_${label}_${state}.txt"
        echo "Finished counting occurrences of $var for chromosome $chr, $state, $label" >> "$LOG_FILE"
    done < "$WD/var_info_entrada.txt"

    rm "$ANC_DIR/$CHRS_UNFILT/chr_${chr}_vars_${label}_${state}.txt"
    rm "$WD/var_info_entrada.txt"
}

# Function to process all labels for a given state and chromosome
process_all_labels_for_state_and_chromosome() {
    local state="$1"
    local chr="$2"

    for label in "${labels[@]}"; do
        process_label_and_chromosome_for_state "$state" "$label" "$chr"
    done
}

# Function to generate gap information per label
generate_gap_info_per_label() {
    local state="$1"
    local chr="$2"
    local label="$3"

    local ANC_DIR="$WD/$state/$label"

    # Generate file with gap infos per label
    awk -F'\t' '$6 == 1 {print prev; print} {prev=$0}' "$ANC_DIR/$CHRS_FILT/chr_${chr}_${label}_${state}_filt.txt"  >> "$ANC_DIR/$CHRS_FILT/temp_pos_gap_${label}_${state}.txt"
    awk -F'\t' -v chr="$chr" '($2 == chr) && !found {start=$4; found=1; next} ($2 == chr) {end=$3; printf "%d\t%d\t%d\n", chr, start, end; start=$4}' "$ANC_DIR/$CHRS_FILT/temp_pos_gap_${label}_${state}.txt" >> "$ANC_DIR/$CHRS_FILT/pos_gap_${label}_${state}.txt"
    awk -v chr="$chr" '{if ($1 == chr) {printf "%d\t%d\t%d\n", $1,$2,$3}}' "$ANC_DIR/$CHRS_FILT/comp_$state_${label}_hg38.txt" >> "$ANC_DIR/$CHRS_FILT/pos_gap_${label}_${state}.txt"
    rm "$ANC_DIR/$CHRS_FILT/temp_pos_gap_${label}_${state}.txt"
}

join_rec() {
    f1=$1
    f2=$2
    shift 2
    if [ $# -gt 0 ]; then
        join -a 1 -a 2 -e 0 "$f1" "$f2" | join_rec /dev/stdin "$@"
    else
        join -a 1 -a 2 -e 0 "$f1" "$f2"
    fi
}

sum_scores() {
    awk -v OFS='\t' '
        {
            variant = $1;
            chromosome = $2;
            position = $3;

            # Extract scores from columns following the first 3
            num_scores = int((NF-3) / 3);  # Calculate the number of scores

            # Iterate through scores
            for (i = 0; i <= num_scores; i++) {
                score_field = i * 3 + 4;  # Starting position for scores
                score = $(score_field);  # Assuming the score is spaced every 4 fields
                sum[variant] += score;
                positions[variant] = position;
            }
        }
        END {
            for (variant in sum) {
                print variant, chromosome, positions[variant], sum[variant];
            }
        }
    '
}
# Main script starts here

# Define an array of states
states=( "rs" "sp")

# Define an array of labels
labels=("eur" "nat" "afr" "unk")

# Check if log file exists, if not create it
touch "$LOG_FILE"

# Parse command-line arguments
if [ "$#" -eq 3 ]; then
    state="$1"
    label="$2"
    chr="$3"
    process_label_and_chromosome_for_state "$state" "$label" "$chr"
elif [ "$#" -eq 2 ]; then
    state="$1"
    chr="$2"
    process_all_labels_for_state_and_chromosome "$state" "$chr"
elif [ "$#" -eq 1 ]; then
	if [ "$1" = "chr" ]; then
        	chr="$2"
        	for state in "${states[@]}"; do
            		for label in "${labels[@]}"; do
                	generate_gap_info_per_label "$state" "$chr" "$label"
            		done
        	done
	else
    		state="$1"
    		for chr in {1..22}; do
        		process_all_labels_for_state_and_chromosome "$state" "$chr"
    		done
	fi
else
    for state in "${states[@]}"; do
        for chr in {1..22}; do
		for label in "${labels[@]}"
                	process_label_and_chromosome_for_state "$state" "$label" "$chr"
			generate_gap_info_per_label "$state" "$label" "$chr"
            	done
        done
    done
fi


#Total occurences per chr across all labels
echo "calculating total occurences" >> "$LOG_FILE"

#for chr in {1..22}; do
        chr=1
        # Arrays for rs_sp, rs, and sp arguments
        rs_sp_args=()
        rs_args=()
        sp_args=()

        for region in nat eur afr unk; do
                # Construct arguments for rs_sp
                rs_sp_args+=("$WD/rs_sp/$region/chr_info_unfilt/count_info/count_chr_${chr}_${region}_rs_sp.txt")

                # Construct arguments for rs
                rs_args+=("$WD/rs/$region/chr_info_unfilt/count_info/count_chr_${chr}_${region}_rs.txt")

                # Construct arguments for sp
        sp_args+=("$WD/sp/$region/chr_info_unfilt/count_info/count_chr_${chr}_${region}_sp.txt")
        done

        # Call join_rec with all arguments
        join_rec "${rs_sp_args[@]}" > "$WD/infos/count_chr_${chr}_rs_sp.txt"
        join_rec "${rs_args[@]}" > "$WD/infos/count_chr_${chr}_rs.txt"
        join_rec "${sp_args[@]}" > "$WD/infos/count_chr_${chr}_sp.txt"

        #join_rec $WD/rs_sp/nat/chr_info_unfilt/count_info/count_chr_"$chr"_nat_rs_sp.txt $WD/rs_sp/eur/chr_info_unfilt/count_info/count_chr_"$chr"_eur_rs_sp.txt $WD/rs_sp/afr/chr_info_unfilt/count_info/count_chr_"$chr"_afr_rs_sp.txt $WD/rs_sp/unk/chr_info_unfilt/count_info/count_chr_"$chr"_unk_rs_sp.txt > $WD/infos/count_chr_"$chr"_rs_sp.txt
        #join_rec $WD/rs/nat/chr_info_unfilt/count_info/count_chr_"$chr"_nat_rs.txt $WD/rs/eur/chr_info_unfilt/count_info/count_chr_"$chr"_eur_rs.txt $WD/rs/afr/chr_info_unfilt/count_info/count_chr_"$chr"_afr_rs.txt $WD/rs/unk/chr_info_unfilt/count_info/count_chr_"$chr"_unk_rs.txt > $WD/infos/count_chr_"$chr"_rs.txt
        #join_rec $WD/sp/nat/chr_info_unfilt/count_info/count_chr_"$chr"_nat_sp.txt $WD/sp/eur/chr_info_unfilt/count_info/count_chr_"$chr"_eur_sp.txt $WD/sp/afr/chr_info_unfilt/count_info/count_chr_"$chr"_afr_sp.txt $WD/sp/unk/chr_info_unfilt/count_info/count_chr_"$chr"_unk_sp.txt > $WD/infos/count_chr_"$chr"_sp.txt
#done
echo "done" >> "$LOG_FILE"
