# Set the working directory
WD=/home/santoro-lab/liri/teste_dir

# Define the input files directory
INPUT_FILES=$WD/output_collapse

# List files in the input directory and save the results to a file
ls $INPUT_FILES > $WD/collapse_results.txt

# Create the 'infos_txt' directory if it doesn't exist
if [ ! -d $WD/infos_txt ]; then
    mkdir $WD/infos_txt
fi

# Set the 'infos_txt' directory path
INFOS_TXT=$WD/infos_txt

# Process each file listed in 'collapse_results.txt'
while read collapse; do
    # Extract the file name without the '.bed' extension
    FILE_NAME=$(echo $collapse | head -n 1 | sed "s/.bed//g")

    # Extract columns 1-4 from the file and append them to 'all_anc_all_chr.txt'
    [ ! -f $INFOS_TXT/all_anc_all_chr.txt ] && cut -f1-4 $INPUT_FILES/$collapse | sed "s/^/$FILE_NAME\t/" >> $INFOS_TXT/all_anc_all_chr.txt
done < $WD/collapse_results.txt

# Remove the temporary file 'collapse_results.txt'
rm $WD/collapse_results.txt

read -p "For fragments starting at the same position, select only the largest ones? (y/n): " answer

# Define an array of labels
labels=("NAT" "EUR" "AFR" "UNK")

# Process each label
for label in "${labels[@]}"; do
    # Convert label to lowercase
    label_lower="${label,,}"

    # Create a directory for the label if it doesn't exist
    if [ ! -d $WD/$label_lower ]; then
        mkdir $WD/$label_lower
    fi

ANC_DIR=$WD/$label_lower

# Filter lines with the label
[ ! -f $ANC_DIR/"$label_lower"_all.txt ] && grep -w "$label" $INFOS_TXT/all_anc_all_chr.txt > $ANC_DIR/"$label_lower"_all.txt

    # Process each chromosome (1 to 22)
    for chr in {1..22}; do
	# Filter lines by chromosome, sort them, remove duplicates, and perform additional processing
       	output_prefix="chr_${chr}_${label_lower}_sort"
        output_sufix="size_gap.txt"

	if [[ $answer == "y" ]]; then
    	CHRS=$(awk -v chr=$chr '{ if ($2 == chr) {print}}' $ANC_DIR/"$label_lower"_all.txt | sort -k3,3nb -k4,4nbr | awk '!seen[$3]++')
	output_dir=$ANC_DIR/"chr_info_filt_largest_frag"; [ ! -d "$output_dir" ] && mkdir "$output_dir"
	output=$output_dir/"$output_prefix"_filt_$output_sufix

	else
    	CHRS=$(awk -v chr=$chr '{ if ($2 == chr) {print}}' $ANC_DIR/"$label_lower"_all.txt | sort -k3,3nb -k4,4nbr)
	output_dir=$ANC_DIR/"chr_info_unfilt"; [ ! -d "$output_dir" ] && mkdir "$output_dir"
	output=$output_dir/"$output_prefix"_unfilt_$output_sufix
	fi


        # If there are matching lines, save the results to a file
        if [ -n "$CHRS" ]; then
		echo "$CHRS" | awk 'NR==1 {a=$4; printf "%s\t%d\t%d\t%d\t%.2f\tNA\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, $5; next} {printf "%s\t%d\t%d\t%d\t%.2f\t%d\t%s\n", $1, $2, $3, $4, ($4-$3)/1000, ($3 <= a) ? 0 : 1, $5; a=$4}' > $output
        fi
    done
done

# End of the script

