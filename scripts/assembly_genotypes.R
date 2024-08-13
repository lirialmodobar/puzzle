library(dplyr)
library(tidyr)
library(readr)

args <- commandArgs(trailingOnly = T)

chr <- args[1]
state <- args[2]
anc <- args[3]
comb_number <- args[4]

base_dir <- "/scratch/unifesp/pgt/liriel.almodobar"
collapse_dir <- file.path(base_dir, "puzzle", state, anc, "chr_info_unfilt")
seq_dir <- file.path(collapse_dir, "seq_info")

combs_file <- paste0("chr_", chr, "_", anc, "_", state, "_comb_", comb_number, ".tsv")
seq_file <- paste0("cohaps_chr_", chr, "_", anc, "_", state, ".txt" )

combs_df <- file.path(seq_dir, combs_file)
seq_df <- file.path(seq_dir, seq_file)

combs_df <- read_tsv(combs_df)
seq_df <- read_tsv(seq_df) ##check

combs_seqs <- inner_join(combs_df, seq_df, by = c("id" = "V1", "chr" = "V2", "first_bp" = "V3", "last_bp" = "V4")) #check


rs_cols <- combs_seqs[, -c(1,2,3,4,5,6)] ##check


# Convert the marker columns into a long format
markers_long <- rs_cols %>%
  pivot_longer(cols = starts_with("rs"), names_to = "marker", values_to = "data") %>%
  filter(!is.na(data))

# Split the data into rsid, position, and allele information
split_info <- do.call(rbind, strsplit(markers_long$data, ","))

# Convert to data frame with appropriate column names
markers_df <- data.frame(
  rsid = split_info[, 1],
  position = as.integer(split_info[, 2]),
  allele = split_info[, 3],
  stringsAsFactors = FALSE
)

# Define the interval from the first to the last position
first_position <- min(combs_seqs$first_bp) ##check
last_position <- max(combs_seqs$last_bp) ##check
interval <- first_position:last_position

# Initialize a vector to hold alleles over the entire interval
allele_sequence <- rep("-", length(interval))
names(allele_sequence) <- interval

# Fill in the alleles at the corresponding positions
allele_sequence[as.character(markers_df$position)] <- markers_df$allele

# Create a single row output with all rsids and the full allele sequence
output_df <- data.frame(
  rsid = paste(markers_df$rsid, collapse = ","),
  allele_sequence = paste(allele_sequence, collapse = "")
)

markers <- paste0("markers_chr_", chr, "_", anc, "_", state, "_comb_", comb_number, ".txt")
markers_file <- file.path(seq_info, markers)
allele_seq <- paste0("allele_seq_chr_", chr, "_", anc, "_", state, "_comb_", comb_number, ".txt")
  
# Save each column of output_df as a text file

writeLines(output_df$allele_sequence, con = file.path(seq_info, allele_seq))

#Save markers df (snp and allele as columns)

write.table(markers_df, markers_file, sep = "\t", row.names = FALSE)

## For testing

#input_df <- data.frame(
 # initial_bp = c(792461, 94730922),
  #final_bp = c(792461, 165211101),
  #rs1 = c("rs116587930,792461,G", "rs116587930,792461,G"),
  #rs2 = c("rs114525117,823656,G", "rs114525117,823656,G"),
  #rs3 = c("rs12127425,858952,G", "rs12127425,858952,G"),
  #rs4 = c("rs28678693,903285,T", "rs28678693,903285,T"),
  #rs5 = c("rs4970382,905373,C", "rs4970382,905373,T"),
  #rs6 = c("rs4475691,911428,T", "rs4475691,911428,C"),
  #rs7 = c("rs72631889,916010,G", "rs72631889,916010,T"),
  #rs8 = c("rs7537756,918870,G", "rs7537756,918870,A"),
  #rs9 = c("rs2880024,931513,T", "rs2880024,931513,C"),
  #rs10 = c(NA, "rs76723341,937572,C"),
  #rs11 = c(NA, "rs143853699,944531,G"),
  #rs12 = c(NA, "rs2272757,946247,A"),
  #rs13 = c(NA, "rs67274836,949387,A"),
  #rs14 = c(NA, "rs3828049,953858,G"),
  #rs15 = c(NA, "rs35241590,969372,T"),
  #rs16 = c(NA, "rs28561399,975093,G"),
  #rs17 = c(NA, "rs3748588,975721,C")
#)