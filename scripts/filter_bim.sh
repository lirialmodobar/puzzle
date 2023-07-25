PLINK2=/usr/bin/plink2
WD=/mnt/genetica_1/liriel/infos_txt
COLLAPSE=/mnt/genetica_1/liriel/output_collapse
[ ! -f "$INFOS_TXT/individuos.txt" ] && ls "$COLLAPSE" | sed -e 's/_A.bed//g; s/_B.bed//g' | sort | uniq > "$INFOS_TXT/individuos.txt"
IND=$WD/individuos.txt
awk -v OFS="\t" '{print 0, $1}' $WD/individuos.txt > $WD/input_keep.txt
$PLINK2 --bfile $WD/BHRC_Probands --keep $WD/input_keep.txt --make-bed --out $WD/BHRC_Probands_filt
rm $WD/input_keep.txt
