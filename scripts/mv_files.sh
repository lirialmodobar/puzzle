#!/bin/bash
WD=/mnt/genetica_1/liriel/output_collapse
#ls $WD | grep ".sh" > $WD/para_mover.txt 
while read file; do
	#if [ ! -d $WD/$DIR ]; then
         #        mkdir $WD/$DIR
        #fi
	mv /mnt/genetica_1/liriel/dados_sp_script_antigo/output_collapse/$file $WD
done < /mnt/genetica_1/liriel/sp.txt
