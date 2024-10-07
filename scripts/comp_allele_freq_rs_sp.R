library(dplyr)
library(rtracklayer)
library(fuzzyjoin)
library(tidyr)

##Data import
rs_dir <- "/home/yuri/liri/puzzle/rs/nat/chr_info_unfilt/count_info"
sp_dir <- "/home/yuri/liri/puzzle/sp/nat/chr_info_unfilt/count_info"
rs_file <- file.path(rs_dir, "freqs_chr_5_nat_rs.txt")
sp_file <- file.path(sp_dir, "freqs_chr_5_nat_sp.txt")
rs <- read.table(rs_file, sep = "\t")
colnames(rs) <- c("SNP", "CHR", "BP", "allele", "count_rs", "total_rs", "freq_rs") #not sure if i need that
sp <- read.table(sp_file, sep = "\t")

##Data exploration
rsvars <- rs[, c(1,4,7)]
spvars <- sp[, c(1,4,7)]
colnames(rsvars) <- c("var", "allele", "freq")
colnames(spvars) <- c("var", "allele", "freq")
rssp_comm <- inner_join(rsvars, spvars, by = c("var", "allele"), suffix = c(".rsvars", ".spvars"))
rssp_comm <- rssp_comm %>% mutate(allele_freq_diff_rssp = round(abs(.[3] - .[4]), digits = 2))
rssp_0 <- subset(rssp_comm, rssp_comm[[5]] == 0)
rssp_maior_0 <- subset(rssp_comm, rssp_comm[[5]] > 0)
rssp_maior_1 <- subset(rssp_comm, rssp_comm[[5]] >= 1)
smallest_diff <- min(rssp_maior_0[[5]])
smallest_non_0_diff <- min(rssp_maior_1[[5]])
rsvars_only <- anti_join(rsvars, spvars, by = c("var", "allele"))
spvars_only <- anti_join (spvars, rsvars, by = c("var", "allele"))
write.csv(rsvars_only, "rs_vars_only_5.csv", quote = FALSE, row.names = FALSE)
write.csv(spvars_only, "sp_vars_only_5.csv", quote = FALSE, row.names = FALSE)

## Diff analysis
sd_3_rssp_diff <- 3*round(sd(rssp_comm$allele_freq_diff_rssp$freq.rsvars), digits = 2)
outliersvars_high_diff <- subset(rssp_comm, rssp_comm[[5]] > sd_3_rssp_diff)
outliersvars_high_diff_5 <- as.data.frame(outliersvars_high_diff$allele_freq_diff_rssp$freq.rsvars)
outliersvars_high_diff <- cbind(outliersvars_high_diff, outliersvars_high_diff_5)
outliersvars_high_diff <- outliersvars_high_diff[, c(1,2,3,4,6)]
write.csv(outliersvars_high_diff, "vars_high_diff_chr5.csv", quote = FALSE, row.names = FALSE)

smallest_high_diff <- min(outliersvars_high_diff[[5]])

## VEP input

vep <- inner_join(rs, outliersvars_high_diff, by =  c("SNP" = "var", "allele"))
vep <- vep %>%
  mutate(SNP = paste(CHR, BP, sep = ":"))
vep <- fuma[, c(1,2,3,4,7)]

subset_not_50 <- subset(vep, vep[[5]] != 50)
subset_50_even <- subset(vep, vep[[5]] == 50 & (1:nrow(vep)) %% 2 == 0)
subset_50_odd <- subset(vep, vep[[5]] == 50 & (1:nrow(vep)) %% 2 == 1)

vep_a1 <-subset_not_50 %>%
  group_by(SNP, CHR, BP) %>%
  slice_max(order_by = freq_rs) %>%
  ungroup()
vep_a1 <- rbind(vep_a1, subset_50_even)
vep_a2 <-subset_not_50 %>%
  group_by(SNP, CHR, BP) %>%
  slice_min(order_by = freq_rs) %>%
  ungroup()
vep_a2 <- rbind(vep_a2, subset_50_odd)
colnames(vep_a1) <- c("SNP", "CHR", "BP", "A2", "freq_A2")
colnames(vep_a2) <- c("SNP", "CHR", "BP", "A1", "freq_A1")
vep <- inner_join(vep_a1, vep_a2, by = c("SNP", "CHR", "BP"))
vep <- vep[,c(1,2,3,6,4)]

vep <- vep[-1]
vep <- vep %>% 
  mutate(BP2 = BP, strand = 1, allele = paste(A2, A1, sep = "/")) %>%
 select(1, 2, 5, 7, 6) %>%
 arrange(CHR, BP)

write.table(vep, "vep_5.tsv", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")
