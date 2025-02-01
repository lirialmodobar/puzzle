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
library(AnnotationDbi)
library(DOSE)


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
  if (!is.null(enrichResult@result)) {
    results_df <- enrichResult@result
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
  } else {
    print("no results")
  } 
} 
#Initializing df to save data from all chrs
diff_rs_gt_sp_all <- data.frame(chr = integer(), pos = integer())
diff_sp_gt_rs_all <- data.frame(chr = integer(), pos = integer())
similar_pos_all <-  data.frame(chr = integer(), pos = integer())
diff_pos_all <- data.frame(chr = integer(), pos = integer())

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
  
  rsids <- count_nat_rs$rsid
  occur_rs <- (count_nat_rs$score)
  occur_sp <- (count_nat_sp$score)

  ### Differences between states 
  diff <- occur_rs - occur_sp
  
  
  # Detect crossings and differences
  nwin <- round(sqrt(length(occur_rs)))
  if (nwin %% 2 == 0) {nwin <- nwin + 1}
  similar <- detect_ZeroCrossing(diff, nwin, z = 1.96)
  similar[is.na(similar)] <- 0
  diff_mean <- mean(diff)
  diff_sd <- sd(diff)
  different <- abs(diff - diff_mean) > 3 * diff_sd
  different <- as.numeric(different)
  diff_sp_gt_rs <- which(diff < 0 & different == 1)
  diff_rs_gt_sp <- which(diff > 0 & different == 1)
  
  # Plot crossings and differences
  saving_dir <- "/home/yuri/liri/puzzle/"
  scaling_factor <- max(c(occur_rs, occur_sp)) / max(c(different, similar))
  png(paste0(saving_dir, "chr_", chr, "_rs_sp", ".png"), width = 2400, height = 1800, res = 300)
  # First, draw the black and green lines (so they appear behind)
  plot(pos_mb, different * scaling_factor, type = 'l', col = 'darkgray',
       ylab = "Occurrences", xlab = paste("chr ", chr, " (Mb)"), bty = "n", xaxt = "n", ylim = c(0, max(occur_rs, occur_sp) + 5))
  lines(pos_mb, similar * scaling_factor, col = "green")
  
  # Then, draw the blue and red lines
  lines(pos_mb, occur_rs, col = 'blue')
  lines(pos_mb, occur_sp, col = 'red')
  
  # Add legend and axis as usual
  legend(x = "top", legend = c("RS", "SP", "Similar", "Different"), fill = c("blue", "red", "green", "darkgray"), ncol = 4, bty = "n")
  x_values <- c(1, seq(20, max(pos_mb) + 20, by = 20))
  x_labels <- x_values
  axis(1, at = x_values, labels = x_labels)
  
  dev.off()
  
  # Save similar and different positions
  diff_pos_sp_gt_rs <- pos[diff_sp_gt_rs]
  diff_pos_rs_gt_sp <- pos[diff_rs_gt_sp]
  diff_pos <- pos[as.logical(different)]
  similar_pos <-pos[as.logical(similar)]
  diff_snp_sp_gt_rs <- rsids[diff_sp_gt_rs]
  diff_snp_rs_gt_sp <- rsids[diff_rs_gt_sp]
  diff_snp <- rsids[as.logical(different)]
  similar_snp <- rsids[as.logical(similar)]
  
  
  # Combine all different positions into a data frame with the current chromosome
  # Only create the data frame if diff_pos_sp_gt_rs has entries
  if(length(diff_pos_sp_gt_rs) > 0) {
    chr_sp_gt_rs_pos <- data.frame(
      chr = chr,
      position = diff_pos_sp_gt_rs,
      rsid = diff_snp_sp_gt_rs
    )
    diff_sp_gt_rs_all <- rbind(diff_sp_gt_rs_all, chr_sp_gt_rs_pos)
  }
  
  # Only create the data frame if diff_pos_rs_gt_sp has entries
  if(length(diff_pos_rs_gt_sp) > 0) {
    chr_rs_gt_sp_pos <- data.frame(
      chr = chr,
      position = diff_pos_rs_gt_sp,
      rsid = diff_snp_rs_gt_sp
    )
    diff_rs_gt_sp_all <- rbind(diff_rs_gt_sp_all, chr_rs_gt_sp_pos)
  }
  
  # Only create the data frame if diff_pos has entries
  if(length(diff_pos) > 0) {
    chr_diff_pos <- data.frame(
      chr = chr,
      position = diff_pos,
      rsid = diff_snp
    )
    diff_pos_all <- rbind(diff_pos_all, chr_diff_pos)
  }
  
  # Only create the data frame if similar_pos has entries
  if(length(similar_pos) > 0) {
    chr_similar_pos <- data.frame(
      chr = chr,
      position = similar_pos,
      rsid = similar_snp
    )
    similar_pos_all <- rbind(similar_pos_all, chr_similar_pos)
  }
}  

write.csv(diff_pos_all, "different_positions_all.csv", row.names = FALSE, quote = FALSE)
write.csv(diff_rs_gt_sp_all, "diff_rs_gt_sp_all_pos.csv", row.names = FALSE, quote = FALSE)
write.csv(diff_sp_gt_rs_all, "diff_sp_gt_rs_all_pos.csv", row.names = FALSE, quote = FALSE)
write.csv(similar_pos_all,"similar_pos_all.csv", row.names = FALSE, quote = FALSE)

  #Enrichment analysis for similar and different positions
  ## Retrieve gene information (chromosome, start, end positions, gene names)
  comparisions <- c("similar positions", "different positions", "different positions (rs > sp)", "different positions (sp > rs)")

  ensembl = useMart("ensembl", dataset = "hsapiens_gene_ensembl")
  
  gene_gr <- getBM(
    attributes = c("ensembl_gene_id", "external_gene_name", "chromosome_name", "start_position", "end_position"),
    mart = ensembl
  )
  
  ## Convert gene information into GenomicRanges object
  gene_gr <- GRanges(
    seqnames = gene_gr$chromosome_name,
    ranges = IRanges(start = gene_gr$start_position, end = gene_gr$end_position),
    gene_id = gene_gr$ensembl_gene_id,
    gene_name = gene_gr$external_gene_name
  )
  for (comp in comparisions) {
    if(comp == "similar positions") {
    ## Create GenomicRanges object for the SNVs
    snv_gr <- GRanges(
      seqnames = similar_pos_all$chr, 
      ranges = IRanges(
        start = similar_pos_all$pos,  # SNV positions
        end = similar_pos_all$pos  # Same position for the end
      )
    )
    } else if (comp == "different positions") {
      snv_gr <- GRanges(
        seqnames = diff_pos_all$chr,  # Single chromosome (e.g., "1")
        ranges = IRanges(
          start = diff_pos_all$pos,  # SNV positions
          end = diff_pos_all$pos  # Same position for the end
        )
      ) 
    } else if (comp == "different positions (rs > sp)") {
      snv_gr <- GRanges(
        seqnames = diff_rs_gt_sp_all$chr,  # Single chromosome (e.g., "1")
        ranges = IRanges(
          start = diff_rs_gt_sp_all$pos ,  # SNV positions
          end = diff_rs_gt_sp_all$pos # Same position for the end
        )
      ) 
    } else if (comp == "different positions (sp > rs)") {
      snv_gr <- GRanges(
        seqnames = diff_sp_gt_rs_all$chr,  # Single chromosome (e.g., "1")
        ranges = IRanges(
          start = diff_sp_gt_rs_all$pos,  # SNV positions
          end = diff_sp_gt_rs_all$pos  # Same position for the end
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
    write.csv(genes_list_go, paste0("genes_", gsub(" ", "_", comp), ".csv"), quote = FALSE, row.names = FALSE)
    
    
    ## Convert to ENTREZ ids (necessary for KEGG enrichment)
    
    entrez_mapping <- AnnotationDbi::select(org.Hs.eg.db, keys = overlap_gene_data$ensembl_id, columns = c("ENSEMBL", "ENTREZID"), keytype = "ENSEMBL")
    entrez_ids <- unique(entrez_mapping$ENTREZID)
    write.csv(entrez_ids, paste0("genes_kegg_", gsub(" ", "_", comp), ".csv"), quote = FALSE, row.names = FALSE)
    
    
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
    go_results_file <- paste0("go_results_3dp_", gsub(" ", "_", comp))
    if(!is.null(go_results_df)) {
      write.csv(go_results_df, paste0(go_results_file, ".csv"), quote = FALSE, row.names = FALSE)
    
    ##Visualize the enrichment results
    title_go <- paste0("Top enriched GO terms for comp", comp)
    ### Bar plot for GO enrichment results
    png(paste0(saving_dir, "barplot_", go_results_file, ".png"), width = 1920, height = 1080, res = 115)
    print(barplot(go_results, showCategory = 10, title = title_go, x = "GeneRatio"))  # Top 20 enriched GO terms
    dev.off()
    
    ### Dot plot for GO enrichment results
    png(paste0(saving_dir, "dotplot_", go_results_file, ".png"), width = 1920, height = 1080, res = 150)
    print(dotplot(go_results, showCategory = 10, title = title_go, x = "GeneRatio", size = "Count"))
    dev.off()
    } else {
      print(paste0("GO: No significant results for comp ", comp))
    }
    
    ### Perform KEGG pathway enrichment analysis
    if(!is.null(entrez_ids) && length(entrez_ids) != 0) {
    kegg_results <- enrichKEGG(
      gene = entrez_ids,
      organism = "hsa",  # KEGG code for human
      pvalueCutoff = 0.05
    )
    
    kegg_results_df <- organize_enrichment_results(kegg_results)
    kegg_results_file <- paste0("kegg_results_3dp_", gsub(" ", "_", comp))
    if(!is.null(kegg_results_df)) {
      write.csv(kegg_results_df, paste0(kegg_results_file, ".csv"), quote = FALSE, row.names = FALSE)
    ##Visualize the enrichment results
    
    title_kegg <- paste0("Enriched KEGG pathways for ", comp)
    
    
    ### Bar plot for KEGG pathway enrichment results
    png(paste0(saving_dir, "barplot_", kegg_results_file, ".png"), width = 1920, height = 1080, res = 150)
    print(barplot(kegg_results, showCategory = 10, title = title_kegg, x = "GeneRatio"))  # Top 20 enriched KEGG pathways
    dev.off()
    ### Dot plot for KEGG enrichment results
    png(paste0(saving_dir, "dotplot_", kegg_results_file, ".png"), width = 1920, height = 1080, res = 150)
    print(dotplot(kegg_results, showCategory = 10, title = title_kegg, x = "GeneRatio", size = "Count"))
    dev.off()
    } else {
      print(paste0("KEGG: No significant results for comp ", comp))
    }
    }
    else {
      print(paste0("KEGG: No entrez ids for comp ", comp))
    } 
    } else {
      print(paste0("No overlapping genes for comp ", comp))
    } 
  }

  # Define SNP comparisons
  comparisions_snps <- c("similar positions snps", "different positions snps", 
                         "different positions snps (rs > sp)", "different positions snps (sp > rs)")
  
  for (comps in comparisions_snps) {
    # Select appropriate SNP data based on the comparison
    if (comps == "similar positions snps") {
      snv_ids <- similar_pos_all$rsid
    } else if (comps == "different positions snps") {
      print("oi")
      snv_ids <- diff_pos_all$rsid
    } else if (comps == "different positions snps (rs > sp)") {
      snv_ids <- diff_rs_gt_sp_all$rsid
    } else if (comps == "different positions snps (sp > rs)") {
      snv_ids <- diff_sp_gt_rs_all$rsid
    }
    
    # Ensure there are SNP IDs to process
    if (length(snv_ids) > 0) {
      # SNP Disease-Gene Network Visualization
        dgn_results <- enrichDGNv(snv_ids)
        
        # Save results
        if (!is.null(dgn_results)) {
          # Save as CSV
          snp_disease_file <- paste0("results_disease_3dp_", gsub(" ", "_", comps), ".csv")
          dgn_results_df <- organize_enrichment_results(dgn_results)
          write.csv(dgn_results_df, snp_disease_file, quote = FALSE, row.names = FALSE)
          
          # Create bar plot
          barplot_file <- paste0("barplot_disease_3dp_", gsub(" ", "_", comps), ".png")
          png(barplot_file, width = 1920, height = 1080, res = 150)
          print(barplot(
            dgn_results,
            title = paste0("SNP-Disease Bar Plot for comp ", comps),
            x = "GeneRatio", 
            showCategory = 10  # Number of categories to show
          ))
          dev.off()
          
          # Create dot plot
          dotplot_file <- paste0("dotplot_disease_3dp_", gsub(" ", "_", comps), ".png")
          png(dotplot_file, width = 1920, height = 1080, res = 150)
          print(dotplot(
            dgn_results,
            title = paste0("SNP-Disease Dot Plot for ", comps),
            x = "GeneRatio",
            size = "Count",
            showCategory = 10  # Number of categories to show
          ))
        } else {
          print(paste0("SNP-DGNV: No significant results for comp ", comps))
        }
    } else {
      print(paste0("No SNP IDs available for comp", comps))
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
