PLINK2=/usr/bin/plink2
WD=/mnt/genetica_1/liriel/infos
COLLAPSE=/mnt/genetica_1/liriel/output_collapse
ls "$COLLAPSE" | sed -e 's/_A.bed//g; s/_B.bed//g' | sort | uniq > "$WD/individuos.txt"
awk -v OFS="\t" '{print 0, $1}' $WD/individuos.txt > $WD/input_keep.txt
$PLINK2 --bfile $WD/BHRC_Probands --rm-dup force-first --make-bed --out $WD/BHRC_Probands_no_dup
$PLINK2 --bfile $WD/BHRC_Probands_no_dup --keep $WD/input_keep.txt --make-bed --out $WD/BHRC_Probands_filt
rm $WD/input_keep.txt
rm $WD/BHRC_Probands_no_dup*
