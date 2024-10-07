#!/bin/bash
WD=/scratch/unifesp/pgt/liriel.almodobar/puzzle
INPUT_DIR=$WD/bhrc_lai
#grep C $INPUT_DIR/*.sample > $WD/infos/individuos.txt 
chr=$1
if [ ! -d "$WD/output_collapse/chr_${chr}" ]; then
       mkdir "$WD/output_collapse/chr_${chr}"
fi
while read p; do
        python3 $WD/scripts/collapse_ancestry.py \
        --rfmix "$INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr${chr}.2.Viterbi.txt" \
        --snp_locations "$INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr${chr}.snp_locations" \
        --fbk "$INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr${chr}.2.ForwardBackward.txt.gz" \
        --fbk_threshold 0.9 \
        --ind "$p"  \
        --ind_info "$INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI.sample" \
        --pop_labels NAT,EUR,AFR \
	--chr $chr \
	--out "$WD/output_collapse/chr_${chr}/$p"
done < $WD/infos/individuos.txt
