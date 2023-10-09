WD=/home/santoro-lab/liri/teste_dir #sets the working directory
INFOS_TXT=$WD/infos_txt
if [ ! -f $INFOS_TXT/hg38_chr_start_end.txt ]; then
    curl -s "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/chromInfo.txt.gz" | gunzip | grep -E 'chr([1-9]|1[0-9]|2[0-2])\b' | sort -V | awk '{print $1"\t"1"\t"$2}' > $INFOS_TXT/hg38_chr_start_end.txt
fi

declare -A chr_pos
while read -r chr start end; do
    chr_pos[$chr]="$start $end"
done < $INFOS_TXT/hg38_chr_start_end.txt

labels=("NAT" "EUR" "AFR" "UNK")
chr_dirs=("chr_info_unfilt" "chr_info_filt_largest_frag")
output_file_prefix=("unfilt" "filt")

for label in "${labels[@]}"; do
    label_lower="${label,,}"
    for ((i=0; i<${#chr_dirs[@]}; i++)); do
        chr_dir=${chr_dirs[$i]}
        output_prefix=${output_file_prefix[$i]}

        output_file="$WD/$label_lower/$chr_dir/${output_prefix}_${label_lower}_comp_hg38.txt"

        # Check if the output file is empty and add the header if needed
        if [ ! -s "$output_file" ]; then
            echo -e "chr\tfirst_bp_gap\tlast_bp_gap\t1st_dist_start_hg38_2nd_dist_hg38_end" > "$output_file"
        fi

        for chr in {1..22}; do
            if [[ "$chr_dir" == "chr_info_unfilt" ]]; then
                CHRS_FILE=$WD/$label_lower/$chr_dir/chr_"${chr}"_"${label_lower}"_sort_unfilt_size_gap.txt
            else
                CHRS_FILE=$WD/$label_lower/$chr_dir/chr_"${chr}"_"${label_lower}"_sort_filt_size_gap.txt
            fi

            if [[ -s "$CHRS_FILE" ]]; then
                if [[ -v chr_pos["chr$chr"] ]]; then
                    initial_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | awk '{print $1}')
                    final_pos_hg38=$(echo "${chr_pos["chr$chr"]}" | awk '{print $2}')
                    initial_pos_chr=$(awk 'NR==1{print $3}' "$CHRS_FILE")
                    final_pos_chr=$(awk 'END{print $4}' "$CHRS_FILE")
                    dist_ini_chr_hg38=$(awk -v initial_pos_chr=$initial_pos_chr -v initial_pos_hg38=$initial_pos_hg38 'BEGIN { printf "%.2f", (initial_pos_chr - initial_pos_hg38) / 1000 }')
                    dist_final_hg38_chr=$(awk -v final_pos_hg38=$final_pos_hg38 -v final_pos_chr=$final_pos_chr 'BEGIN { printf "%.2f", (final_pos_hg38 - final_pos_chr) / 1000 }')

                    echo -e "$chr\t$initial_pos_hg38\t$initial_pos_chr\t$dist_ini_chr_hg38\n$chr\t$final_pos_chr\t$final_pos_hg38\t$dist_final_hg38_chr" >> "$output_file"
                fi
            fi
        done
    done
done