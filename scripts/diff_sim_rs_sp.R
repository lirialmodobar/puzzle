# Install required packages if not already installed
#install.packages("biomaRt")
#install.packages("GenomicRanges")
## Install Bioconductor if you don't have it installed
#if (!requireNamespace("BiocManager", quietly = TRUE)) {
 # install.packages("BiocManager")
#}
## Install clusterProfiler and KEGGREST from Bioconductor
#BiocManager::install("clusterProfiler")
#install.packages("org.Hs.eg.db")
#install.packages("enrichplot")
#BiocManager::install("KEGGREST")

# Load required libraries
library(signal)
library(biomaRt)
library(GenomicRanges)
library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(KEGGREST)

detect_ZeroCrossing <- function(signal, movwin_length, z){
# detect_ZeroCrossing detecta os pontos de um sinal onde houve cruzamento por 
# zero. Ao passar a diferença de dois sinais como sinal, serve como detecção de
# de cruzamento.
# Input
#   signal: vetor com o sinal a ser processado
#   movwin_length: tamanho da janela a ser usada para a média móvel de suavização.
#   z: estatística Z relativa ao nível de confiança desejado. Por exemplo,
#      z = 1.96 indica um nível de confiança de 95%. A base é a curva Normal mesmo.
# Output: 
#   signal_similar: um vetor com 0's em regiões sem zero-crossing e 1's onde há zero-crossing.

  signal_filtered <- stats::filter(signal, rep(1/movwin_length, movwin_length), sides = 2)
  thresh <- z*sd((signal-signal_filtered),na.rm = TRUE)/sqrt(movwin_length)
  signal_similar <- as.numeric(abs(signal_filtered) < thresh)
  return(signal_similar)
}

organize_enrichment_results <- function(enrichResult)  {
  #Filters for significant results adjusted by multiple comparisions
  #Orders by gene ratio and then p.adjust
  
  ###Filter for significant results 
  
  results_df <- enrichResult@result
  results_significant <-results_df[results_df$p.adjust < 0.05,]
  
  ###Order by p.adjust and gene ratio
  if (!is.null(results_significant) && nrow(results_significant) != 0) {
  #### Split the GeneRatio values by the '/' character
  gene_ratio_parts <- strsplit(results_significant$GeneRatio, "/")
  
  #### Perform the division and store the results
  results_significant$GeneRatio <- sapply(gene_ratio_parts, function(x) as.numeric(x[1]) / as.numeric(x[2]))
  
  #### Now order by p.adjust (ascending) and then GeneRatio (descending) 
  results_significant <- results_significant[order(results_significant$p.adjust, -results_significant$GeneRatio), ]
  return(results_significant)
  }
}

# Define the loop over chromosomes
for (chr in 1:2) {
  #Data processing
  ## NAT RS
  freqs_rs <- paste0("/home/yuri/liri/puzzle_sdumont/rs/nat/chr_info_unfilt/count_info/freqs_chr_", chr, "_nat_rs.txt") 
  count_nat_rs <- read.table(freqs_rs, h=F)
  count_nat_rs <- count_nat_rs[order(count_nat_rs[,3]),]
  count_nat_rs <- count_nat_rs[,c(2,3,6)]
  count_nat_rs <- count_nat_rs[!duplicated(count_nat_rs),]
  colnames(count_nat_rs) <- c("chrom","bp", "score")
  count_nat_rs$chrom <- paste("chr", count_nat_rs$chrom, sep='')
  count_nat_rs$end <- c(count_nat_rs$bp[2:length(count_nat_rs$bp)] - 1, count_nat_rs$bp[length(count_nat_rs$bp)] + 1)
  count_nat_rs <- count_nat_rs[,c(1,2,4,3)]
  colnames(count_nat_rs) <- c("chrom", "start", "end", "score")
  
  ## NAT SP
  freqs_sp <- paste0("/home/yuri/liri/puzzle_sdumont/sp/nat/chr_info_unfilt/count_info/freqs_chr_", chr, "_nat_sp.txt") 
  count_nat_sp <- read.table(freqs_sp, h=F)
  count_nat_sp <- count_nat_sp[order(count_nat_sp[,3]),]
  count_nat_sp <- count_nat_sp[,c(2,3,6)]
  count_nat_sp <- count_nat_sp[!duplicated(count_nat_sp),]
  colnames(count_nat_sp) <- c("chrom","bp", "score")
  count_nat_sp$chrom <- paste("chr", count_nat_sp$chrom, sep='')
  count_nat_sp$end <- c(count_nat_sp$bp[2:length(count_nat_sp$bp)] - 1, count_nat_sp$bp[length(count_nat_sp$bp)] + 1)
  count_nat_sp <- count_nat_sp[,c(1,2,4,3)]
  colnames(count_nat_sp) <- c("chrom", "start", "end", "score")
  
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
  
  
  ### Normalizing occurrences to the range [0, 1] to ensures comparability despite differences in raw  magnitudes.
  occur_rs <- (count_nat_rs$score - min(count_nat_rs$score)) / max(count_nat_rs$score - min(count_nat_rs$score))
  occur_sp <- (count_nat_sp$score - min(count_nat_sp$score)) / max(count_nat_sp$score - min(count_nat_sp$score))
  
  ### Differences between states 
  diff <- occur_rs - occur_sp
  
  # Detect crossings and differences
  nwin <- round(sqrt(length(occur_rs)))
  if (nwin %% 2 == 0) {nwin <- nwin + 1}
  similar <- detect_ZeroCrossing(diff, nwin, z = 1.96)
  similar[is.na(similar)] <- 0
  diff_mean <- mean(diff)
  diff_sd <- sd(diff)
  different <- abs(diff - diff_mean) > 2 * diff_sd
  different <- as.numeric(different)
  
  # Plot crossings and differences
  saving_dir <- "/home/yuri/liri/puzzle/"
  png(paste0(saving_dir, "chr_", chr, "_rs_sp", ".png"), width = 2400, height = 1800, res = 300)
  plot(pos_mb, occur_rs, type = 'l', col = 'blue', ylim = c(-0.1, 1.4),
       ylab = "Occurrences", xlab = paste("chr ", chr, " (Mb)"), bty = "n", xaxt = "n")
  lines(pos_mb, occur_sp, col = 'red')
  lines(pos_mb, different, col = 'black')
  lines(pos_mb, similar, col = "green")
  legend(x = "top", legend = c("RS", "SP", "Similar", "Different"), fill = c("blue", "red", "green", "black"), ncol = 4, bty = "n")
  x_values <- c(1, seq(20, max(pos_mb) + 20, by = 20))
  x_labels <- x_values
  axis(1, at = x_values, labels = x_labels)
  dev.off()
  
  # Save similar and different positions
  similar_pos <-pos[as.logical(similar)]
  similar_pos_df <- as.data.frame(similar_pos)
  write.csv(similar_pos_df, paste0("similar_positions_", chr, ".csv"), row.names = FALSE, quote = FALSE)
  diff_pos <- pos[as.logical(different)]
  diff_pos_df <- as.data.frame(diff_pos)
  write.csv(diff_pos_df, paste0("different_positions_", chr, ".csv"), row.names = FALSE, quote = FALSE)
  comparisions <- c("similar", "different")
  
  #Enrichment analysis for similar and different positions
  ## Retrieve gene information (chromosome, start, end positions, gene names)
  
  ensembl = useMart("ensembl", dataset = "hsapiens_gene_ensembl")
  
  gene_gr <- getBM(
    attributes = c("ensembl_gene_id", "external_gene_name", "chromosome_name", "start_position", "end_position"),
    filters = "chromosome_name",
    values = chr,
    mart = ensembl
  )
  
  ## Convert gene information into GenomicRanges object
  gene_gr <- GRanges(
    seqnames = gene_gr$chromosome_name,
    ranges = IRanges(start = gene_gr$start_position, end = gene_gr$end_position),
    gene_id = gene_gr$ensembl_gene_id,
    gene_name = gene_gr$external_gene_name
  )
  if (!is.null(similar_pos) && !(is.null(diff_pos)) && length(diff_pos) != 0 && length(similar_pos) != 0) {
  for (comp in comparisions) {
    if(comp == "similar") {
    ## Create GenomicRanges object for the SNVs
    snv_gr <- GRanges(
      seqnames = chr,  # Single chromosome (e.g., "1")
      ranges = IRanges(
        start = similar_pos,  # SNV positions
        end = similar_pos  # Same position for the end
      )
    )
    } else {
      snv_gr <- GRanges(
        seqnames = chr,  # Single chromosome (e.g., "1")
        ranges = IRanges(
          start = diff_pos,  # SNV positions
          end = diff_pos  # Same position for the end
        )
      ) 
    }
    
    
    ## Find Genes Overlapping SNVs
    overlap_genes <- findOverlaps(snv_gr, gene_gr)
    overlap_gene_indices <- subjectHits(overlap_genes)
    overlap_gene_names <- gene_gr$gene_name[overlap_gene_indices]
    overlap_gene_ensembl_id <- gene_gr$gene_id[overlap_gene_indices]
    overlap_gene_data <- DataFrame(
      gene_name = overlap_gene_names,
      ensembl_id = overlap_gene_ensembl_id
    )
    gene_info <- ifelse(is.na(overlap_gene_names) | overlap_gene_names == "", 
                        overlap_gene_ensembl_id, 
                        overlap_gene_names)
    
    if(!is.null(gene_info) && length(gene_info) != 0) {
    ## Get the list of gene names from the overlaps
    genes_list_go <- unique(gene_info)  # Remove duplicates
    
    ## Convert to ENTREZ ids (necessary for KEGG enrichment)
    
    entrez_mapping <- select(org.Hs.eg.db, keys = overlap_gene_data$ensembl_id, columns = c("ENSEMBL", "ENTREZID"), keytype = "ENSEMBL")
    entrez_ids <- unique(entrez_mapping$ENTREZID)
    
    ##Perform Pathway Enrichment Analysis (GO/KEGG)
    
    ### Perform Gene Ontology (GO) enrichment analysis
    go_results <- enrichGO(
      gene = genes_list_go,
      OrgDb = org.Hs.eg.db,  # Human genome annotations
      keyType = "SYMBOL",  # Or use "ENSEMBL" depending on your input
      ont = "BP",  # Biological process; change to "MF" or "CC" for molecular function or cellular component
      pvalueCutoff = 0.05
    )
    
    go_results_df <- organize_enrichment_results(go_results)
    print(head(go_results_df))
    go_results_file <- paste0("go_results_", chr, "_", comp)
    if(!is.null(go_results_df)) {
      write.csv(go_results_df, paste0(go_results_file, ".csv"), quote = FALSE, row.names = FALSE)
    
    ##Visualize the enrichment results
    title_go <- paste0("Top enriched GO terms for ", comp, " regions in chr ", chr)
    ### Bar plot for GO enrichment results
    png(paste0(saving_dir, "barplot_", go_results_file, ".png"), width = 1920, height = 1080, res = 150)
    print(barplot(go_results, showCategory = 10, title = title_go))  # Top 20 enriched GO terms
    dev.off()
    
    ### Dot plot for GO enrichment results
    png(paste0(saving_dir, "dotplot_", go_results_file, ".png"), width = 1920, height = 1080, res = 150)
    print(dotplot(go_results, showCategory = 10, title = title_go))
    dev.off()
    } else {
      print(paste0("No significant results for comp ", comp, " and chr ", chr))
    }
    
    ### Perform KEGG pathway enrichment analysis
    if(!is.null(entrez_ids) && length(entrez_ids) != 0) {
    kegg_results <- enrichKEGG(
      gene = entrez_ids,
      organism = "hsa",  # KEGG code for human
      pvalueCutoff = 0.05
    )
    
    kegg_results_df <- organize_enrichment_results(kegg_results)
    kegg_results_file <- paste0("kegg_results_", chr, "_", comp)
    if(!is.null(kegg_results_df)) {
      write.csv(kegg_results_df, paste0(kegg_results_file, ".csv"), quote = FALSE, row.names = FALSE)
    ##Visualize the enrichment results
    
    title_kegg <- paste0("Enriched KEGG pathways for ", comp, " regions in chr ", chr)
    
    
    ### Bar plot for KEGG pathway enrichment results
    png(paste0(saving_dir, "barplot_", kegg_results_file, ".png"), width = 1920, height = 1080, res = 150)
    print(barplot(kegg_results, showCategory = 10, title = title_kegg))  # Top 20 enriched KEGG pathways
    dev.off()
    ### Dot plot for KEGG enrichment results
    png(paste0(saving_dir, "dotplot_", kegg_results_file, ".png"), width = 1920, height = 1080, res = 150)
    print(dotplot(kegg_results, showCategory = 10, title = title_kegg))
    dev.off()
    } else {
      print(paste0("No significant results for comp ", comp, " and chr ", chr))
    }
    }
    else {
      print(paste0("No entrez ids for chr ", chr, " comp ", comp))
    } 
    } else {
      print(paste0("No overlapping genes for chr ", chr, " comp ", comp))
    } 
  }
  } 
} 

#Extra

#Plot only different
plot(pos,occur_rs,type='l',col='blue', ylim = c(-0.1,1.1),
     ylab="Frequência Relativa", xlab = "Posição Genômica")
lines(pos,occur_sp,col='red')
lines(pos,different,col='black') 
legend(x="topright", legend = c("RS","SP","differences"), fill = c("blue","red","black"))

#Plot only similar

plot(pos_mb,occur_rs,type='l',col='blue', ylim = c(-0.1,1.4),
     ylab="Occurrences", xlab = "chr 1 (Mb)", bty="n")
lines(pos_mb,occur_sp,col='red')
lines(pos_mb,similar,col='green')
legend(x="top", legend = c("RS","SP","Similar positions"),fill = c("blue","red","green"), bty = "n", ncol = 3) #ajeitar legenda







