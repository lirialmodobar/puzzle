\# This pipeline performs local ancestry inference for target populations using ChromoPainterV2. 
# It processes genomic data, infers local ancestry, and assembles ancestral haplotypes. 
# 
# Author: Xiaoxi Zhang
# Purpose: To process genomic data for local ancestry inference and assemble ancestry-specific haplotypes.
# To help users run the pipeline more efficiently, we have removed the data preprocessing section and the subsequent analysis for generating samples. If users require these steps, please refer to our paper.
# 
# Pipeline Steps:
# 1. Local ancestry inference for the target populations.
# 2. Determine which ancestries the recipient haplotypes copies from at each allele.
# 3. Data transpose and adding physical location information.
# 4. Extract the specified ancestral alleles from the selected samples.
# 5. Assemble ancestral haplotypes using extracted ancestral gene pools.
# 6. Generate ancestral individuals using assembled ancestral haplotypes.
# 7. Synthesize individual files into group files and remove missing variants.
# 
# Input:
# - VCF files, genetic maps, and population-specific configuration files.
# 
# Output:
# - Local ancestry results, integrated ancestral haplotypes, and assembled VCF files.


#This pipeline was modified by Liriel Almodobar to only contain steps 5, 6 and 7, in a loop for all chromosomes, removing intermediate files,automatizing cutoff_length attribution, absolute paths only.
#"New" purpose: Construct non-admixed genomes from a given ancestry based on the tracts of that ancestry obtained from an admixed population.
#Q: Why not use steps 1 to 5? A: I already had results from RFMIX v1.0, so I created a pipeline to adapt them into input for step 5 forward.
#Q: Why is there a loop for "states"? A: I am trying to reasemble 100% native-american genomes from admixed individuals from 2 different brazilian states.

#Software
python=/opt/anaconda3/bin/python			#Python3
perl=/opt/anaconda3/bin/perl				#Perl v5 #LA: not sure it is being used for my steps, check
bcftools=/usr/local/bin/bcftools			#BCFtools v1.14

#Working directory and scripts dir
WD=/workspace/puzzle
SCRIPTS_DIR=$WD/scripts

#Initial parameters:
cutoff_freq=$1


for state in "rs" "sp"; do

        #Define input and output_directories
	INPUT_HAP_DIR=$WD/$state/nat/chr_info_unfilt/haps_nat
        INPUT_VCF_DIR=$WD/$state/nat/chr_info_unfilt/vcf_nat
        OUTPUT_DIR=$WD/$state/nat/chr_info_unfilt/seq_info/assembled
	TEMP_DIR=$WD/temp
        mkdir -p $OUTPUT_DIR
	mkdir -p $TEMP_DIR

 	#Create array with cutoff_lengths for all chrs (cutoff_length is explained further below and needed for the steps)
	array_name=cutoffs_${state}
	declare -n state_array=$array_name
        readarray state_array < $WD/$state/nat/chr_info_unfilt/cutoff_length

	#Determine number of haplotypes to be generated
	if [ "$state" = "rs" ]; then
  		n_haps=$(ls $WD/output_collapse | grep C1 | wc -l) #LA: output_collapse = 2 files per individual, matching mother and father haplotypes; C1 = beggining of ID for rs individuals
  		n_haps=$(echo "$n_haps * 15.6 / 100" | bc) #15.6 = native-american ancestry % (ADMIXTURE)
	else
  		n_haps=$(ls $WD/output_collapse | grep C2 | wc -l) #C2: beggining of ID for sp individuals
  		n_haps=$(echo "$n_haps * 11.6 / 100" | bc) #LA: 11.6 = native-american ancestry % (ADMIXTURE)
	fi

	for chr in {1..22}; do

        echo   -e   "${chr}\tchr${chr}"  >  $TEMP_DIR/rename_chr${chr}.txt #LA: necessary for step 3 and dont wanna repeat it per state

	#Define cutoff_length
	cutoff_length=$(echo "${state_array[$chr]}") #LA: arrays are 0 indexed, but first line from input is colname, so chr numbers match positions in the array

	echo "Step 1: Assemble haplotypes" "for chr " "$chr" "and state " "$state"
	# Assemble haplotypes using extracted  gene pools


 	#"01.inte.genome.cutoff.py" integrates gene pool across multiple files to generate an haplotype.
	# python   01.inte.genome.cutoff.py   <Output haplotype>   <Missing rate cutoff>   <Length cutoff>   <Gene pool 1>   …   < Gene pool n>
	# Length cutoff: The maximum length that can be extended at one time when obtaining segments on a haplotype (e.g., 6000.0 bp).
	# Can input one or more gene pool files by appending them to the script parameters in sequence.

		for i in $(seq 1 $n_haps)    # Generate n_haps haplotypes
		do
			python   $SCRIPTS_DIR/01.inte.genome.cutoff.py  \
			$TEMP_DIR/101.nat_${state}_chr${chr}.${i}.${cutoff_freq}.${cutoff_length}.txt.gz \ #LA: removed num argument, it's a cutoff from chromopainter and I didnt use this tool
			${cutoff_freq} \
			${cutoff_length} \
			$INPUT_HAP_DIR/chr_${chr}_1_nat_${state}.hap.gz \ #LA: it actually is the same population, but divided in half
			$INPUT_HAP_DIR/chr_${chr}_2_nat_${state}.hap.gz
		done



	#echo "Step 2: Generate ancestral individuals using assembled ancestral haplotypes"

	# Generate individuals from the assembled haplotypes
	# "02.trans.to.vcf.py" converts two haplotypes into a VCF-format individual.
	# python   trans.to.vcf.py   <Input gzipped VCF file>   <haplotype 1>   < haplotype 2>   <Sample ID>   <Output individual>

		for i in $(seq 1 2 $n_haps)
		do
		j=$[ $i + 1 ]
		#Combine two consecutively numbered haplotypes to generate a diploid
		python   $SCRIPTS_DIR/02.trans.to.vcf.py \
		$INPUT_VCF_DIR/chr_${chr}_nat_${state}.vcf.gz \
		$TEMP_DIR/101.nat_${state}_chr${chr}.${i}.${cutoff_freq}.${cutoff_length}.txt.gz \
		$TEMP_DIR/101.nat_${state}_chr${chr}.${j}.${cutoff_freq}.${cutoff_length}.txt.gz \
		$TEMP_DIR/201.nat_${state}_chr${chr}.${i}.${j} \
		$TEMP_DIR/202.nat_${state}_chr${chr}.${i}.${j}.${cutoff_freq}.${cutoff_length}.vcf
		#rm $TEMP_DIR/101.nat_${state}_chr${chr}.${i}.${cutoff_freq}.${cutoff_length}.txt.gz
		#rm $TEMP_DIR/101.nat_${state}_chr${chr}.${j}.${cutoff_freq}.${cutoff_length}.txt.gz
		done


	#echo "Step 3: Synthesize individual files into group files and remove missing variants"

	# Synthesize individual files into group files and remove missing variants
	# Loop through chromosomes to merge individual VCF files
	#rm   $TEMP_DIR/301.merge_${state}_chr${chr}.list.txt
	# Generate a list of VCF files for merging
		for  i   in   $(seq 1 2 $n_haps)
		do
		j=$[ i + 1 ]
		echo   "$TEMP_DIR/nat_${state}_chr${chr}.${i}.${j}.${cutoff_freq}.${cutoff_length}.vcf"   >> $TEMP_DIR/301.merge_${state}_chr${chr}.list.txt
		done
	#rm $TEMP_DIR/202.nat_${state}_chr${chr}.${i}.${j}.${cutoff_freq}.${cutoff_length}.vcf
	# Merge the VCF files
	bcftools   merge   -l  $TEMP_DIR/301.merge_${state}_chr${chr}.list.txt   -O z   -o $TEMP_DIR/302.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.tmp.vcf.gz   &&    tabix   -f   -p vcf $TEMP_DIR/302.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.tmp.vcf.gz
	#rm $TEMP_DIR/202.nat_${state}_chr${chr}.${i}.${j}.${cutoff_freq}.${cutoff_length}.vcf #LA: after the last iteration there will still be one for chr 22

	# Rename chromosomes in the merged file.
	bcftools   annotate   --rename-chrs   $TEMP_DIR/rename_chr${chr}.txt   -O z   -o $OUTPUT_DIR/303.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.vcf.gz  $TEMP_DIR/302.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.tmp.vcf.gz   &&   tabix   -f   -p vcf   $TEMP_DIR/302.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.vcf.gz
	#rm $TEMP_DIR/302.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.tmp.vcf.gz
	#rm $TEMP_DIR/rename_chr${chr}.txt

	# Remove missing variants
	bcftools   view   -i 'F_MISSING<0.001'   --threads 10   -O z   -o $OUTPUT_DIR/304.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.rm.missing.vcf.gz $OUTPUT_DIR/303.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.vcf.gz   &&   tabix   -f   -p vcf   $OUTPUT_DIR/304.nat_chr${chr}_${state}.${cutoff_freq}.${cutoff_length}.rm.missing.vcf.gz
	done
done
