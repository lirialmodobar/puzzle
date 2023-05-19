# Install and load the karyoploteR package
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", dependencies = TRUE)
BiocManager::install("karyoploteR", dependencies = TRUE)
library(karyoploteR)

# Read the data file
dados <- read.table("nat/chr_1_nat_sort_filt_size_gap.txt", header = FALSE, sep=' ')
positions <- dados[2:4]
positions[,1] <- paste0("chr", positions[,1])
start <- positions[[2]]
end <- positions[[3]]
print(positions)
positions <- data.frame(chr=c("chr1", "chr1", "chr1", "chr1"), start=c(1, 15, 30, 50), end=c(150, 300, 400, 700))
# Extract the chromosome from your data (assuming all values in the second column are the same)
chromosome <- positions[1, 1]

pdf("karyotype_plot.pdf")
# Create a karyotype object for chromosome drawing with the extracted chromosome
kp <- plotKaryotype(genome = "hg38", chromosomes = chromosome)

# Calculate the number of fragments
num_fragments <- nrow(positions)

# Add genomic regions of the specified chromosome to the plot, one above the other
kpRect(kp, chr=chromosome, x0=start, x1=end, y0=0.2, y1=0.8)

dev.off()
