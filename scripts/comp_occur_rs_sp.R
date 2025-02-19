# Load required libraries
library(dplyr)
library(tidyr)

occur_dir <- "/home/yuri/liri/puzzle/comp_occur/all/3dp/"


diff_all_chr <- c()
pos_all <- c()
chr_all <- c()
rsids_all <- c()

# Define the loop over chromosomes
for (chr in 1:22) {
  #Data processing
  ## NAT RS
  freqs_rs <- paste0("/home/yuri/liri/puzzle_sdumont/rs/nat/chr_info_unfilt/count_info/freqs_chr_", chr, "_nat_rs.txt") 
  count_nat_rs <- read.table(freqs_rs, h=F)
  count_nat_rs <- count_nat_rs[order(count_nat_rs[,3]),]
  count_nat_rs <- count_nat_rs[,c(1, 2,3,6)]
  count_nat_rs <- count_nat_rs[!duplicated(count_nat_rs),]
  colnames(count_nat_rs) <- c("rsid", "chrom","bp", "score")
  count_nat_rs$chrom <- paste("chr", count_nat_rs$chrom, sep='')
  count_nat_rs$end <- c(count_nat_rs$bp[2:length(count_nat_rs$bp)] - 1, count_nat_rs$bp[length(count_nat_rs$bp)] + 1)
  count_nat_rs <- count_nat_rs[,c(1,2,3,5,4)]
  count_nat_rs$score <- count_nat_rs$score*0.116
  colnames(count_nat_rs) <- c("rsid", "chrom", "start", "end", "score")
  
  ## NAT SP
  freqs_sp <- paste0("/home/yuri/liri/puzzle_sdumont/sp/nat/chr_info_unfilt/count_info/freqs_chr_", chr, "_nat_sp.txt") 
  count_nat_sp <- read.table(freqs_sp, h=F)
  count_nat_sp <- count_nat_sp[order(count_nat_sp[,3]),]
  count_nat_sp <- count_nat_sp[,c(1,2,3,6)]
  count_nat_sp <- count_nat_sp[!duplicated(count_nat_sp),]
  colnames(count_nat_sp) <- c("rsid", "chrom","bp", "score")
  count_nat_sp$chrom <- paste("chr", count_nat_sp$chrom, sep='')
  count_nat_sp$end <- c(count_nat_sp$bp[2:length(count_nat_sp$bp)] - 1, count_nat_sp$bp[length(count_nat_sp$bp)] + 1)
  count_nat_sp <- count_nat_sp[,c(1,2,3,5,4)]
  count_nat_sp$score <- count_nat_sp$score*0.156
  colnames(count_nat_sp) <- c("rsid", "chrom", "start", "end", "score")
  
  ## Check position indexing
  if (sum(count_nat_rs$start - count_nat_sp$start) != 0) {
    ### Find indices of the missing rows in count_nat_sp and count_nat_rs
    missing_in_rs_indices <- which(!(count_nat_sp$start %in% count_nat_rs$start)) # Indices of rows in count_nat_sp not in count_nat_rs
    missing_in_sp_indices <- which(!(count_nat_rs$start %in% count_nat_sp$start)) # Indices of rows in count_nat_rs not in count_nat_sp
    
    ### Add missing rows from count_nat_sp to count_nat_rs
    if (length(missing_in_rs_indices) > 0) {
      missing_rows_rs <- count_nat_sp[missing_in_rs_indices, ]
      missing_rows_rs$score <- 0 # Set score to 0 for missing rows
      count_nat_rs <- rbind(count_nat_rs, missing_rows_rs)
    }
    
    ### Add missing rows from count_nat_rs to count_nat_sp
    if (length(missing_in_sp_indices) > 0) {
      missing_rows_sp <- count_nat_rs[missing_in_sp_indices, ]
      missing_rows_sp$score <- 0 # Set score to 0 for missing rows
      count_nat_sp <- rbind(count_nat_sp, missing_rows_sp)
    }
    
    
    ### Ensure both data frames are sorted by position (start)
    count_nat_rs <- count_nat_rs[order(count_nat_rs$start), ]
    count_nat_sp <- count_nat_sp[order(count_nat_sp$start), ]
    
    ### Recalculate positions and ranges
    pos <- count_nat_rs$start # Positions (after ensuring consistency)
    pos_mb <- pos / 1e6       # Positions in Mb
    
    ### Minimum and maximum scores
    min_occur <- min(c(count_nat_rs$score, count_nat_sp$score))
    max_occur <- max(c(count_nat_rs$score, count_nat_sp$score))
    
  } else {
    pos <- count_nat_rs$start
    pos_mb <- pos / 1e6
    min_occur <- min(c(count_nat_rs$score, count_nat_sp$score))
    max_occur <- max(c(count_nat_rs$score, count_nat_sp$score))
  }
  
  chr_save <- rep(chr, length(pos))
  chr_all <- c(chr_all, chr_save)
  
  pos_all <- c(pos_all, pos)
  rsids <- count_nat_rs$rsid
  rsids_all <- c(rsids_all, rsids)
  occur_rs <- (count_nat_rs$score)
  occur_sp <- (count_nat_sp$score)
  
  ### Differences between states 
  diff <- occur_rs - occur_sp
  diff_all_chr <- c(diff_all_chr, diff)
  
  # Detect differences

  diff_mean <- mean(diff)
  diff_sd <- sd(diff)
  
  plot_data_chr <- list(
    pos_mb = pos_mb,
    occur_rs = occur_rs,
    occur_sp = occur_sp,
    chr = chr,
    col_rs = 'blue',
    col_sp = 'red',
    ylab = "Weighted occurrences",
    xlab = paste("chr ", chr, " (Mb)"),
    ylim = c(0, max(occur_rs, occur_sp) + 5),
    xaxt = "n",
    bty = "n",
    legend_pos = "top",
    legend_labels = c("RS", "SP"),
    legend_fill = c("blue", "red"),
    axis_x_values = c(1, seq(20, max(pos_mb) + 20, by = 20)),
    axis_x_labels = c(1, seq(20, max(pos_mb) + 20, by = 20))
  )
  
  assign(paste0("plot_data_chr_", chr), plot_data_chr)
}  

## All chrs

diff_mean_all_chr <- mean(diff_all_chr)
diff_sd_all_chr <- sd(diff_all_chr)
different_all_chr <- abs(diff_all_chr - diff_mean_all_chr) > 3 * diff_sd_all_chr
different_all_chr <- as.numeric(different_all_chr)
diff_sp_gt_rs_all_chr <- which(diff_all_chr < 0 & different_all_chr == 1)
diff_rs_gt_sp_all_chr <- which(diff_all_chr > 0 & different_all_chr == 1)

diff_pos_sp_gt_rs_all_chr <- pos_all[diff_sp_gt_rs_all_chr]
diff_pos_rs_gt_sp_all_chr <- pos_all[diff_rs_gt_sp_all_chr]
diff_pos_all_chr <- pos_all[as.logical(different_all_chr)]

diff_snp_sp_gt_rs_all_chr <- rsids_all[diff_sp_gt_rs_all_chr]
diff_snp_rs_gt_sp_all_chr <- rsids_all[diff_rs_gt_sp_all_chr]
diff_snp_all_chr <- rsids_all[as.logical(different_all_chr)]

diff_chr_sp_gt_rs_all_chr <- chr_all[diff_sp_gt_rs_all_chr]
diff_chr_rs_gt_sp_all_chr <- chr_all[diff_rs_gt_sp_all_chr]
diff_chr_all_chr <- chr_all[as.logical(different_all_chr)]


all_chr_rs_gt_sp_pos <- data.frame(
  chr = diff_chr_rs_gt_sp_all_chr,
  position = diff_pos_rs_gt_sp_all_chr,
  rsid = diff_snp_rs_gt_sp_all_chr
)

all_chr_sp_gt_rs_pos <- data.frame(
  chr = diff_chr_sp_gt_rs_all_chr,
  position = diff_pos_sp_gt_rs_all_chr,
  rsid = diff_snp_sp_gt_rs_all_chr
)

all_chr_diff_pos <- data.frame(
  chr = diff_chr_all_chr,
  position = diff_pos_all_chr,
  rsid = diff_snp_all_chr
)

write.csv(all_chr_diff_pos, paste0(occur_dir, "different_all_chr.csv"), row.names = FALSE, quote = FALSE)
write.csv(all_chr_rs_gt_sp_pos, paste0(occur_dir, "diff_rs_gt_sp_all_chr.csv"), row.names = FALSE, quote = FALSE)
write.csv(all_chr_sp_gt_rs_pos, paste0(occur_dir, "diff_sp_gt_rs_all_chr.csv"), row.names = FALSE, quote = FALSE)

chromosomes_with_differences <- unique(all_chr_diff_pos$chr)
is_different_all_chr <- data.frame(chr_all, different_all_chr) 
  

for (chr in chromosomes_with_differences) {
  # Obtain differing_positions vector
  is_different_chr <- subset(is_different_all_chr, chr_all == chr)
  is_different <- is_different_chr$different_all_chr
  # Construct the variable name for the stored plot data
  plot_data_var <- paste0("plot_data_chr_", chr)
  
  # Ensure the plot data exists
  if (exists(plot_data_var, envir = .GlobalEnv)) {
    # Retrieve the stored plot data
    plot_data <- get(plot_data_var, envir = .GlobalEnv)
    
    scaling_factor <- max(c(plot_data$occur_rs, plot_data$occur_sp)) 
    png(paste0(saving_dir, "chr_", chr, "_rs_sp_all", ".png"), width = 2400, height = 1800, res = 300)
    # First, draw the black and green lines (so they appear behind)
    plot(plot_data$pos_mb, is_different * scaling_factor, type = 'l', col = 'darkgray',
         ylab = "Occurrences", xlab = paste("chr ", chr, " (Mb)"), bty = "n", xaxt = "n", ylim = c(0, max(plot_data$occur_rs, plot_data$occur_sp) + 5))
    # Then, draw the blue and red lines
    lines(plot_data$pos_mb, plot_data$occur_rs, col = 'blue')
    lines(plot_data$pos_mb, plot_data$occur_sp, col = 'red')
    
    # Add legend and axis as usual
    legend(x = "top", legend = c("RS", "SP", "Different"), fill = c("blue", "red", "darkgray"), ncol = 3, bty = "n")
    x_values <- c(1, seq(20, max(plot_data$pos_mb) + 20, by = 20))
    x_labels <- x_values
    axis(1, at = x_values, labels = x_labels)
    dev.off()
  }
}
  