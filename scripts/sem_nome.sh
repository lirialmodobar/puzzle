WD=/home/santoro/liri/puzzle

## Generate .haps with header

tail +3 $WD/bhrc_haps_sample/127_BHRC_altura_chr21.sample | awk '{ print $2}' | sed "p" |awk 'NR%2{suffix="_A"} !(NR%2){suffix="_B"} {print $0 suffix}' | tr '\n' '\t' > $WD/geno_columns.txt
paste $WD/5_columns.txt $WD/geno_columns.txt > $WD/header.txt
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
}' $WD/bhrc_haps_sample/127_BHRC_altura_chr21.haps > $WD/output_file.txt

cat $WD/header.txt $WD/output_file.txt | head > $WD/geno_header_127_BHRC_altura_chr21.haps

## Format output relative to each individual

# Define function to print allele for each ID
print_allele() {
    local id=$1
    local snp_id=$2
    local index_id=$3
    local row=$4
    local allele=$(echo "$row" | awk -v index_id=$index_id '{print $index_id}')
    echo "$id    $chr    $snp_id    $pos    $allele"
}

# Read the first line to get column indexes
header=$(head -n 1 $WD/geno_header_127_BHRC_altura_chr21.haps)

tail +2 $WD/geno_header_127_BHRC_altura_chr21.haps > $WD/temp.txt

# Split the header to get column indexes for IDs
IFS=$'\t' read -r -a ids <<< "$header"

# Read the remaining lines and process
while read -r line; do
    # Split the line
    IFS=$'\t' read -r -a fields <<< "$line"

    # Extract common fields
    chr="${fields[0]}"
    snp_id="${fields[1]}"
    pos="${fields[2]}"

    # Iterate over IDs
    for ((i = 5; i < ${#fields[@]}; i++)); do
        id="${ids[$i]}"
        print_allele "$id" "$snp_id" "$i" "$line" >> $WD/geno_info_BHRC_altura_chr21.txt
    done
done < $WD/temp.txt

rm $WD/temp.txt
