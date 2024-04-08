#!/bin/bash
chr=$1
WD=/mnt/genetica_1/liriel/puzzle
if [ ! -d "$WD/output_collapse/chr_${chr}" ]; then
       mkdir "$WD/chr_${chr}"
fi
INPUT_DIR=/mnt/genetica_1/Rafaella/bhrc_lai
grep C $INPUT_DIR/*.sample > /mnt/genetica_1/liriel/individuos.txt 
while read p; do
        python3 /mnt/genetica_1/Rafaella/rafathon/ancestry_pipeline-master/collapse_ancestry.py \
        --rfmix "$INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr${chr}.2.Viterbi.txt" \
        --snp_locations "$INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr${chr}.snp_locations" \
        --fbk "$INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr${chr}.2.ForwardBackward.txt.gz" \
        --fbk_threshold 0.9 \
        --ind "$p"  \
        --ind_info "$INPUT_DIR/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI.sample" \
        --pop_labels NAT,EUR,AFR \
        --out "/mnt/genetica_1/liriel/output_collapse/chr_${chr}/$p"
done < /mnt/genetica_1/liriel/individuos.txt
