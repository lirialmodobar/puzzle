WD=/home/santoro/liri/puzzle
HAPS_SAMPLE_DIR=$WD/bhrc_haps_sample

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

### Subset haps for my sample

tail +3 INPD_hg38_1.sample | grep -n C | sed s#:0##g | sed 's#_[^ ]*##g' | awk '{ print $1, $2}' | sed "p" |awk 'NR%2{suffix="_A"} !(NR%2){suffix="_B"} {print $0 suffix}' | awk '{if (NR % 2 == 0) $1 = ($1 * 2) + 5 ; else $1 = ($1 * 2) - 1 + 5} 1' > $WD/haps_cols.txt
awk '{print $1}' $WD/haps_cols.txt > $WD/haps_indexes

#### Declare an empty array
indexes=()

# Read the file line by line and populate the array
while IFS= read -r line; do
    indexes+=("$line")
done < $WD/haps_indexes

awk -v OFS="\t"  -v indexes="${indexes[*]}" '{split(indexes, arr, " "); for (i in arr) printf "%s ", $arr[i]; print ""}' $haps_file > "$WD/haps_bhrc_children/bhrc_hg38_children_chr_${chr}.haps" 

rm $WD/haps_indexes

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
	local sample_file=$1
	local subset_haps_file=$2
	local header_allele_file=$3
	haps_header
	get_allele
	join_header_allele
}


### Format output relative to each individual

get_ids_cols_indexes(){
        ### Split the header to get column indexes for IDs
        header=$(head -n 1 $header_allele_file)
        IFS=$'\t' read -r -a ids <<< "$header"
}

get_relevant_fields(){
        #### Split the line
                IFS=$'\t' read -r -a fields <<< "$row"
        #### Extract common fields
                chr="${fields[0]}"
                snp_id="${fields[1]}"
                pos="${fields[2]}"
}


get_allele_for_id() {
        local index_id=$1
        allele=$(echo "$row" | awk -v index_id=$index_id '{print $index_id}')
}

join_infos(){
       echo "$id    $chr    $snp_id    $pos    $allele" >> $WD/infos/geno_info_chr_${chr}.txt
}

id_as_row(){
	local header_allele_file=$1
	get_ids_cols_indexes
	get_relevant_fields
        #### Iterate over IDs
        for ((i = 5; i < ${#fields[@]}; i++)); do
                id="${ids[$i]}"
                get_allele_for_id $i
		join_infos
        done
}

#Main script

# Subset haps for my sample

tail +3 INPD_hg38_1.sample | grep -n C | sed s#:0##g | sed 's#_[^ ]*##g' | awk '{ print $1, $2}' | sed "p" |awk 'NR%2{suffix="_A"} !(NR%2){suffix="_B"} {print $0 suffix}' | awk '{if (NR % 2 == 0) $1 = ($1 * 2) + 5 ; else $1 = ($1 * 2) - 1 + 5} 1' > $WD/haps_cols.txt
awk '{print $1}' $WD/haps_cols.txt > $WD/haps_indexes

## Declare an empty array
indexes=()

### Read the file line by line and populate the array

while IFS= read -r line; do
    indexes+=("$line")
done < $WD/haps_indexes

awk -v OFS="\t"  -v indexes="${indexes[*]}" '{split(indexes, arr, " "); for (i in arr) printf "%s ", $arr[i]; print ""}' "$WD/bhrc_haps_sample/127_BHRC_altura_chr${chr}.haps > "$WD/haps_bhrc_children/bhrc_hg38_children_chr_${chr}.haps"

rm $WD/haps_indexes

get_header_allele "$HAPS_SAMPLE_DIR/127_BHRC_altura_chr${chr}.sample" "$WD/haps_bhrc_children/bhrc_hg38_children_chr_${chr}.haps" $WD/haps_geno_header.txt

tail +2 $WD/haps_geno_header.txt > $WD/geno_headless.txt

while read -r row; do
	id_as_row $WD/haps_geno_header.txt
done < $WD/geno_headless.txt

#rm $WD/haps_geno_header.txt
rm $WD/geno_headless.txt

# ----------------------------------------------------------------------------------

#Obtaining allele frequency through processed haps file

#INPUT_FILE="$WD/$state/$anc/chr_info_unfilt/chr_${chr}_${anc}_${state}_unfilt.txt"
#INPUT_DIR="$WD/$state/$anc/chr_info_unfilt"

##Create necessary dirs for future steps
#if [ ! -d "$INPUT_DIR/count_info" ]; then
 #       mkdir "$INPUT_DIR/count_info"
#fi

#if [ ! -d "$INPUT_DIR/seq_info" ]; then
 #       mkdir "$INPUT_DIR/seq_info"
#fi


##Functions

###Find haps data in collapse intervals (merge collapse and haps)

#find_vars_within_pos_range() {
#	local pos_file="$1"
#	local var_file="$2"
#	local output_file="$3"

	#### Process each line in pos file
#	while read -r id chrom initial_pos final_pos _ _ _ _; do
		#### Search for matching positions in bim file
#		vars=$(awk -v OFS="\t" -v id="$id" -v ip="$initial_pos" -v fp="$final_pos" '$1 == id && $4 > ip && $4 < fp { vals = vals  $3 "," $4 "," $5 "\t" } END { print vals }' "$var_file")
#		if [ -n "$vars" ]; then #testing only
#			echo -e "$id\t$chrom\t$initial_pos\t$final_pos\t$vars" >> "$output_file"
#		fi
#	done < "$pos_file"
#}

###Obtain allele frequencies

#### Count occurrences of var_allele combinations

#count_var_allele(){
#	count=$(grep -w "$var_allele" "$cohaps" | wc -l)
#	echo -e "$var_allele\t$chr\t$count\t" | sed 's#,#\t#g' | awk -v OFS="\t" '{print $1, $4, $2, $3, $5}' >> "$WD/count_var_allele.txt"
#}

#### Get allele frequencies
#allele_freq(){
#	sum_var=$(grep "$var" "$WD/count_var_allele.txt" | awk '{ sum += $5 } END { print sum }')
#	awk -v OFS="\t" -v var=$var -v sum_var=$sum_var '{if ($1 == var) {print $1, $2, $3, $4, $5, sum_var, ($5/sum_var)*100}}' "$WD/count_var_allele.txt" >> "$INPUT_DIR/count_info/freqs_chr_${chr}_${anc}_${state}.txt"
#}

##Main script

#find_vars_within_pos_range $INPUT_FILE "$WD/infos/geno_info_chr_${chr}.txt" "$INPUT_DIR/seq_info/cohaps_chr_${chr}_${anc}_${state}.txt"

#cohaps="$INPUT_DIR/seq_info/cohaps_chr_${chr}_${anc}_${state}.txt"

### Getting variant_alleles combinations to search
#awk '{for(i=5;i<=NF;i++) print $i}' "$cohaps"  | sort -b | uniq > "$WD/varal_info_entrada.txt"

#while read var_allele; do
 #       count_var_allele "$var_allele"
#done < $WD/varal_info_entrada.txt

###Getting variants to search
#cut -f 1 "$WD/count_var_allele.txt" | sort -b | uniq  > $WD/temp_input.txt

#while read var; do
#	allele_freq $var
#done < $WD/temp_input.txt

#rm "$WD/infos/geno_info_chr_${chr}.txt"
#rm $WD/varal_info_entrada.txt
#rm $WD/count_var_allele.txt
#rm $WD/temp_input
