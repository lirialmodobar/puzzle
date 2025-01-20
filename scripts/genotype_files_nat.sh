#!/bin/bash

# Definir os arquivos de entrada e saída
CHR="$1"
STATE="$2"
WD="/home/yuri/liri/puzzle_sdumont"
UNFILT_FILE="$WD/$STATE/nat/chr_info_unfilt/chr_${CHR}_nat_${STATE}_unfilt.txt"  # Substituir pelo caminho do arquivo real
HAPS_FILE="$WD/infos/haps_geno_header_${CHR}.txt"   # Substituir pelo caminho do arquivo .haps real
HAPS_DIR="$WD/$STATE/nat/chr_info_unfilt/haps_nat" #haps separado por chr
VCF_DIR="$WD/$STATE/nat/chr_info_unfilt/vcf_nat" #vcf todas amostras todos cromossomos
PLINK_FILES_DIR="$WD/$STATE/nat/chr_info_unfilt/vcf_nat/plink_files" #bed bim fam todas amostras todos cromossomos
SHAPEIT=/home/yuri/Downloads/shapeit.v2.904.3.10.0-693.11.6.el7.x86_64/bin/shapeit #v2
BCFTOOLS=/usr/bin/bcftools
PLINK=/usr/local/bin/plink #v1.9

# Criar diretório de saída se não existir
mkdir -p "$HAPS_DIR"
mkdir -p "$VCF_DIR"
mkdir -p "$PLINK_FILES_DIR"

#Funcoes

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


# Obter lista de IDs únicos sem duplicação de _A e _B
INDIVIDUALS=$(cut -f1 "$UNFILT_FILE" | sed 's/_.$//' | sort -u)

# Iterar sobre cada indivíduo
for ID in $INDIVIDUALS; do
    echo "Processando indivíduo: $ID"

    # Filtrar os fragmentos NAT do indivíduo (_A e _B)
    grep -E "^${ID}_[AB]" "$UNFILT_FILE" > "$WD/${ID}_${CHR}_${STATE}_fragments.txt"

    # Extrair as coordenadas dos fragmentos
   awk '{print $2, $3, $4}' "$WD/${ID}_${CHR}_${STATE}_fragments.txt" > "$WD/${ID}_${CHR}_${STATE}_coords.txt"

   rm "$WD/${ID}_${CHR}_${STATE}_fragments.txt"
    # Subsetar o arquivo .haps para os fragmentos do indivíduo
     while read -r chrom initial_pos final_pos; do
                        awk -v ip="$initial_pos" -v fp="$final_pos" '$3 >= ip && $3 <= fp {print $0}' "$HAPS_FILE" >> "$WD/${ID}_${CHR}_${STATE}_subset.haps"
     done < "$WD/${ID}_${CHR}_${STATE}_coords.txt"

   rm "$WD/${ID}_${CHR}_${STATE}_coords.txt"

   # Manter somente o individuo atual no haps
   col_number=$(head -n 1 "$HAPS_FILE" | tr '\t' '\n' | nl -v 6 | grep -i "$ID_A" | awk '{print $1}')
   awk -v col_num="$col_number" -v OFS="\t" '{print $1, $2, $3, $4, $5, $col_num, $(col_num+1)}' "$WD/${ID}_${CHR}_${STATE}_subset.haps" > "$WD/${ID}_${CHR}_${STATE}_subset_final.txt"
   rm "$WD/${ID}_${CHR}_${STATE}_subset.haps"

   #Voltar alelos de letras pra 0 e 1
   haps_alleles_to_0_1 "$WD/${ID}_${CHR}_${STATE}_subset_final.txt" "$HAPS_DIR/${ID}_${CHR}_${STATE}_haps_nat.haps"
   rm "$WD/${ID}_${CHR}_${STATE}_subset_final.txt"

   #Criar arquivos .sample e converter haps para vcf
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
  #  echo "Converting $haps_file to VCF format..."
   $SHAPEIT -convert --input-haps "$haps_prefix" --output-vcf "$output_vcf"
   rm "$HAPS_DIR/${ID}_${CHR}_${STATE}_haps_nat.hap"
   rm "$HAPS_DIR/${ID}_${CHR}_${STATE}_haps_nat.samples"
done

#Juntar todos os vcfs daquele cromossomo em um so
ulimit -n 10000 #aumentar limite de arquivos abertos de uma vez para poder fazer essa parte
    #Comprimir
    bgzip $VCF_DIR/*${CHR}_${STATE}_haps_nat.vcf

    #Indexar
    for VCF in $VCF_DIR/*${CHR}_${STATE}_haps_nat.vcf.gz; do $BCFTOOLS index "$VCF"; done

    #Juntar
if [ "$STATE" = "rs" ]; then
    $BCFTOOLS  merge -O z -o $VCF_DIR/all_C10_chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/C10*${CHR}_${STATE}_haps_nat.vcf.gz
    $BCFTOOLS  merge -O z -o $VCF_DIR/all_C11_chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/C11*${CHR}_${STATE}_haps_nat.vcf.gz
    $BCFTOOLS index $VCF_DIR/all_C10_chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS index $VCF_DIR/all_C11_chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS  merge -O z -o $VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/all_C*_chr_${CHR}_nat_${STATE}.vcf.gz
fi
if [ "$STATE" = "sp" ]; then
    $BCFTOOLS  merge -O z -o $VCF_DIR/all_C20_chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/C20*${CHR}_${STATE}_haps_nat.vcf.gz
    $BCFTOOLS  merge -O z -o $VCF_DIR/all_C21_chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/C21*${CHR}_${STATE}_haps_nat.vcf.gz
    $BCFTOOLS index $VCF_DIR/all_C20_chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS index $VCF_DIR/all_C21_chr_${CHR}_nat_${STATE}.vcf.gz
    $BCFTOOLS  merge -O z -o $VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz $VCF_DIR/all_C*_chr_${CHR}_nat_${STATE}.vcf.gz
fi

    rm $VCF_DIR/C*
    rm $VCF_DIR/all*

#Ter um haps com todas as amostras daquele cromossomo
    $BCFTOOLS convert --hapsample "$HAPS_DIR/chr_${CHR}_nat_${STATE}"  "$VCF_DIR/chr_${CHR}_nat_${STATE}.vcf.gz"

#Ter um vcf com todos os cromossomos e amostras, assim como bed bim fam (tem que ter rodado na ordem de cromossomos)
if [ "$CHR" -eq 22 ]; then
        # Merge all VCFs from chr1 to chr22 into one VCF
	for VCF in $VCF_DIR/chr_*_nat_${STATE}.vcf.gz; do $BCFTOOLS index "$VCF"; done
        #$BCFTOOLS merge -O z -o "$VCF_DIR/all_chr_nat_${STATE}.vcf.gz" $VCF_DIR/chr_*_nat_${STATE}.vcf.gz #same samples, but some files have fewer samples: no merge or concat
        # Remove individual chromosome VCF files
        #rm $VCF_DIR/chr_*_nat_${STATE}.vcf.gz
        #Ter um bed bim fam com todas as amostras daquele cromossomo
        #$PLINK  --vcf "$VCF_DIR/all_chr_nat_${STATE}.vcf.gz" --make-bed --out "$PLINK_FILES_DIR/chr_${CHR}_nat_${STATE}" #se um dia tiver o merge ou se precisar dos bed bim fam separados
fi
echo "fim"
