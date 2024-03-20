WD=/home/santoro/liri/puzzle

#Process .haps file

## Generate .haps with header

tail +3 $WD/bhrc_haps_sample/127_BHRC_altura_chr1.sample | awk '{ print $2}' | sed "p" |awk 'NR%2{suffix="_A"} !(NR%2){suffix="_B"} {print $0 suffix}' | tr '\n' '\t' > $WD/geno_columns.txt
paste $WD/5_columns.txt $WD/geno_columns.txt > $WD/header.txt #5_columns should go to info
rm $WD/geno_columns.txt


## Replace 1 and 0 by the actual allele

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
}' $WD/bhrc_haps_sample/127_BHRC_altura_chr1.haps  > $WD/alleles.txt

cat $WD/header.txt $WD/alleles.txt | head -n 10 > $WD/haps_geno_header.txt # n 10 just for testing

rm $WD/alleles.txt

## Format output relative to each individual

### Define function to print allele for each ID
print_allele() {
	local id=$1
	local snp_id=$2
	local index_id=$3
	local row=$4
	local allele=$(echo "$row" | awk -v index_id=$index_id '{print $index_id}')
	echo "$id    $chr    $snp_id    $pos    $allele"
}

### Read the first line to get column indexes
header=$(head -n 1 $WD/haps_geno_header.txt)

### Split the header to get column indexes for IDs
IFS=$'\t' read -r -a ids <<< "$header"

### Read the remaining lines and process

tail +2 $WD/haps_geno_header.txt > $WD/geno_headless.txt

while read -r line; do
	#### Split the line
	IFS=$'\t' read -r -a fields <<< "$line"

	#### Extract common fields
	chr="${fields[0]}"
	snp_id="${fields[1]}"
	pos="${fields[2]}"

	#### Iterate over IDs
	for ((i = 5; i < ${#fields[@]}; i++)); do
		id="${ids[$i]}"
		print_allele "$id" "$snp_id" "$i" "$line" >> $WD/geno_info.txt
	done
done < $WD/geno_headless.txt

rm $WD/haps_geno_header.txt
rm $WD/geno_headless.txt

# Find haps data in collapse intervals (merge collapse and haps)

find_vars_within_pos_range() {
	local pos_file="$1"
	local var_file="$2"
	local output_file="$3"

	## Process each line in pos file
	while read -r id chrom initial_pos final_pos _ _ _ _; do
		### Search for matching positions in bim file
		vars=$(awk -v OFS="\t" -v id="$id" -v ip="$initial_pos" -v fp="$final_pos" '$1 == id && $4 > ip && $4 < fp { vals = vals  $3 "," $4 "," $5 "\t" } END { print vals }' "$var_file")
		if [ -n "$vars" ]; then #testing only
			echo -e "$id\t$chrom\t$initial_pos\t$final_pos\t$vars" >> "$output_file"
		fi
	done < "$pos_file"
}

find_vars_within_pos_range $WD/chr_1_eur_sp_unfilt.txt $WD/geno_info.txt $WD/coll_haps_chr_1.txt

rm $WD/geno_info.txt

#Obtain allele frequencies

chr=1

## Getting variants to search

awk '{for(i=5;i<=NF;i++) print $i}' $WD/coll_haps_chr_1.txt  | sort -b | uniq > "$WD/var_info_entrada.txt"

## Count occurrences of var_allele combinations

	while read -r var_allele; do
		count=$(grep -w "$var_allele" "$WD/coll_haps_chr_1.txt" | wc -l)
		echo -e "$var_allele\t$chr\t$count\t" | sed 's#,#\t#g' | awk -v OFS="\t" '{print $1, $4, $2, $3, $5}' >> "$WD/count_var_allele.txt"
	done < "$WD/var_info_entrada.txt"

## Get allele frequencies

cut -f 1 "$WD/count_var_allele.txt" | sort -b | uniq  > $WD/temp_entrada.txt
	while read var; do
		sum_var=$(grep "$var" "$WD/count_var_allele.txt" | awk '{ sum += $5 } END { print sum }')
		awk -v OFS="\t" -v var=$var -v sum_var=$sum_var '{if ($1 == var) {print $1, $2, $3, $4, $5, sum_var, ($5/sum_var)*100}}' "$WD/count_var_allele.txt" >> "$WD/allele_freqs_chr1.txt"
	done < $WD/temp_entrada.txt
rm $WD/temp_entrada.txt
rm $WD/count_var_allele.txt
