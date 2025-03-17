WD=/scratch/unifesp/pgt/liriel.almodobar/puzzle
HAPS_SAMPLE_DIR=$WD/bhrc_haps_hg38

# Assigning arguments to variables
chr=$1

#Functions

##Process .haps file

### Generate .haps with header

haps_header() {
	awk '{print $2}' $WD/haps_cols_${chr}.txt | tr '\n' '\t' > $WD/geno_columns_${chr}.txt
	paste $WD/infos/5_columns.txt $WD/geno_columns_${chr}.txt > $WD/header_${chr}.txt  #5_columns should go to info
	rm $WD/geno_columns_${chr}.txt
	rm $WD/haps_cols_${chr}.txt
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
	}' $subset_haps_file > $WD/alleles_${chr}.txt
}

join_header_allele(){
	cat $WD/header_${chr}.txt $WD/alleles_${chr}.txt  > $header_allele_file
	rm $WD/alleles_${chr}.txt
	rm $WD/header_${chr}.txt
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

tail -n +3 "$WD/bhrc_haps_hg38/INPD_hg38_${chr}.sample" | grep -n C | sed s#:0##g | sed 's#_[^ ]*##g' | awk '{ print $1, $2}' | sed "p" |awk 'NR%2{suffix="_A"} !(NR%2){suffix="_B"} {print $0 suffix}' | awk '{if (NR % 2 == 0) $1 = ($1 * 2) + 5 ; else $1 = ($1 * 2) - 1 + 5} 1' > $WD/haps_cols_${chr}.txt
awk '{print $1}' $WD/haps_cols_${chr}.txt > $WD/haps_indexes_${chr}

## Declare an empty array
indexes=()

### Read the file line by line and populate the array

while IFS= read -r line; do
    indexes+=("$line")
done < $WD/haps_indexes_${chr}

gunzip "$WD/bhrc_haps_hg38/INPD_hg38_${chr}.haps"
awk -v OFS="\t"  -v indexes="${indexes[*]}" '{split(indexes, arr, " "); for (i in arr) printf "%s ", $arr[i]; print ""}' "$WD/bhrc_haps_hg38/INPD_hg38_${chr}.haps" > $WD/ind_cols_haps_${chr}
awk '{print $1,$2,$3,$4,$5}' "$WD/bhrc_haps_hg38/INPD_hg38_${chr}.haps" > $WD/first_haps_${chr}
paste $WD/first_haps_${chr} $WD/ind_cols_haps_${chr} > "$WD/haps_bhrc_children/bhrc_hg38_children_chr_${chr}.haps"

rm $WD/haps_indexes_${chr}
rm $WD/first_haps_${chr}
rm $WD/ind_cols_haps_${chr}

get_header_allele "$WD/haps_bhrc_children/bhrc_hg38_children_chr_${chr}.haps" $WD/infos/haps_geno_header_${chr}.txt
