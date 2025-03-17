#!/bin/bash

# Input, output, tools
CHR="$1"
STATE="$2"
WD="/home/yuri/liri/puzzle_sdumont"
UNFILT_FILE="$WD/$STATE/nat/chr_info_unfilt/chr_${CHR}_nat_${STATE}_unfilt.txt"  # Substituir pelo caminho do arquivo real
HAPS_FILE="$WD/infos/haps_geno_header_${CHR}.txt"   # Substituir pelo caminho do arquivo .haps real
HAPS_DIR="$WD/$STATE/nat/chr_info_unfilt/haps_nat" #haps separado por chr
HAPS_SIMPLIFIED_DIR=$HAPS_DIR/haps_simplified
VCF_DIR="$WD/$STATE/nat/chr_info_unfilt/vcf_nat" #vcf todas amostras todos cromossomos
PLINK_FILES_DIR="$WD/$STATE/nat/chr_info_unfilt/vcf_nat/plink_files" #bed bim fam todas amostras todos cromossomos
SHAPEIT=/home/yuri/Downloads/shapeit.v2.904.3.10.0-693.11.6.el7.x86_64/bin/shapeit #v2
BCFTOOLS=/usr/bin/bcftools
PLINK=/usr/local/bin/plink #v1.9

# Create output directories if they dont exist
mkdir -p "$HAPS_DIR"
mkdir -p "$VCF_DIR"
mkdir -p "$PLINK_FILES_DIR"
mkdir -p "$HAPS_SIMPLIFIED_DIR"

#Functions

haps_alleles_to_0_1() {
    local haps_alleles="$1"  # Input file
    local haps_0_1="$2"  # Output file
    # Use `awk` to process each row and reverse the modification
    awk '{
        fourth_col = $4
        fifth_col = $5
        reversed_line = $1 "\t" $2 "\t" $3 "\t" fourth_col "\t" fifth_col
        for (i = 6; i <= NF; i++) {
            if ($i == fourth_col) {
                reversed_line = reversed_line "\t0"
            } else if ($i == fifth_col) {
                reversed_line = reversed_line "\t1"
            } else {
                # If the value does not match fourth_col or fifth_col, keep it unchanged (optional)
                reversed_line = reversed_line "\t" $i
            }
        }
     print reversed_line
    }' "$haps_alleles" > "$haps_0_1"
}


# Unique IDs whithout _A e _B
INDIVIDUALS=$(cut -f1 "$UNFILT_FILE" | sed 's/_.$//' | sort -u)


for ID in $INDIVIDUALS; do
   echo "Processando indivíduo: $ID"

    # Filter for NAT fragments 
    grep -E "^${ID}_[AB]" "$UNFILT_FILE" > "$WD/${ID}_${CHR}_${STATE}_fragments.txt"

    # Extract coordinates
   awk '{print $2, $3, $4}' "$WD/${ID}_${CHR}_${STATE}_fragments.txt" > "$WD/${ID}_${CHR}_${STATE}_coords.txt"

   rm "$WD/${ID}_${CHR}_${STATE}_fragments.txt"
    # Subset haps file for the haplotypes of one individual
     while read -r chrom initial_pos final_pos; do
                        awk -v ip="$initial_pos" -v fp="$final_pos" '$3 >= ip && $3 <= fp {print $0}' "$HAPS_FILE" >> "$WD/${ID}_${CHR}_${STATE}_subset.haps"
     done < "$WD/${ID}_${CHR}_${STATE}_coords.txt"

   rm "$WD/${ID}_${CHR}_${STATE}_coords.txt"

   # Keep only current individual in haps file
   col_number=$(head -n 1 "$HAPS_FILE" | tr '\t' '\n' | nl -v 6 | grep -i "$ID_A" | awk '{print $1}')
   awk -v col_num="$col_number" -v OFS="\t" '{print $1, $2, $3, $4, $5, $col_num, $(col_num+1)}' "$WD/${ID}_${CHR}_${STATE}_subset.haps" > "$WD/${ID}_${CHR}_${STATE}_subset_final.txt"
   rm "$WD/${ID}_${CHR}_${STATE}_subset.haps"

   #Alleles in 0/1
   haps_alleles_to_0_1 "$WD/${ID}_${CHR}_${STATE}_subset_final.txt" "$HAPS_DIR/${ID}_${CHR}_${STATE}_haps_nat.haps"
   rm "$WD/${ID}_${CHR}_${STATE}_subset_final.txt"

   #Create .sample file and convert haps to vcf
   haps_prefix="${HAPS_DIR}/${ID}_${CHR}_${STATE}_haps_nat"
   haps_file="${haps_prefix}.haps"

    # Define the .sample file
    sample_file="${haps_prefix}.sample"

    # Create the .sample file
    echo "Creating .sample file for $haps_file"
    echo -e "ID_1\tID_2\tmissing" > "$sample_file"
    echo -e "0\t0\t0" >> "$sample_file"
    echo -e "${ID}\t${ID}\t0" >> "$sample_file"

    # Define the output VCF file
    output_vcf="${VCF_DIR}/${ID}_${CHR}_${STATE}_haps_nat.vcf"
    sort -k3,3n "${haps_file}" -o "${haps_file}"

    # Run ShapeIt conversion
    echo "Converting $haps_file to VCF format..."
    $SHAPEIT -convert --input-haps "$haps_prefix" --output-vcf "$output_vcf"
    rm "$HAPS_DIR/${ID}_${CHR}_${STATE}_haps_nat.hap"
    rm "$HAPS_DIR/${ID}_${CHR}_${STATE}_haps_nat.samples"
done

#All vcfs of a chromosome into one
ulimit -n 10000 #increase limit of open files
    #Compress
    bgzip $VCF_DIR/*${CHR}_${STATE}_haps_nat.vcf

    #Index
    for VCF in $VCF_DIR/*${CHR}_${STATE}_haps_nat.vcf.gz; do $BCFTOOLS index "$VCF"; done

    #Merge
if [ "$STATE" = "rs" ]; then
    $BCFTOOLS  merge -O z -o $VCF_DIR/all_C10_chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/C10*${CHR}_${STATE}_haps_nat.vcf.gz
    $BCFTOOLS  merge -O z -o $VCF_DIR/all_C11_chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/C11*${CHR}_${STATE}_haps_nat.vcf.gz
    $BCFTOOLS index $VCF_DIR/all_C10_chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS index $VCF_DIR/all_C11_chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS  merge -O z -o $VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/all_C*_chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS  index $VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS  norm -d all $VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz  -O z -o $VCF_DIR/dedup_chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS index $VCF_DIR/dedup_chr_${CHR}_nat_${STATE}.vcf.gz
fi
if [ "$STATE" = "sp" ]; then
   $BCFTOOLS  merge -O z -o $VCF_DIR/all_C20_chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/C20*${CHR}_${STATE}_haps_nat.vcf.gz
   $BCFTOOLS  merge -O z -o $VCF_DIR/all_C21_chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/C21*${CHR}_${STATE}_haps_nat.vcf.gz
   $BCFTOOLS index $VCF_DIR/all_C20_chr_${CHR}_nat_${STATE}.vcf.gz
   $BCFTOOLS index $VCF_DIR/all_C21_chr_${CHR}_nat_${STATE}.vcf.gz
   $BCFTOOLS  merge -O z -o $VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/all_C*_chr_${CHR}_nat_${STATE}.vcf.gz
   $BCFTOOLS  index $VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz
   $BCFTOOLS  norm -d all $VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz  -O z -o $VCF_DIR/dedup_chr_${CHR}_nat_${STATE}.vcf.gz
   $BCFTOOLS index $VCF_DIR/dedup_chr_${CHR}_nat_${STATE}.vcf.gz

fi

rm $VCF_DIR/C*
rm $VCF_DIR/all*
rm $VCF_DIR/chr*

#Haps with all the samples from the chromosome, already only segments from our desired ancestry
    $BCFTOOLS convert --hapsample "$HAPS_DIR/chr_${CHR}_nat_${STATE}"  "$VCF_DIR/dedup_chr_${CHR}_nat_${STATE}.vcf.gz"
#Get adapted haps to use as input for the pipeline
    samples_file="$HAPS_DIR/chr_${CHR}_nat_${STATE}.samples"
    out1_samples_file="$HAPS_SIMPLIFIED_DIR/chr_${CHR}_1_nat_${STATE}.samples"
    out2_samples_file="$HAPS_SIMPLIFIED_DIR/chr_${CHR}_2_nat_${STATE}.samples"
    out1_hap_file="$HAPS_SIMPLIFIED_DIR/chr_${CHR}_1_nat_${STATE}.hap"
    out2_hap_file="$HAPS_SIMPLIFIED_DIR/chr_${CHR}_2_nat_${STATE}.hap"
    zcat "$HAPS_DIR/chr_${CHR}_nat_${STATE}.hap.gz" | awk -v OFS="\t" '{$2=$4=$5=""; $0=$0; print}' | sed 's#?#.#g' > "$HAPS_SIMPLIFIED_DIR/temp_chr_${CHR}_nat_${STATE}.hap"

# Get the total number of lines, excluding the first two rows
total_lines=$(wc -l < "$samples_file")
remaining_lines=$((total_lines - 2))

# Calculate the midpoint, rounding up for the top half
midpoint=$(( (remaining_lines + 1) / 2 ))

# First two lines
head -n 2 "$samples_file" > "$out1_samples_file"
head -n 2 "$samples_file" > "$out2_samples_file"

# Split the remaining lines into top and bottom halves
tail -n +3 "$samples_file" | head -n "$midpoint" >> "$out1_samples_file"
tail -n +3 "$samples_file" | tail -n "$((remaining_lines - midpoint))" >> "$out2_samples_file"

# Subset haps for my new samples

# Define an associative array for sample files and their respective output files
declare -A sample_files
sample_files["$out1_samples_file"]="$out1_hap_file"
sample_files["$out2_samples_file"]="$out2_hap_file"

for sample_file in "${!sample_files[@]}"; do
    # Extract the output file for the current sample file
    output_file="${sample_files[$sample_file]}"

    # Extract file prefix for naming intermediate files
    file_prefix=$(basename "$sample_file" | sed 's/\.[^.]*$//')

    # Process the sample file
    tail -n +3 "$sample_file" | grep -n C | sed 's#:0##g' | sed 's#_[^ ]*##g' | awk '{print $1, $2}' | \
        sed 'p' | awk 'NR%2{suffix="_1"} !(NR%2){suffix="_2"} {print $0 suffix}' | \
        awk '{if (NR % 2 == 0) $1 = ($1 * 2) + 2 ; else $1 = ($1 * 2) - 1 + 2} 1'  > "$HAPS_SIMPLIFIED_DIR/haps_cols_${CHR}_nat_${STATE}.txt"

    # Generate haps_indexes file
    awk '{print $1}' "$HAPS_SIMPLIFIED_DIR/haps_cols_${CHR}_nat_${STATE}.txt" > "$HAPS_SIMPLIFIED_DIR/haps_indexes_${CHR}_nat_${STATE}"

    # Declare an empty array
    indexes=()

    # Read the file line by line and populate the array
    while IFS= read -r line; do
        indexes+=("$line")
   done < "$HAPS_SIMPLIFIED_DIR/haps_indexes_${CHR}_nat_${STATE}"

    # Process temp hap file using the indexes
    intermediate_file="$HAPS_SIMPLIFIED_DIR/temp_processed_hap_${file_prefix}"
    awk -v OFS="\t" -v indexes="${indexes[*]}" '{split(indexes, arr, " "); for (i in arr) printf "%s ", $arr[i]; print ""}' \
        "$HAPS_SIMPLIFIED_DIR/temp_chr_${CHR}_nat_${STATE}.hap" > "$HAPS_SIMPLIFIED_DIR/ind_cols_${file_prefix}"

    # Extract the first two columns
    awk '{print $1, $2}' "$HAPS_SIMPLIFIED_DIR/temp_chr_${CHR}_nat_${STATE}.hap" > "$HAPS_SIMPLIFIED_DIR/first_haps_${file_prefix}"

    # Generate column headers
    geno_columns_file="$HAPS_SIMPLIFIED_DIR/geno_columns_${CHR}_${STATE}.txt"
    awk '{print $2}' "$HAPS_SIMPLIFIED_DIR/haps_cols_${CHR}_nat_${STATE}.txt" | tr '\n' '\t' > "$geno_columns_file"
    header_file="$HAPS_SIMPLIFIED_DIR/header_${CHR}_${STATE}.txt"
    echo -e "Chr\tPos\t$(cat $geno_columns_file)" > "$header_file"

    # Combine header and intermediate file into final output
    paste "$HAPS_SIMPLIFIED_DIR/first_haps_${file_prefix}" "$HAPS_SIMPLIFIED_DIR/ind_cols_${file_prefix}" > "$intermediate_file"
    cat "$header_file" "$intermediate_file" > "$output_file"
    gzip "$output_file"

    # Clean up intermediate files
    rm "$HAPS_SIMPLIFIED_DIR/haps_indexes_${CHR}_nat_${STATE}"
    rm "$HAPS_SIMPLIFIED_DIR/ind_cols_${file_prefix}"
    rm "$HAPS_SIMPLIFIED_DIR/first_haps_${file_prefix}"
    rm "$geno_columns_file"
    rm "$header_file"
    rm "$intermediate_file"
done
rm "$HAPS_SIMPLIFIED_DIR/temp_chr_${CHR}_nat_${STATE}.hap"
echo "fim"
