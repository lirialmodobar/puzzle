WD=/mnt/genetica_1/liriel
#HAPS_SAMPLE_DIR=$WD/bhrc_haps_hg38

# Check if all three arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <state> <anc> <chr>"
    exit 1
fi

# Assigning arguments to variables
state=$1
anc=$2
chr=$3

#Obtaining allele frequency through processed haps file

INPUT_FILE="$WD/$state/$anc/chr_info_unfilt/chr_${chr}_${anc}_${state}_unfilt.txt"
INPUT_DIR="$WD/$state/$anc/chr_info_unfilt"

##Create necessary dirs for future steps
if [ ! -d "$INPUT_DIR/count_info" ]; then
        mkdir "$INPUT_DIR/count_info"
fi

if [ ! -d "$INPUT_DIR/seq_info" ]; then
        mkdir "$INPUT_DIR/seq_info"
fi


##Functions

###Find haps data in collapse intervals (merge collapse and haps)

find_vars_within_pos_range() {
        local pos_file="$1"
        local var_file="$2"
        local output_file="$3"
        while read -r id chrom initial_pos final_pos _ _ _ _; do
                #### Search for matching positions in bim file
                index_id=$(awk -v id="$id" '{ for (i=1; i<=NF; i++) if ($i == id) { print i; exit } }' "$var_file")
                if [ -n "$index_id" ]; then
                        vars=$(awk -v OFS="\t" -v index_id="$index_id" -v ip="$initial_pos" -v fp="$final_pos" -v id="$id" '$3 >= ip && $3 <= fp { print $2 "," $3 "," $index_id }' "$var_file" | tr "\n" "\t")
                        if [ -n "$vars" ]; then #testing only
                                echo -e "$id\t$chrom\t$initial_pos\t$final_pos\t$vars" >> "$output_file"
                        fi
                fi
        done < "$pos_file"
}


###Obtain allele frequencies

#### Count occurrences of var_allele combinations

count_var_allele(){
	count=$(grep -w "$var_allele" "$cohaps" | wc -l)
	echo -e "$var_allele\t$chr\t$count\t" | sed 's#,#\t#g' | awk -v OFS="\t" '{print $1, $4, $2, $3, $5}' >> "$WD/count_var_allele_${state}_${anc}_${chr}.txt"
}

#### Get allele frequencies
allele_freq(){
	sum_var=$(grep "$var" "$WD/count_var_allele_${state}_${anc}_${chr}.txt" | awk '{ sum += $5 } END { print sum }')
	awk -v OFS="\t" -v var=$var -v sum_var=$sum_var '{if ($1 == var) {print $1, $2, $3, $4, $5, sum_var, ($5/sum_var)*100}}' "$WD/count_var_allele_${state}_${anc}_${chr}.txt" >> "$INPUT_DIR/count_info/freqs_chr_${chr}_${anc}_${state}.txt"
}

##Main script

#find_vars_within_pos_range $INPUT_FILE "$WD/infos/haps_geno_header_${chr}.txt" "$INPUT_DIR/seq_info/cohaps_chr_${chr}_${anc}_${state}.txt"

cohaps="$INPUT_DIR/seq_info/cohaps_chr_${chr}_${anc}_${state}.txt"

### Getting variant_alleles combinations to search
awk '{for(i=5;i<=NF;i++) print $i}' "$cohaps"  | sort -b | uniq > "$WD/varal_info_entrada_${state}_${anc}_${chr}.txt"

while read var_allele; do
        count_var_allele "$var_allele"
done < "$WD/varal_info_entrada_${state}_${anc}_${chr}.txt"

###Getting variants to search
cut -f 1 "$WD/count_var_allele_${state}_${anc}_${chr}.txt" | sort -b | uniq  > "$WD/temp_input_${state}_${anc}_${chr}.txt"

while read var; do
	allele_freq $var
done < "$WD/temp_input_${state}_${anc}_${chr}.txt"

#rm "$WD/varal_info_entrada_${state}_${anc}_${chr}.txt"
#rm "$WD/count_var_allele_${state}_${anc}_${chr}.txt"
#rm "$WD/temp_input_${state}_${anc}_${chr}.txt"
