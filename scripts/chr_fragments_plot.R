# Load project environment
if (!requireNamespace("renv", quietly = TRUE)) {
	# Install renv and its dependencies
	install.packages("renv", dependencies = TRUE)
}
library(renv)
renv::restore()

# Load the required packages
library(karyoploteR)
library(optparse)

# Set the working directory
wd <- "~/liri/teste_dir"  

# Define the labels and corresponding colors
labels <- c("nat", "eur", "afr", "unk")
colors <- c("#6caf5e", "#7297b4", "#c05040", "#919191")

#Create plot
create_fragments_plot <- function(label, label_dir, color, chr, n_rows) {
	graph_dir <- "frags_plots"
	if (!file.exists(file.path(label_dir, graph_dir))) {
		dir.create(file.path(label_dir, graph_dir))
	}
	file_name_prefix <- paste0("chr_", chr, "_", label)
	positions_file <- file.path(label_dir, paste0(file_name_prefix, "_sort_filt_size_gap.txt"))
	pdf_file <- file.path(label_dir, graph_dir, paste0(file_name_prefix, "_plot_fragments.pdf"))
	# Read the data file
	dados <- read.table(positions_file, header = FALSE, sep = "\t")
	positions <- dados[2:4]
	positions[, 1] <- paste0("chr", positions[, 1])
	# Extract the chromosome from your data (assuming all values in the second column are the same)
	chromosome <- positions[1, 1]
	# Start PDF device
	pdf_file <- file.path(label_dir, graph_dir, paste0(n_rows,file_name_prefix, "_plot_fragments.pdf"))
	pdf(pdf_file)
	# Create a karyotype object for chromosome drawing with the extracted chromosome
	kp <- plotKaryotype(genome = "hg38", chromosomes = chromosome)
	kpAddLabels(kp, labels = paste("frag", label))
	# Add fragments to the plot
	kpPlotRegions(kp, data = positions[1:n_rows, ], col=color, border=darker(color), avoid.overlapping=TRUE)
	# End PDF device
	dev.off()
}

option_list <- list(
	make_option(c("--rows_per_anc"), type = "file", default = NULL,
              help = "Tab-delimited file with rows and labels (no header)."),
	make_option(c("--run_as_test"), type = "logical", default = FALSE,
              help = "Flag to run the test.")
)

# Parse command-line arguments
opt_parser <- OptionParser(usage = "Usage: Rscript script.R [options]", option_list = option_list)
opt <- parse_args(opt_parser)

if (opt$run_as_test) {
	# Check that --rows_per_anc is not provided when --run_as_test is enabled
	if (!is.null(opt$rows_per_anc)) {
		cat("Error: The --run_as_test flag should not be used with the --rows_per_anc option.\n")
		quit(status = 1)
	}
} else {
	# Check that --rows_per_anc is provided when not running as a test
	if (is.null(opt$rows_per_anc) || !file.exists(opt$rows_per_anc)) {
		cat("Error: Please provide a valid --rows_per_anc file.\n")
		quit(status = 1)
	}
	# Read the provided file and validate its format
	rows_data <- read.table(opt$rows_per_anc, header = FALSE, sep = "\t")
		if (ncol(rows_data) != 2 || any(is.na(rows_data$V1)) || any(is.na(rows_data$V2) || any(duplicated(rows_data$V2))) {
			cat("Error: The input file must contain two tab-delimited columns with no header (n_rows and label), and labels should not be repeated.\n")
			quit(status = 1)
		}
}

# Loop through the labels and chromosomes
for (i in 1:length(labels)) {
	label <- labels[i]
	color <- colors[i]
	label_dir <- file.path(wd, label, "chr_info_filt_largest_frag")
	if (opt$run_as_test) {
		files <- list.files(label_dir, full.names = TRUE)
		max_rows <- 0
		for (file in files) {
			# Use the system command to count the number of lines in the file
			line_count <- as.numeric(system(paste("wc -l", shQuote(file)), intern = TRUE))
			# Extract the number of rows from the command output
			num_rows <- line_count[1]
			# Update max_rows if necessary
			if (num_rows > max_rows) {
				max_rows <- num_rows
			}
		}
	rows <- seq(from = 100, to = max_rows, by = 100)
	} 
	# Create vector with the numbers of rows to be tested for that label
	for (chr in 1:22) {
		if (opt$run_as_test) {
			for (n_rows in rows) {
				create_fragments_plot(label, label_dir, color, chr, n_rows)
			}
		} else {
			# Ask the user for the value of n_rows
			n_rows <- rows_data$V1[rows_data$V2 == label][1]
			create_fragments_plot(label, label_dir, color, chr, n_rows)
		}
	}
}
# Save current environment
renv::snapshot()
