# Load the required packages
library(karyoploteR)
library(viridisLite)

# Get command line arguments
#args <- commandArgs(trailingOnly = TRUE)

# Check if the correct number of arguments is provided
#if (length(args) != 2) {
#  stop("Please provide the positions file path and the PDF file name (without .pdf extension) as command line arguments.")
#}

# Extract the arguments
positions_file <- "nat/chr_1_nat_sort_filt_size_gap.txt"
pdf_file <- paste("karyotype_plot", ".pdf")

# Read the data file
dados <- read.table(positions_file, header = FALSE, sep = " ")
positions <- dados[2:4]
positions[, 1] <- paste0("chr", positions[, 1])

# Extract the chromosome from your data (assuming all values in the second column are the same)
chromosome <- positions[1, 1]

# Start PDF device
pdf(pdf_file)

# Create a karyotype object for chromosome drawing with the extracted chromosome
kp <- plotKaryotype(genome = "hg38", chromosomes = chromosome)

# Define the number of fragments
num_fragments <- nrow(positions)

# Generate a pastel color palette based on the number of fragments using the viridis palette
colors <- viridis(num_fragments, option = "D", begin = 0.6, end = 0.9)

# Add genomic regions of the specified chromosome to the plot, one above the other, with different colors
kpPlotRegions(kp, data = positions, col = colors)

# End PDF device
dev.off()
