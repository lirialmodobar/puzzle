library(arrow)
library(dplyr)
library(tidyr)
library(ggplot2)

#preparing eQTL data from GTEx
eqtls_list <- list.files("/home/yuri/Downloads/GTEx_Analysis_v10_eQTL_updated/", pattern = "*.parquet", full.names = TRUE)
eqtls <- lapply(eqtls_list, read_parquet)
eqtls <- lapply(eqtls, as.data.frame)
eqtls_vars_pos <- sapply(eqtls, separate, variant_id, into = c("chr", "pos"), sep = "_", remove = FALSE)
eqtls_vars_pos <- lapply(seq_len(ncol(eqtls_vars_pos)), function(i) {
  data.frame(chr = eqtls_vars_pos["chr", i], pos = eqtls_vars_pos["pos", i])
})
eqtls_vars_pos <- lapply(eqtls_vars_pos, function(df) {
  df$chr <- gsub("chr", "", df$chr)
  return(df)
})
eqtls_vars_pos <- lapply(eqtls_vars_pos, function(df) {
  df$chr <- as.numeric(df$chr) # Apply gsub to resto column
  df
})
eqtls_vars_pos <- lapply(eqtls_vars_pos, function(df) {
  df$pos <- as.numeric(df$pos) # Apply gsub to resto column
  df
})

#Occurrences RS > SP
diff_occur_rs_gt_sp <- read.csv("/home/yuri/liri/puzzle/comp_occur/all/3dp/diff_rs_gt_sp_all_chr.csv")
eqtls_occur_rs_gt_sp <- lapply(eqtls_vars_pos, inner_join, diff_occur_rs_gt_sp, by = c("chr", "pos" = "position"))

eqtls_occur_rs_gt_sp <- Map(function(df, file) {
  if (nrow(df) > 0) {
    tissue_name <- gsub(".*/([A-Za-z_]+)\\.v10\\.eQTLs.*", "\\1", file)
    df$tissue <- tissue_name
  } else {
    df$tissue <- character(0)  # Ensures an empty column for empty data frames
  }
  df
}, eqtls_occur_rs_gt_sp, eqtls_list)
eqtls_occur_rs_gt_sp <- do.call(rbind, eqtls_occur_rs_gt_sp)
eqtls_occur_rs_gt_sp$tissue <- gsub(".*/([^/]+)\\.v10\\.eQTLs.*", "\\1", eqtls_occur_rs_gt_sp$tissue)
colnames(eqtls_occur_rs_gt_sp) <- c("chr", "pos", "rsid", "tissue")

#Occurrences SP gt RS

diff_occur_sp_gt_rs <- read.csv("/home/yuri/liri/puzzle/comp_occur/all/3dp/diff_sp_gt_rs_all_chr.csv")
eqtls_occur_sp_gt_rs <- lapply(eqtls_vars_pos, inner_join, diff_occur_sp_gt_rs, by = c("chr", "pos" = "position"))
eqtls_occur_sp_gt_rs <- Map(function(df, file) {
  if (nrow(df) > 0) {
    tissue_name <- gsub(".*/([A-Za-z_]+)\\.v10\\.eQTLs.*", "\\1", file)
    df$tissue <- tissue_name
  } else {
    df$tissue <- character(0)  # Ensures an empty column for empty data frames
  }
  df
}, eqtls_occur_sp_gt_rs, eqtls_list)
eqtls_occur_sp_gt_rs <- do.call(rbind, eqtls_occur_sp_gt_rs)
eqtls_occur_sp_gt_rs$tissue <- gsub(".*/([^/]+)\\.v10\\.eQTLs.*", "\\1", eqtls_occur_sp_gt_rs$tissue)
colnames(eqtls_occur_sp_gt_rs) <- c("chr", "pos", "rsid", "tissue")

#Allele freq differences

diff_freq <- read.csv("/home/yuri/liri/puzzle/comp_allele_freq/snvs_diff_all.csv")
diff_freq <- diff_freq[,c(2,3,7)]
eqtls_freq <- lapply(eqtls_vars_pos, inner_join, diff_freq, by = c("chr" = "CHR", "pos" = "BP"))
eqtls_freq <- Map(function(df, file) {
  if (nrow(df) > 0) {
    tissue_name <- gsub(".*/([A-Za-z_]+)\\.v10\\.eQTLs.*", "\\1", file)
    df$tissue <- tissue_name
  } else {
    df$tissue <- character(0)  # Ensures an empty column for empty data frames
  }
  df
}, eqtls_freq, eqtls_list)
eqtls_freq <- do.call(rbind, eqtls_freq)
eqtls_freq $tissue <- gsub(".*/([^/]+)\\.v10\\.eQTLs.*", "\\1", eqtls_freq$tissue)
colnames(eqtls_freq) <- c("chr", "pos", "rsid", "tissue")

#Number of eqtls for each comparision

eqtls_freq_number <- length(unique(eqtls_freq$rsid))
eqtls_occur_rs_gt_number <- length(unique(eqtls_occur_rs_gt_sp$rsid))
eqtls_occur_sp_gt_number <- length(unique(eqtls_occur_sp_gt_rs$rsid))

write.csv(eqtls_occur_rs_gt_sp, "/home/yuri/liri/puzzle/comp_occur/all/3dp/eqtls_rs_gt.csv", row.names = FALSE, quote = FALSE)
write.csv(eqtls_occur_sp_gt_rs, "/home/yuri/liri/puzzle/comp_occur/all/3dp/eqtls_sp_gt.csv", row.names = FALSE, quote = FALSE)
write.csv(eqtls_freq, "/home/yuri/liri/puzzle/comp_allele_freq/eqtls_diff.csv", row.names = FALSE, quote = FALSE)

#Number of eqtls per tissue excluding variants that are eqtls for more than one gene in the tissue
eqtls_tissues_occur_rs_gt <- eqtls_occur_rs_gt_sp %>% distinct(rsid, tissue)
eqtls_tissues_occur_sp_gt <- eqtls_occur_sp_gt_rs %>% distinct(rsid, tissue)
eqtls_tissues_freq <- eqtls_freq %>% distinct(rsid, tissue)


n_eqtls_tissue_occur_rs_gt <- as.data.frame(table(eqtls_tissues_occur_rs_gt$tissue))
n_eqtls_tissue_occur_sp_gt <- as.data.frame(table(eqtls_tissues_occur_sp_gt$tissue))
n_eqtls_tissue_freq <- as.data.frame(table(eqtls_tissues_freq$tissue))

png("/home/yuri/liri/puzzle/comp_occur/all/3dp/n_eqtls_tissue_occur_rs_gt.png", width = 3800, height = 1080, res = 300)
ggplot(n_eqtls_tissue_occur_rs_gt, aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "#FFB3BA") +
  theme_minimal() +
  labs(title = "Number of eQTLs per tissue (occurrences RS > SP)", x = "Tissue", y = "Number of eQTLs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability
dev.off()

png("/home/yuri/liri/puzzle/comp_occur/all/3dp/n_eqtls_tissue_occur_sp_gt.png", width = 3800, height = 1080, res = 300)
ggplot(n_eqtls_tissue_occur_sp_gt, aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "#B3D9FF") +
  theme_minimal() +
  labs(title = "Number of eQTLs per tissue (occurrences SP > RS)", x = "Tissue", y = "Number of eQTLs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability
dev.off()

png("/home/yuri/liri/puzzle/comp_allele_freq/n_eqtls_tissue_freq.png", width = 3800, height = 1080, res = 300)
ggplot(n_eqtls_tissue_freq, aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "#B3FFB3") +
  theme_minimal() +
  labs(title = "Number of eQTLs per tissue (frequency differences)", x = "Tissue", y = "Number of eQTLs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability
dev.off()

#Tissues with high amount of eqtls

mean_eqtls_tissue_rs_gt <- mean(n_eqtls_tissue_occur_rs_gt$Freq)
sd_eqtls_tissue_rs_gt <- sd(n_eqtls_tissue_occur_rs_gt$Freq)
alta_qtd_tec_rs_gt <- n_eqtls_tissue_occur_rs_gt$Freq > 3 * sd_eqtls_tissue_rs_gt
alta_qtd_tissue_rs <- n_eqtls_tissue_occur_rs_gt[alta_qtd_tec_rs_gt, ]

mean_eqtls_tissue_sp_gt <- mean(n_eqtls_tissue_occur_sp_gt$Freq)
sd_eqtls_tissue_sp_gt <- sd(n_eqtls_tissue_occur_sp_gt$Freq)
alta_qtd_tec_sp_gt <- n_eqtls_tissue_occur_sp_gt$Freq  > 3 * sd_eqtls_tissue_sp_gt
alta_qtd_tissue_sp <- n_eqtls_tissue_occur_sp_gt[alta_qtd_tec_sp_gt, ]

mean_eqtls_tissue_freq <- mean(n_eqtls_tissue_freq$Freq)
sd_eqtls_tissue_freq <- sd(n_eqtls_tissue_freq$Freq)
alta_qtd_tec_freq <- n_eqtls_tissue_freq$Freq > 3 * sd_eqtls_tissue_freq
alta_qtd_tissue_freq <- n_eqtls_tissue_freq[alta_qtd_tec_freq, ]


