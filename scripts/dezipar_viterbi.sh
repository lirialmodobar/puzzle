#!/bin/bash
cd /mnt/genetica_1/Rafaella/bhrc_lai
ls | grep "Viterbi.txt.gz" > viterbis.txt 
while read viterbi; do
	gzip -d $viterbi
done < viterbis.txt
