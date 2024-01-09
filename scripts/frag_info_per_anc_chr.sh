# Set the working directory
WD=/home/yuri/liri/puzzle

# Define the input files directory
INPUT_FILES=$WD/output_collapse

# List files in the input directory and save the results to a file
ls $INPUT_FILES > $WD/collapse_results.txt

# Create the 'infos' directory if it doesn't exist
if [ ! -d $WD/infos ]; then
    mkdir $WD/infos
fi

# Set the 'infos' directory path
INFOS=$WD/infos

# Process each file listed in 'collapse_results.txt'
while read collapse; do
    # Extract the file name (ID) without the '.bed' extension
    FILE_NAME=$(echo $collapse | head -n 1 | sed "s/.bed//g")

    # Extract columns 1-4 from the file and append them to 'all_anc_all_chr.txt'
    #[ ! -f $INFOS/all_anc_all_chr.txt ] && 
    cut -f1-4 $INPUT_FILES/$collapse | sed "s/^/$FILE_NAME\t/" >> $INFOS/all_anc_all_chr.txt
done < $WD/collapse_results.txt

# Remove the temporary file 'collapse_results.txt'
rm $WD/collapse_results.txt

# Define an array of labels
labels=("NAT" "EUR" "AFR" "UNK")

# Process each label
for label in "${labels[@]}"; do
        #Convert label to lowercase
        label_lower="${label,,}"

        #Create a directory for the label if it doesn't exist
        if [ ! -d $WD/$label_lower ]; then
                mkdir $WD/$label_lower
        fi
        ANC_DIR=$WD/$label_lower
        if [ ! -d $WD/$label_lower/chr_info_filt ]; then
                mkdir $WD/$label_lower/chr_info_filt
        fi
        if [ ! -d $WD/$label_lower/chr_info_unfilt ]; then
                mkdir $WD/$label_lower/chr_info_unfilt
        fi
	# Filter lines with the label (generates file with all the ids, chrs and frags start and ending positions for that label)
	#[ ! -f $ANC_DIR/"$label_lower"_all.txt ] && 
	grep -w "$label" $INFOS/all_anc_all_chr.txt > $ANC_DIR/"$label_lower"_all.txt
	# Process each chromosome (1 to 22)
        	chr=1
                awk -v chr="$chr" -v OFS="\t" '{ if ($2 == chr) {print}}' "${ANC_DIR}/${label_lower}_all.txt" | sort -k3,3nb -k4,4nbr > $WD/"$chr"_"$label_lower"_temp.txt
                # Calculate frag size and check for gaps, generating one file per chr within the label with all the info related to the frags
                if [ -f $WD/"$chr"_"$label_lower"_temp.txt ]; then
                        awk '!seen[$3]++' $WD/"$chr"_"$label_lower"_temp.txt | awk 'NR==1 {a=$4; printf "%s\t%d\t%d\t%d\t%.2f\tNA\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, $5; next} {printf "%s\t%d\t%d\t%d\t%.2f\t%d\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, ($3 <= a) ? 0 : 1, $5; a=$4}' > "$ANC_DIR/chr_info_filt/chr_${chr}_${label_lower}_sort_filt_size_gap.txt"
                        awk 'NR==1 {a=$4; printf "%s\t%d\t%d\t%d\t%.2f\tNA\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, $5; next} {printf "%s\t%d\t%d\t%d\t%.2f\t%d\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, ($3 <= a) ? 0 : 1, $5; a=$4}' $WD/"$chr"_"$label_lower"_temp.txt > "$ANC_DIR/chr_info_unfilt/chr_${chr}_${label_lower}_sort_unfilt_size_gap.txt"
                fi
		rm $WD/"$chr"_"$label_lower"_temp.txt
done
