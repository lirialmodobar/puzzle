library(dplyr)
unfilt_frags_dir <- "/home/yuri/liri/puzzle_sdumont/rs/nat/chr_info_unfilt"
setwd(unfilt_frags_dir)
files <- list.files(unfilt_frags_dir, full.names = TRUE)
files <- files[1:22] #removing dirs and files that are not unfilt frags
files <- lapply(files, read.table, header = FALSE)
frag_sizes <- lapply(files, select, 5)
mode <- function(x) {mode <- rownames(as.data.frame((which(table(x) == max(table(x)))))); return(mode)}
modes <- lapply(frag_sizes, mode)
mean_modes <- function(x) {if(length(x) > 1) {x = sum(as.numeric(x[1]),as.numeric(x[2])/length(x))} else {x = x}} #only valid if max length == 2, which is my case
cutoff_length <- sapply(modes, mean_modes)
cutoff_length <- round(as.numeric(cutoff_length), 0)
write.table(cutoff_length, paste0(unfilt_frags_dir, "/cutoff_length_rs.txt"), row.names = FALSE, quote = FALSE)



