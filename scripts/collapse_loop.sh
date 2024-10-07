#!/bin/bash
<<<<<<< HEAD
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
=======
while read p; do
	python2 /mnt/c9589b8d-6052-48a3-8414-700ae0d33823/Rafaella/rafathon/ancestry_pipeline-master/collapse_ancestry.py \
	--rfmix /mnt/c9589b8d-6052-48a3-8414-700ae0d33823/Rafaella/bhrc_lai/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr1.2.Viterbi.txt \
	--snp_locations /mnt/c9589b8d-6052-48a3-8414-700ae0d33823/Rafaella/bhrc_lai/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr1.snp_locations \
	--fbk /mnt/c9589b8d-6052-48a3-8414-700ae0d33823/Rafaella/bhrc_lai/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI_chr1.2.ForwardBackward.txt.gz \
	--fbk_threshold 0.9 \
	--ind "$p"  \
	--ind_info /mnt/c9589b8d-6052-48a3-8414-700ae0d33823/Rafaella/bhrc_lai/BHRC_JOIN_RefHGDPNAT_1kgIBS_1kgYRI.sample \
	--pop_labels NAT,EUR,AFR \
	--out /mnt/c9589b8d-6052-48a3-8414-700ae0d33823/liriel/"$p"
done < /mnt/c9589b8d-6052-48a3-8414-700ae0d33823/Rafaella/bhrc_lai/amostras_inpd_para_collapse.txt
>>>>>>> d91d9f4 (old scripts)
