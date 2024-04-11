WD=/scratch/unifesp/pgt/liriel.almodobar/puzzle
HAPS_SAMPLE_DIR=$WD/bhrc_haps_hg38

# Check if all three arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <state> <anc> <chr>"
    exit 1
fi

# Assigning arguments to variables
state=$1
anc=$2
chr=$3

#Functions

##Process .haps file

### Generate .haps with header

haps_header() {
	awk '{print $2}' $WD/haps_cols.txt | tr '\n' '\t' > $WD/geno_columns.txt
	paste $WD/infos/5_columns.txt $WD/geno_columns.txt > $WD/header.txt  #5_columns should go to info
	rm $WD/geno_columns.txt
	rm $WD/haps_cols.txt
}


### Replace 1 and 0 by the actual allele

get_allele() {
	awk '{
		fourth_col=$4
		fifth_col=$5
		modified_line=$1"\t"$2"\t"$3"\t"fourth_col"\t"fifth_col
		for (i=6; i<=NF; i++) {
			if ($i == 0) {
				modified_line = modified_line"\t"fourth_col
			} else if ($i == 1) {
				modified_line = modified_line"\t"fifth_col
			}
		}
		print modified_line
	}' $subset_haps_file > $WD/alleles.txt
}

join_header_allele(){
	cat $WD/header.txt $WD/alleles.txt | head -n 10  > $header_allele_file # n 10 just for testing
	rm $WD/alleles.txt
	rm $WD/header.txt
}

get_header_allele(){
	local subset_haps_file=$1
	local header_allele_file=$2
	haps_header
	get_allele
	join_header_allele
}


#Main script

# Subset haps for my sample

##Create necessary dirs for future steps

if [ ! -d "$WD/haps_bhrc_children" ]; then
        mkdir "$INPUT_DIR/haps_bhrc_children"
fi


#tail +3 "$WD/bhrc_haps_hg38/INPD_hg38_${chr}.sample" | grep -n C | sed s#:0##g | sed 's#_[^ ]*##g' | awk '{ print $1, $2}' | sed "p" |awk 'NR%2{suffix="_A"} !(NR%2){suffix="_B"} {print $0 suffix}' | awk '{if (NR % 2 == 0) $1 = ($1 * 2) + 5 ; else $1 = ($1 * 2) - 1 + 5} 1' > $WD/haps_cols.txt
#awk '{print $1}' $WD/haps_cols.txt > $WD/haps_indexes

## Declare an empty array
#indexes=()

### Read the file line by line and populate the array

#while IFS= read -r line; do
 #   indexes+=("$line")
#done < $WD/haps_indexes

#awk -v OFS="\t"  -v indexes="${indexes[*]}" '{split(indexes, arr, " "); for (i in arr) printf "%s ", $arr[i]; print ""}' "$WD/bhrc_haps_sample/127_BHRC_altura_chr${chr}.haps > $WD/ind_cols_haps
#awk '{print $1,$2,$3,$4,$5}' "$WD/bhrc_haps_hg38/INPD_hg38_${chr}.haps" > $WD/first_haps
#paste $WD/first_haps $WD/ind_cols_haps > "$WD/haps_bhrc_children/bhrc_hg38_children_chr_${chr}.haps"

#rm $WD/haps_indexes
#rm $WD/first_haps
#rm $WD/ind_cols_haps

get_header_allele "$WD/haps_bhrc_children/bhrc_hg38_children_chr_${chr}.haps" $WD/infos/haps_geno_header.txt

# ----------------------------------------------------------------------------------

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
                        vars=$(awk -v OFS="\t" -v index_id="$index_id" -v ip="$initial_pos" -v fp="$final_pos" -v id="$id" '$3 >= ip && $3 <= fp { print $2 "," $3 "
," $index_id }' "$var_file" | tr "\n" "\t")
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
	echo -e "$var_allele\t$chr\t$count\t" | sed 's#,#\t#g' | awk -v OFS="\t" '{print $1, $4, $2, $3, $5}' >> "$WD/count_var_allele.txt"
}

#### Get allele frequencies
allele_freq(){
	sum_var=$(grep "$var" "$WD/count_var_allele.txt" | awk '{ sum += $5 } END { print sum }')
	awk -v OFS="\t" -v var=$var -v sum_var=$sum_var '{if ($1 == var) {print $1, $2, $3, $4, $5, sum_var, ($5/sum_var)*100}}' "$WD/count_var_allele.txt" >> "$INPUT_DIR/count_info/freqs_chr_${chr}_${anc}_${state}.txt"
}

##Main script

find_vars_within_pos_range $INPUT_FILE "$WD/infos/haps_geno_header.txt" "$INPUT_DIR/seq_info/cohaps_chr_${chr}_${anc}_${state}.txt"

cohaps="$INPUT_DIR/seq_info/cohaps_chr_${chr}_${anc}_${state}.txt"

### Getting variant_alleles combinations to search
awk '{for(i=5;i<=NF;i++) print $i}' "$cohaps"  | sort -b | uniq > "$WD/varal_info_entrada.txt"

while read var_allele; do
        count_var_allele "$var_allele"
done < $WD/varal_info_entrada.txt

###Getting variants to search
cut -f 1 "$WD/count_var_allele.txt" | sort -b | uniq  > $WD/temp_input.txt

while read var; do
	allele_freq $var
done < $WD/temp_input.txt

#rm "$WD/infos/geno_info_chr_${chr}.txt"
#rm $WD/varal_info_entrada.txt
#rm $WD/count_var_allele.txt
#rm $WD/temp_input
