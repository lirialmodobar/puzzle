#!/bin/bash
sed s/$/_B.bed/g /mnt/genetica_1/liriel/liri_dell/teste_dir/scripts/lote_7_individuos.txt > /mnt/genetica_1/liriel/entrada.txt
while read rm; do
	rm /mnt/genetica_1/liriel/output_collapse/$rm
done < /mnt/genetica_1/liriel/entrada.txt
rm /mnt/genetica_1/liriel/entrada.txt
