library(dplyr)
library(rtracklayer)
library(fuzzyjoin)
library(tidyr)
setwd("/home/yuri/liri/puzzle")

##Data import
rs <- read.table("freqs_chr_1_nat_rs.txt", sep = "\t")
colnames(rs) <- c("SNP", "CHR", "BP", "allele", "count_rs", "total_rs", "freq_rs")
sp <- read.table("freqs_chr_1_nat_sp.txt", sep = "\t")

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

## Diff analysis
sd_2_rssp_diff <- 2*round(sd(rssp_comm$allele_freq_diff_rssp$freq.rsvars), digits = 2)
outliersvars_high_diff <- subset(rssp_comm, rssp_comm[[5]] > sd_2_rssp_diff)
outliersvars_high_diff_5 <- as.data.frame(outliersvars_high_diff$allele_freq_diff_rssp$freq.rsvars)
outliersvars_high_diff <- cbind(outliersvars_high_diff, outliersvars_high_diff_5)
outliersvars_high_diff <- outliersvars_high_diff[, c(1,2,3,4,6)]
smallest_high_diff <- min(outliersvars_high_diff[[5]])

## FUMA

fuma <- inner_join(rs, outliersvars_high_diff, by =  c("SNP" = "var", "allele"))
fuma <- fuma %>%
  mutate(SNP = paste(CHR, BP, sep = ":"))
fuma <- fuma[, c(1,2,3,4,7)]

subset_not_50 <- subset(fuma, fuma[[5]] != 50)
subset_50_even <- subset(fuma, fuma[[5]] == 50 & (1:nrow(fuma)) %% 2 == 0)
subset_50_odd <- subset(fuma, fuma[[5]] == 50 & (1:nrow(fuma)) %% 2 == 1)

fuma_a1 <-subset_not_50 %>%
  group_by(SNP, CHR, BP) %>%
  slice_max(order_by = freq_rs) %>%
  ungroup()
fuma_a1 <- rbind(fuma_a1, subset_50_even)
fuma_a2 <-subset_not_50 %>%
  group_by(SNP, CHR, BP) %>%
  slice_min(order_by = freq_rs) %>%
  ungroup()
fuma_a2 <- rbind(fuma_a2, subset_50_odd)
colnames(fuma_a1) <- c("SNP", "CHR", "BP", "A2", "freq_A2")
colnames(fuma_a2) <- c("SNP", "CHR", "BP", "A1", "freq_A1")
fuma <- inner_join(fuma_a1, fuma_a2, by = c("SNP", "CHR", "BP"))
fuma <- fuma[,c(1,2,3,6,4)]


## Just found out allele is not mandatory, so to prevent any mistakes:


## Add other columns
fuma <- fuma %>%
  mutate(P = runif(n(), min = 0.00000000001, max = 0.00000000005))
write.table(fuma, "fuma.tsv", row.names = FALSE)


##For liftover

fuma_liftover <- fuma[,c(2,3)]
liftover_add_bp <- fuma_liftover %>%
  mutate(BP2 = BP+1)
liftover_ordered <- liftover_add_bp[, c(2,3,5,1)]
liftover_ordered$CHR <- paste("chr", liftover$CHR, sep = "")
write.table(liftover_ordered, "liftover.bed", row.names = FALSE, quote = FALSE)

## Correct positions for hg19 and add rest of the columns

hg19 <- read.table("/home/yuri/Downloads/hglft_genome_2dd54_110710.bed")
hg19 <- hg19[,c(5,2,4)]
fuma_hg19 <- inner_join(fuma, hg19, by = c("SNP" = "V4"))
fuma_hg19 <- fuma_hg19[,c(2,8,3,4,5)]
fuma_hg19 <- fuma_hg19 %>%
  mutate(OR = runif(n(), min = -10, max = 10))
fuma_hg19 <- fuma_hg19 %>%
  mutate(Beta = runif(n(), min = -1, max = 1))
fuma_hg19 <- fuma_hg19 %>%
  mutate(SE = runif(n(), min = 2, max = 15))
colnames(fuma_hg19) <- c("CHR", "BP", "P", "A1", "A2", "OR", "Beta", "SE" )
write.table(fuma_hg19, "fuma_hg19.tsv", row.names = FALSE)

## For vep
vep <- fuma[-1]
vep <- vep %>% mutate(BP2 = BP)
vep <- vep %>% mutate(strand = 1)
vep <- vep %>% mutate(allele = paste(A2, A1, sep="/"))
vep <- vep[, c(1,2,6,8,7)]
write.table(vep,"vep.tsv", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")


##GTF


##VEP coding, largest frag

vep_coding <- read.table("vep_allele_right_prot_coding.txt")
vep_coding <- vep_coding %>% 
  separate(V2, into = c("chr", "pos"), sep = ":")
vep_coding <- vep_coding %>% 
  separate(pos, into = c("start", "end"), sep = "-")
vep_coding$chr <- as.integer(vep_coding$chr)
vep_coding$start <- as.integer(vep_coding$start)
vep_coding$end <- as.integer(vep_coding$end)
largest_pa_sp <- read.table("largest_pa_sp.txt")
colnames(largest_pa_sp) <- c("chr", "start", "end", "id")
vep_coding_largest <- genome_inner_join(largest_pa_sp, vep_coding, by =  c("chr", "start", "end" ))
write.table(vep_coding_largest, "vep_coding_largest.tsv", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")


### Counts and graphical representation

library(ggplot2)
library(gridExtra)

# Data preparation
variant_data <- data.frame(
  Category = factor(c("Total Variants", "Largest NAT tract (PA)", "Overlap of SP and PA", "Exclusive to PA"),
                    levels = c("Total Variants", "Largest NAT tract (PA)", "Overlap of SP and PA", "Exclusive to PA")),
  Count = c(2392, 1390, 1031, 359)
)

gene_data <- data.frame(
  Category = factor(c("Total Genes", "Largest NAT tract (PA)", "Overlap of SP and PA", "Exclusive to PA"),
                    levels = c("Total Genes", "Largest NAT tract (PA)", "Overlap of SP and PA", "Exclusive to PA")),
  Count = c(865, 555, 415, 140)  # Adjusted last number to fit the sum
)

# Define color palettes
variant_colors <- c("#FFB3BA", "#FFDFBA", "#FFFFBA", "#BAFFC9")  # Pastel warm
gene_colors <- c("#A3C1DA", "#D0E3CC", "#B0E0E6", "#D7BCE8")  # Diverse cold pastels

# Bar plot for variants
variant_plot <- ggplot(variant_data, aes(x = Category, y = Count, fill = Category)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Variants with high difference and protein coding transcripts", y = "Number of Variants", x = NULL) +
  scale_fill_manual(values = variant_colors) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

# Bar plot for genes
gene_plot <- ggplot(gene_data, aes(x = Category, y = Count, fill = Category)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Genes affected by those variants", y = "Number of Genes", x = NULL) +
  scale_fill_manual(values = gene_colors) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none")

# Combine the plots using gridExtra
combined_plot <- grid.arrange(variant_plot, gene_plot, ncol = 1, heights = c(1, 1))

# Display the combined plot
print(combined_plot)
