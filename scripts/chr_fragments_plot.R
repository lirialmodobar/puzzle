# Load project environment
if (!requireNamespace("renv", quietly = TRUE)) {
  # Install renv and its dependencies
  install.packages("renv", dependencies = TRUE)
}
library(renv)
renv::restore()

# Load the required packages
library(karyoploteR)

# Set the working directory
wd <- "~/liri/teste_dir"  

# Define the labels and corresponding colors
labels <- c("nat", "eur", "afr", "unk")
colors <- c("#6caf5e", "#7297b4", "#c05040", "#919191")

# Loop through the labels and chromosomes
for (i in 1:length(labels)) {
  label <- labels[i]
  color <- colors[i]
  for (chr in 1:22) {
    positions_file <- file.path(wd, label, paste0("chr_", chr, "_", label, "_sort_filt_size_gap.txt"))
    pdf_file <- file.path(wd, label,  paste0("chr_", chr, "_", label, "_plot_fragments.pdf"))
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
    kpAddLabels(kp, labels = paste("frag", label))
    # Add fragments to the plot
    kpPlotRegions(kp, data = positions, col=color, border=darker(color), avoid.overlapping=TRUE)
    # End PDF device
    dev.off()     
  }
}
# Save current environment
renv::snapshot()
