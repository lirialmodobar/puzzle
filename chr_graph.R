# Install and load the karyoploteR package
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", dependencies = TRUE)
BiocManager::install("karyoploteR", dependencies = TRUE)
library(karyoploteR)

# Read the data file
dados <- read.table("nat/chr_1_nat_sort_filt_size_gap.txt", header = FALSE, sep=' ')

# Extract the chromosome from your data (assuming all values in the second column are the same)
chromosome <- dados[1, 2]

# Create a karyotype object for chromosome drawing with the extracted chromosome
kp <- plotKaryotype(genome = "hg38", chromosomes = chromosome)

# Add genomic regions of the specified chromosome to the plot
kpPlotRegions(kp, data = dados, start.column = 3, end.column = 4, col = "blue", chr.column = 2)

# Display the plot
plot(kp)
