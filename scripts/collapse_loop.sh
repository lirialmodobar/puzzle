#!/bin/bash
WD=/scratch/unifesp/pgt/liriel.almodobar/puzzle
INPUT_DIR=$WD/bhrc_lai
#grep C $INPUT_DIR/*.sample > $WD/infos/individuos.txt 
while read p; do
        python3 $WD/scripts/collapse_ancestry.py \
        --rfmix $INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr2.2.Viterbi.txt \
        --snp_locations $INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr2.snp_locations \
        --fbk $INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr2.2.ForwardBackward.txt.gz \
        --fbk_threshold 0.9 \
        --ind "$p"  \
        --ind_info $INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI.sample \
        --pop_labels NAT,EUR,AFR \
        --out $WD/output_collapse/chr_2/"$p"
done < $WD/infos/individuos.txt
