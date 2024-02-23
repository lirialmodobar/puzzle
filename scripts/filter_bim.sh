PLINK2=/usr/bin/plink2
WD=/home/yuri/liri/puzzle/109_preliminar_oct23
INFOS=$WD/infos_txt
COLLAPSE=$WD/output_collapse
ls "$COLLAPSE" | sed -e 's/_A.bed//g; s/_B.bed//g' | sort | uniq > "$INFOS/individuos.txt"
awk -v OFS="\t" '{print 0, $1}' $INFOS/individuos.txt > $WD/input_keep.txt
$PLINK2 --bfile $INFOS/BHRC_Probands --rm-dup force-first --make-bed --out $INFOS/BHRC_Probands_no_dup
$PLINK2 --bfile $INFOS/BHRC_Probands_no_dup --keep $WD/input_keep.txt --make-bed --out $INFOS/BHRC_Probands_filt
rm $WD/input_keep.txt
rm $INFOS/BHRC_Probands_no_dup*
