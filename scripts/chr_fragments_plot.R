#Load project environment
if (!requireNamespace("renv", quietly = TRUE)) {
  # Install renv and its dependencies
  install.packages("renv", dependencies = TRUE)
}
library(renv)
renv::restore()
# Load the required packages
library(karyoploteR)
library(viridis)
# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
# Check if the correct number of arguments is provided
if (length(args) != 2) {
  stop("Please provide the positions file path and the PDF file name (without .pdf extension) as command line arguments.")
}
# Extract the arguments
positions_file <- args[1]
pdf_file <- paste0(args[2], ".pdf")
# Read the data file
dados <- read.table(positions_file, header = FALSE, sep = "\t")
positions <- dados[2:4]
positions[, 1] <- paste0("chr", positions[, 1])
# Extract the chromosome from your data (assuming all values in the second column are the same)
chromosome <- positions[1, 1]

# Start PDF device
pdf(pdf_file)

# Create a karyotype object for chromosome drawing with the extracted chromosome
kp <- plotKaryotype(genome = "hg38", chromosomes = chromosome)
kpAddLabels(kp, labels = "frag/n nat")
# Define the number of fragments
num_fragments <- nrow(positions)
# Generate a rainbow color ramp based on the number of fragments using the viridis color palette with turbo option
#color_ramp <- colorRampPalette(viridis(256, option = "inferno"))
#colors <- c("black", "grey")
# Add genomic regions of the specified chromosome to the plot, one above the other, with different colors
kpPlotRegions(kp, data = positions, col="#53BDA5", border=darker("#53BDA5"))
# End PDF device
dev.off()
#Save current environment
renv::snapshot()
