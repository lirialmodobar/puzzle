#!/bin/bash

# Set the working directory
WD=/home/yuri/liri/puzzle/old_data/teste

# Define the input files directory
INPUT_FILES=/home/yuri/liri/puzzle/old_data/output_collapse

# Function to process a specific chromosome
process_chromosome() {
    local chr=$1
    local label=$2
    local ANC_DIR=$3

    awk -v chr="$chr" -v OFS="\t" '{ if ($2 == chr) {print}}' "${ANC_DIR}/${label}_${state}_all.txt" | sort -k3,3nb -k4,4nbr > "$WD/$chr_${label}_temp.txt"

    if [ -s "$WD/$chr_${label}_temp.txt" ]; then
        awk '!seen[$3]++' "$WD/$chr_${label}_temp.txt" | awk 'NR==1 {a=$4; printf "%s\t%d\t%d\t%d\t%.2f\tNA\t%s\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, $5, $6; next} {printf "%s\t%d\t%d\t%d\t%.2f\t%d\t%s\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, ($3 <= a) ? 0 : 1, $5, $6; a=$4}' > "$ANC_DIR/chr_info_filt/chr_${chr}_${label}_${state}_filt.txt"

        awk 'NR==1 {a=$4; printf "%s\t%d\t%d\t%d\t%.2f\tNA\t%s\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, $5, $6; next} {printf "%s\t%d\t%d\t%d\t%.2f\t%d\t%s\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, ($3 <= a) ? 0 : 1, $5, $6; a=$4}' "$WD/$chr_${label}_temp.txt" > "$ANC_DIR/chr_info_unfilt/chr_${chr}_${label}_${state}_unfilt.txt"
    fi
    rm "$WD/$chr_${label}_temp.txt"
}

# Function to process states and ancestries

process_states_ancs() {
	local state=$1
	local label_lower=$2

	if [ "$state" = "rs_sp" ]; then
		grep -w "$label" "$INFOS/all_anc_all_chr.txt" | awk '{if ($1 ~ /^C1*/) print $0 "\trs"; else print $0 "\tsp"}' > "$ANC_DIR/${label_lower}_${state}_all.txt"
	elif [ "$state" = "rs" ]; then
		awk '{if ($6 == "rs") print $0}' $WD/rs_sp/$label_lower/"$label_lower"_rs_sp_all.txt > $ANC_DIR/"$label_lower"_"$state"_all.txt
	else
		awk '{if ($6 == "sp") print $0}' $WD/rs_sp/$label_lower/"$label_lower"_rs_sp_all.txt > $ANC_DIR/"$label_lower"_"$state"_all.txt
	fi
}


# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --chr) chr_flag="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check if the 'infos' directory exists and create it if not
if [ ! -d "$WD/infos" ]; then
    mkdir "$WD/infos"
fi

# Set the 'infos' directory path
INFOS="$WD/infos"

# List files in the input directory and save the results to a file
ls "$INPUT_FILES" > "$WD/collapse_results.txt"

# Process each file listed in 'collapse_results.txt'
while read collapse; do
    FILE_NAME=$(echo "$collapse" | head -n 1 | sed "s/.bed//g")
    cut -f1-4 "$INPUT_FILES/$collapse" | sed "s/^/$FILE_NAME\t/" >> "$INFOS/all_anc_all_chr.txt"
done < "$WD/collapse_results.txt"

# Remove the temporary file 'collapse_results.txt'
rm "$WD/collapse_results.txt"

#Define an array of states
states=("rs_sp" "rs" "sp")

# Define an array of labels
labels=("NAT" "EUR" "AFR" "UNK")

# Process each state and label
for state in "${states[@]}"; do
	STATE_DIR=$WD/$state
	if [ ! -d "$STATE_DIR" ]; then
        	mkdir "$STATE_DIR"
    	fi

	for label in "${labels[@]}"; do
    		label_lower="${label,,}"
    		ANC_DIR="$STATE_DIR/$label_lower"

   	 	# Create a directory for the label if it doesn't exist
    		if [ ! -d "$ANC_DIR" ]; then
        		mkdir "$ANC_DIR"
    		fi

    		if [ ! -d "$ANC_DIR/chr_info_filt" ]; then
        		mkdir "$ANC_DIR/chr_info_filt"
    		fi

    		if [ ! -d "$ANC_DIR/chr_info_unfilt" ]; then
        		mkdir "$ANC_DIR/chr_info_unfilt"
    		fi

    		# Process states and ancs
		process_states_ancs "$state" "$label_lower"

    		# Process chromosomes based on the --chr flag
    		if [ -n "$chr_flag" ]; then
        		process_chromosome "$chr_flag" "$label_lower" "$ANC_DIR"
    		else
        	# Process each chromosome from 1 to 22
        		for chr in {1..22}; do
            			process_chromosome "$chr" "$label_lower" "$ANC_DIR"
        		done
		fi
	done
done
