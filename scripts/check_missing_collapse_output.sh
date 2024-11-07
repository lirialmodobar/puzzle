COLLAPSE=/mnt/genetica_1/liriel/output_collapse
WD=/mnt/genetica_1/liriel/liri_dell/teste_dir/scripts
ls $COLLAPSE | sed s/_A.bed//g | sed s/_B.bed//g | sort | uniq > $WD/collapse_files.txt
sort /mnt/genetica_1/liriel/infos_txt/individuos.txt > $WD/all_inds.txt
grep -Fvf $WD/collapse_files.txt $WD/all_inds.txt > $WD/faltou.txt
 
