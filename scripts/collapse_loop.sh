#!/bin/bash
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
