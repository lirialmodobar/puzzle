# Install and load the karyoploteR package
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", dependencies = TRUE)
BiocManager::install("karyoploteR", dependencies = TRUE)
library(karyoploteR)

# Read the data file
dados <- read.table("nat/chr_1_nat_sort_filt_size_gap.txt", header = FALSE, sep=' ')
positions <- dados[2:4]
colnames(positions) <- c("chr", "start", "end")
print(positions)
class(positions)
#positions <- data.frame(chr=c("chr1", "chr1", "chr1", "chr1"), start=c(30e6, 70e6, 150e6, 180e6), end=c(50e6, 90e6, 170e6, 200e6))
# Extract the chromosome from your data (assuming all values in the second column are the same)
chromosome <- paste0("chr", positions[1,1])

pdf("karyotype_plot.pdf")
# Create a karyotype object for chromosome drawing with the extracted chromosome
kp <- plotKaryotype(genome = "hg38", chromosomes = chromosome)

# Calculate the number of fragments
num_fragments <- nrow(positions)

# Calculate the height for each fragment
height <- 0.1

# Add genomic regions of the specified chromosome to the plot, one above the other
for (i in 1:num_fragments) {
  r0 <- i * height
  r1 <- r0 + height
  kpPlotRegions(kp, data = positions[i, ], col = "#EEFFCC", border = darker("#EEFFCC"), r0 = r0, r1 = r1)
}

dev.off()
