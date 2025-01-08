library(dplyr)
library(rtracklayer)
library(fuzzyjoin)
library(tidyr)

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

# Directories
rs_dir <- "/home/yuri/liri/puzzle_sdumont/rs/nat/chr_info_unfilt/count_info"
sp_dir <- "/home/yuri/liri/puzzle_sdumont/sp/nat/chr_info_unfilt/count_info"

# Initialize empty data frames to store results for all chromosomes
vep_combined <- data.frame()
diff_vars_combined <- data.frame()
rsvars_only_combined <- data.frame()
spvars_only_combined <- data.frame()

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
  
  # Extract variables of interest
  rsvars <- rs[, c("SNP", "allele", "freq_rs")]
  spvars <- sp[, c("SNP", "allele", "freq_sp")]
  
  colnames(rsvars) <- c("var", "allele", "freq")
  colnames(spvars) <- c("var", "allele", "freq")
  
  # Common variants and frequency difference
  rssp_comm <- inner_join(rsvars, spvars, by = c("var", "allele"), suffix = c(".rsvars", ".spvars"))
  rssp_comm <- rssp_comm %>%
    mutate(allele_freq_diff_rssp = round(abs(freq.rsvars - freq.spvars), digits = 2))
  
  diff_vars <- subset(rssp_comm, abs(allele_freq_diff_rssp - mean(allele_freq_diff_rssp)) > (3 * sd(allele_freq_diff_rssp)))
  
  # Append diff_vars to combined data frame
  diff_vars_combined <- bind_rows(diff_vars_combined, diff_vars)
  
  # Get rsvars_only and spvars_only
  rsvars_only <- anti_join(rsvars, spvars, by = c("var", "allele"))
  spvars_only <- anti_join(spvars, rsvars, by = c("var", "allele"))
  
  # Append to combined data frames
  rsvars_only_combined <- bind_rows(rsvars_only_combined, rsvars_only)
  spvars_only_combined <- bind_rows(spvars_only_combined, spvars_only)
  
  # VEP preparation
  vep <- inner_join(rs, diff_vars, by = c("SNP" = "var", "allele"))
  vep <- vep %>%
    mutate(SNP = paste(CHR, BP, sep = ":")) %>%
    select(SNP, CHR, BP, allele, freq_rs)
  
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
  
  colnames(vep_a1) <- c("SNP", "CHR", "BP", "A2", "freq_A2")
  colnames(vep_a2) <- c("SNP", "CHR", "BP", "A1", "freq_A1")
  
  vep_chr <- inner_join(vep_a1, vep_a2, by = c("SNP", "CHR", "BP")) %>%
    select(SNP, CHR, BP, A1, A2) %>%
    mutate(BP2 = BP, strand = 1, allele = paste(A2, A1, sep = "/")) %>%
    select(SNP, CHR, BP, BP2, strand, allele) %>%
    arrange(CHR, BP)
  
  # Append to combined VEP data frame
  vep_combined <- bind_rows(vep_combined, vep_chr)
}

# Write combined data frames to files
write.csv(diff_vars_combined, "diff_vars_combined.csv", row.names = FALSE, quote = FALSE)
write.csv(rsvars_only_combined, "rsvars_only_combined.csv", row.names = FALSE, quote = FALSE)
write.csv(spvars_only_combined, "spvars_only_combined.csv", row.names = FALSE, quote = FALSE)

# Write final combined VEP file
write.table(vep_combined, "vep_combined.tsv", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = "\t")


##Enrichment analysis

saving_dir <- "/home/yuri/liri/puzzle/"

### Retrieve gene information (chromosome, start, end positions, gene names)

ensembl = useMart("ensembl", dataset = "hsapiens_gene_ensembl", host = "https://asia.ensembl.org")

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
## Create GenomicRanges object for the SNVs
    snv_gr <- GRanges(
      seqnames = vep_combined$CHR, 
      ranges = IRanges(
        start = vep_combined$BP,  # SNV positions
        end = vep_combined$BP  # Same position for the end
      )
    )

  
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
    
    entrez_mapping <- AnnotationDbi::select(org.Hs.eg.db, keys = overlap_gene_data$ensembl_id, columns = c("ENSEMBL", "ENTREZID"), keytype = "ENSEMBL")
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
    go_results_file <- "go_results_allele_freq"
    if(!is.null(go_results_df)) {
      write.csv(go_results_df, paste0(go_results_file, ".csv"), quote = FALSE, row.names = FALSE)
      
      ##Visualize the enrichment results
      title_go <- paste0("Top enriched GO terms")
      ### Bar plot for GO enrichment results
      png(paste0(saving_dir, "barplot_", go_results_file, ".png"), width = 1920, height = 1080, res = 150)
      print(barplot(go_results, showCategory = 10, title = title_go))  # Top 20 enriched GO terms
      dev.off()
      
      ### Dot plot for GO enrichment results
      png(paste0(saving_dir, "dotplot_", go_results_file, ".png"), width = 1920, height = 1080, res = 150)
      print(dotplot(go_results, showCategory = 10, title = title_go))
      dev.off()
    } else {
      print(paste0("GO: No significant results"))
    }
    
    ### Perform KEGG pathway enrichment analysis
    if(!is.null(entrez_ids) && length(entrez_ids) != 0) {
      kegg_results <- enrichKEGG(
        gene = entrez_ids,
        organism = "hsa",  # KEGG code for human
        pvalueCutoff = 0.05
      )
      
      kegg_results_df <- organize_enrichment_results(kegg_results)
      kegg_results_file <- "kegg_results_allele_freq"
      if(!is.null(kegg_results_df)) {
        write.csv(kegg_results_df, paste0(kegg_results_file, ".csv"), quote = FALSE, row.names = FALSE)
        ##Visualize the enrichment results
        
        title_kegg <- paste0("Enriched KEGG pathways")
        
        
        ### Bar plot for KEGG pathway enrichment results
        png(paste0(saving_dir, "barplot_", kegg_results_file, ".png"), width = 1920, height = 1080, res = 150)
        print(barplot(kegg_results, showCategory = 10, title = title_kegg))  # Top 20 enriched KEGG pathways
        dev.off()
        ### Dot plot for KEGG enrichment results
        png(paste0(saving_dir, "dotplot_", kegg_results_file, ".png"), width = 1920, height = 1080, res = 150)
        print(dotplot(kegg_results, showCategory = 10, title = title_kegg))
        dev.off()
      } else {
        print(paste0("KEGG: No significant results"))
      }
    }
    else {
      print(paste0("KEGG: No entrez ids"))
    } 
  } else {
    print(paste0("No overlapping genes"))
  } 
