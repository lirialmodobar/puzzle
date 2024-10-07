#!/bin/bash
WD=/mnt/genetica_1/liriel
COLLAPSE=$WD/output_collapse
INFOS=$WD/infos
CHRS_UNFILT="chr_info_unfilt"
CHRS_FILT="chr_info_filt"
#Check which file should be used as reference for start and end bp for gaps (filt or unfilt)
process_chr_file() {
    local label_lower="$1"
    local dir="$2"
    local chr="$3"
    local file_type="$4"

    CHR_FILE="$WD/${label_lower}/$dir/chr_${chr}_${label_lower}_sort_${file_type}_size_gap.txt"
    if [[ -s "$CHR_FILE" ]]; then
        awk '{ if ($6 == 1) {print $1,$2,$3,$4}}' "$CHR_FILE" >> "$WD/$label_lower/$dir/gap_${file_type}_frags_${label_lower}.txt"
    fi
}

## Define an array of labels
labels=("NAT" "EUR" "AFR" "UNK")

## Process each label and each chromosome (1 to 22) for both file types
for label in "${labels[@]}"; do
    ### Convert label to lowercase
    label_lower="${label,,}"

    ### Process both "filt" and "unfilt" files for each chromosome
    for chr in {1..2}; do
        process_chr_file "$label_lower" "$CHRS_FILT" "$chr" "filt"
        process_chr_file "$label_lower" "$CHRS_UNFILT" "$chr" "unfilt"
    done

##Compare the gap files
diff $WD/$label_lower/$CHRS_FILT/gap_filt_frags_"$label_lower".txt $WD/$label_lower/$CHRS_UNFILT/gap_unfilt_frags_"$label_lower".txt > $WD/$label_lower/diff_gap_filt_unfilt_"$label_lower".txt
done
