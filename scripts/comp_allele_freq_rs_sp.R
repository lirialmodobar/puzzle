library(dplyr)
library(tidyr)

# Directories
rs_dir <- "/home/yuri/liri/puzzle_sdumont/rs/nat/chr_info_unfilt/count_info"
sp_dir <- "/home/yuri/liri/puzzle_sdumont/sp/nat/chr_info_unfilt/count_info"
allele_freq_dir <- "/home/yuri/liri/puzzle/comp_allele_freq/"

# Initialize empty data frames to store results for all chromosomes
rsvars_only_combined <- data.frame()
spvars_only_combined <- data.frame()
rssp_comm_combined <- data.frame() 
rs_all <- data.frame() 

# Loop through chromosomes 1 to 22
for (chr in 1:22) {
  # File paths for current chromosome
  rs_file <- file.path(rs_dir, paste0("freqs_chr_", chr, "_nat_rs.txt"))
  sp_file <- file.path(sp_dir, paste0("freqs_chr_", chr, "_nat_sp.txt"))
  
  # Read and filter data
  rs <- read.table(rs_file, sep = "\t", header = FALSE)
  sp <- read.table(sp_file, sep = "\t", header = FALSE)
  
  colnames(rs) <- c("SNP", "CHR", "BP", "allele", "count_rs", "total_rs", "freq_rs")
  colnames(sp) <- c("SNP", "CHR", "BP", "allele", "count_sp", "total_sp", "freq_sp")
  
  rs <- subset(rs, total_rs > 10)
  sp <- subset(sp, total_sp > 10)
  
  rs_all <- bind_rows(rs_all, rs)
  
  # Extract variables of interest
  rsvars <- rs[, c("CHR", "SNP", "allele", "freq_rs")]
  spvars <- sp[, c("CHR", "SNP", "allele", "freq_sp")]
  
  colnames(rsvars) <- c("chr", "var", "allele", "freq")
  colnames(spvars) <- c("chr", "var", "allele", "freq")
  
  # Common variants and frequency difference
  rssp_comm <- inner_join(rsvars, spvars, by = c("chr", "var", "allele"), suffix = c(".rsvars", ".spvars"))
  
  rssp_comm_combined <- bind_rows(rssp_comm_combined, rssp_comm)
  
  # Get rsvars_only and spvars_only
  rsvars_only <- anti_join(rsvars, spvars, by = c("chr", "var", "allele"))
  spvars_only <- anti_join(spvars, rsvars, by = c("chr", "var", "allele"))
  
  # Append to combined data frames
  rsvars_only_combined <- bind_rows(rsvars_only_combined, rsvars_only)
  spvars_only_combined <- bind_rows(spvars_only_combined, spvars_only)
}
  
rssp_comm_combined <- rssp_comm_combined %>% 
  mutate(allele_freq_diff_rssp = round(abs(freq.rsvars - freq.spvars), digits = 2), allele_freq_diff = round(freq.rsvars - freq.spvars, digits = 2))
diff_vars_all_chr <- subset(rssp_comm_combined, abs(allele_freq_diff_rssp - mean(allele_freq_diff_rssp)) > (3 * sd(allele_freq_diff_rssp))) #only for all

max_diff_chr <- diff_vars_all_chr %>% 
  dplyr::select(chr, var, allele, freq.rsvars, freq.spvars, allele_freq_diff_rssp) %>%
  group_by(chr) %>%
  slice_max(order_by = allele_freq_diff_rssp, n = 1) %>%
  dplyr::filter(row_number() %% 2 == 0)  # Keep only even rows

# VEP input preparation
vep <- inner_join(rs_all, diff_vars_all_chr, by = c("CHR" = "chr", "SNP" = "var", "allele")) #for all: rs_all, diff_vars_all_chr
vep <- vep %>% mutate(rsids = ifelse(grepl("^rs", SNP), SNP, NA))
vep <- vep %>%
  mutate(SNP = paste(CHR, BP, sep = ":")) %>%
  dplyr::select(SNP, CHR, BP, allele, freq_rs, rsids)
  
subset_not_50 <- subset(vep, freq_rs != 50)
subset_50_even <- subset(vep, freq_rs == 50 & (1:nrow(vep)) %% 2 == 0)
subset_50_odd <- subset(vep, freq_rs == 50 & (1:nrow(vep)) %% 2 == 1)
  
vep_a1 <- subset_not_50 %>%
  group_by(SNP, CHR, BP) %>%
  slice_max(order_by = freq_rs) %>%
  ungroup() %>%
  bind_rows(subset_50_even)
  
vep_a2 <- subset_not_50 %>%
  group_by(SNP, CHR, BP) %>%
  slice_min(order_by = freq_rs) %>%
  ungroup() %>%
  bind_rows(subset_50_odd)
  
colnames(vep_a1) <- c("SNP", "CHR", "BP", "A2", "freq_A2", "rsids")
colnames(vep_a2) <- c("SNP", "CHR", "BP", "A1", "freq_A1", "rsids")
  
vep_all <- inner_join(vep_a1, vep_a2, by = c("SNP", "CHR", "BP", "rsids")) %>% 
  dplyr::select(SNP, CHR, BP, A1, A2, rsids) %>%
  mutate(BP2 = BP, strand = 1, allele = paste(A2, A1, sep = "/")) %>%
  dplyr::select(SNP, CHR, BP, BP2, strand, allele, rsids) %>%
  arrange(CHR, BP)

snv_diff_combined <- dplyr::filter(vep_all, !is.na(vep_all$rsids)) 

vep_all <- vep_all[,c(2,3,4,6,5)]
  
# Write combined data frames to files
write.csv(diff_vars_all_chr, paste0(allele_freq_dir, "diff_vars_all_chr.csv"), row.names = FALSE, quote = FALSE)
write.csv(max_diff_chr, paste0(allele_freq_dir, "max_diff_chr.csv"), row.names = FALSE, quote = FALSE)
write.csv(rsvars_only_combined, paste0(allele_freq_dir, "rsvars_only_combined.csv"), row.names = FALSE, quote = FALSE)
write.csv(spvars_only_combined, paste0(allele_freq_dir, "spvars_only_combined.csv"), row.names = FALSE, quote = FALSE)
write.csv(snv_diff_combined, paste0(allele_freq_dir,"snvs_diff_all.csv"), row.names = FALSE, quote = FALSE)
write.table(vep_all, paste0(allele_freq_dir, "vep_all.tsv"), row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")
