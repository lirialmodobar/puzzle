
#eQTL

library(arrow)

eqtls_list <- list.files("/home/yuri/Downloads/GTEx_Analysis_v10_eQTL_updated/", pattern = "*.parquet", full.names = TRUE)
eqtls <- lapply(eqtls_list, read_parquet)
eqtls <- lapply(eqtls, as.data.frame)
eqtls_vars_pos <- sapply(eqtls, separate, variant_id, into = c("resto", "pos"), sep = "_", remove = FALSE)
eqtls_vars_pos <- lapply(seq_len(ncol(eqtls_vars_pos)), function(i) {
  data.frame(chr = eqtls_vars_pos["chr", i], pos = eqtls_vars_pos["pos", i])
})
eqtls_vars_pos <- lapply(seq_len(ncol(eqtls_vars_pos)), function(i) {
  data.frame(chr = eqtls_vars_pos["chr", i], pos = eqtls_vars_pos["pos", i])
})
eqtls_vars_pos <- lapply(dfs, function(df) {
  eqtls_vars_pos$chr <- as.numeric(df$chr) # Apply gsub to resto column
  df
})
eqtls_vars_pos <- lapply(dfs, function(df) {
  eqtls_vars_pos$pos <- as.numeric(eqtls_vars_pos$pos) # Apply gsub to resto column
  eqtls_vars_pos
})

diff_occur_rs_gt_sp <- read.csv("/home/yuri/liri/puzzle/comp_occur/all/3dp/diff_rs_gt_sp_all_chr.csv")
diff_occur_sp_gt_rs <- read.csv("/home/yuri/liri/puzzle/comp_occur/all/3dp/diff_sp_gt_rs_all_chr.csv")
eqtls_occur <- lapply(dfs, inner_join, diff_occur_sp_gt_rs, by = c("chr", "pos" = "position"))
eqtls_occur_3 <- Map(function(df, file) {
  if (nrow(df) > 0) {
    tissue_name <- gsub(".*/([A-Za-z_]+)\\.v10\\.eQTLs.*", "\\1", file)
    df$tissue <- tissue_name
  } else {
    df$tissue <- character(0)  # Ensures an empty column for empty data frames
  }
  df
}, eqtls_occur, eqtls_list)
eqtls_occur_5 <- do.call(rbind, eqtls_occur_3)
eqtls_occur_5$tissue <- gsub(".*/([^/]+)\\.v10\\.eQTLs.*", "\\1", eqtls_occur_5$tissue)
colnames(eqtls_occur_5) <- c("chr", "pos", "rsid", "tissue")


diff_freq <- read.csv("/home/yuri/liri/puzzle/comp_allele_freq/snvs_diff_all.csv")
diff_freq <- diff_freq[,c(1,2,9)]
eqtls_freq <- lapply(dfs, inner_join, diff_freq, by = c("resto" = "chr", "pos" = "BP"))
eqtls_freq_3 <- Map(function(df, file) {
  if (nrow(df) > 0) {
    tissue_name <- gsub(".*/([A-Za-z_]+)\\.v10\\.eQTLs.*", "\\1", file)
    df$tissue <- tissue_name
  } else {
    df$tissue <- character(0)  # Ensures an empty column for empty data frames
  }
  df
}, eqtls_freq, eqtls_list)
eqtls_freq_4 <- do.call(rbind, eqtls_freq_3)
eqtls_freq_4$tissue <- gsub(".*/([^/]+)\\.v10\\.eQTLs.*", "\\1", eqtls_freq_4$tissue)
colnames(eqtls_freq_4) <- c("chr", "pos", "rsid", "tissue")


eqtls_freq_number <- length(unique(eqtls_freq_4$rsid))
eqtls_occur_rs_gt_number <- length(unique(eqtls_occur_4$rsid))
eqtls_occur_sp_gt_number <- length(unique(eqtls_occur_5$rsid))

write.csv(eqtls_occur_4, "/home/yuri/liri/puzzle/comp_occur/all/3dp/eqtls_rs_gt.csv", row.names = FALSE, quote = FALSE)
write.csv(eqtls_occur_5, "/home/yuri/liri/puzzle/comp_occur/all/3dp/eqtls_sp_gt.csv", row.names = FALSE, quote = FALSE)
write.csv(eqtls_freq_4, "/home/yuri/liri/puzzle/comp_allele_freq/eqtls_diff.csv", row.names = FALSE, quote = FALSE)

eqtls_tissues_occur_rs_gt <- eqtls_occur_4 %>% distinct(rsid, tissue)
eqtls_tissues_occur_sp_gt <- eqtls_occur_5 %>% distinct(rsid, tissue)
eqtls_tissues_freq_gt <- eqtls_freq_4 %>% distinct(rsid, tissue)


n_eqtls_tissue_occur_rs_gt <- as.data.frame(table(eqtls_occur_4$tissue))
n_eqtls_tissue_occur_sp_gt <- as.data.frame(table(eqtls_occur_5$tissue))
n_eqtls_tissue_freq <- as.data.frame(table(eqtls_freq_4$tissue))

library(ggplot2)


png("/home/yuri/liri/puzzle/comp_occur/all/3dp/n_eqtls_tissue_occur_rs_gt.png", width = 3800, height = 1080, res = 250)
ggplot(n_eqtls_tissue_occur_rs_gt, aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "#FFB3BA") +
  theme_minimal() +
  labs(title = "Number of eQTLs per tissue (occurrences RS > SP)", x = "Tissue", y = "Number of eQTLs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability
dev.off()

png("/home/yuri/liri/puzzle/comp_occur/all/3dp/n_eqtls_tissue_occur_sp_gt.png", width = 3800, height = 1080, res = 250)
ggplot(n_eqtls_tissue_occur_sp_gt, aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "#B3D9FF") +
  theme_minimal() +
  labs(title = "Number of eQTLs per tissue (occurrences SP > RS)", x = "Tissue", y = "Number of eQTLs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability
dev.off()

png("/home/yuri/liri/puzzle/comp_allele_freq/n_eqtls_tissue_freq.png", width = 3800, height = 1080, res = 250)
ggplot(n_eqtls_tissue_freq, aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "#B3FFB3") +
  theme_minimal() +
  labs(title = "Number of eQTLs per tissue (frequency differences)", x = "Tissue", y = "Number of eQTLs") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability
dev.off()

