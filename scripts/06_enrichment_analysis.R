#Enrichment analysis

## libraries (see the ones that arent used)

library(dplyr)
library(rtracklayer)
library(fuzzyjoin)
library(tidyr)
library(biomaRt)
library(GenomicRanges)
library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(KEGGREST)
library(AnnotationDbi)
library(DOSE)

## Functions

find_overlapping_genes <- function(snv_gr, gene_gr, analysis) {
  # Find overlaps between SNVs and genes
  overlap_genes <- findOverlaps(snv_gr, gene_gr)
  
  # Extract the gene indices and names
  overlap_gene_indices <- subjectHits(overlap_genes)
  overlap_gene_names <- gene_gr$gene_name[overlap_gene_indices]
  overlap_gene_ensembl_id <- gene_gr$gene_id[overlap_gene_indices]
  
  # Combine gene names and Ensembl IDs into a DataFrame
  overlap_gene_data <- DataFrame(
    gene_name = overlap_gene_names,
    ensembl_id = overlap_gene_ensembl_id
  )
  
  assign(paste0(analysis, "overlap_gene_data"), overlap_gene_data, envir = .GlobalEnv)
  
  
  # Determine the gene info, default to Ensembl ID if gene name is NA or empty
  gene_info <- ifelse(is.na(overlap_gene_names) | overlap_gene_names == "", 
                            overlap_gene_ensembl_id, 
                            overlap_gene_names)
  
  # Return the list of unique gene names/IDs
  genes_list_go <- unique(gene_info)
  
  if(!is.null(genes_list_go)){
  return(genes_list_go)
  } else {
    print("No overlapping genes")
  }
}

get_entrez_ids <- function(overlap_gene_data) {
  
  # Retrieve Entrez IDs from Ensembl IDs
  entrez_mapping <- AnnotationDbi::select(org.Hs.eg.db, keys = overlap_gene_data$ensembl_id, 
                                          columns = c("ENSEMBL", "ENTREZID"), keytype = "ENSEMBL")
  
  # Extract and return unique Entrez IDs
  entrez_ids <- unique(entrez_mapping$ENTREZID)
  if(!is.null(entrez_ids)){ 
  return(entrez_ids)
  } else {
    print("KEGG: no entrez ids")
  }
}

organize_enrichment_results <- function(enrichResult)  {
  #Filters for significant results adjusted by multiple comparisions
  #Orders by gene ratio and then p.adjust
  
  ##Filter for significant results 
  
  results_df <- enrichResult@result
  results_significant <-results_df[results_df$p.adjust < 0.05,]
  
  ##Order by p.adjust and gene ratio
  if (!is.null(results_significant) && nrow(results_significant) != 0) {
    ### Split the GeneRatio values by the '/' character
    gene_ratio_parts <- strsplit(results_significant$GeneRatio, "/")
    results_significant$n_genes_input <- sapply(gene_ratio_parts, function(x) as.numeric(x[2]))
    
    ### Perform the division and store the results
    results_significant$GeneRatio <- sapply(gene_ratio_parts, function(x) as.numeric(x[1]) / as.numeric(x[2]))
    
    ### Now order by p.adjust (ascending) and then GeneRatio (descending) 
    results_significant <- results_significant[order(results_significant$p.adjust, -results_significant$GeneRatio), ]
    return(results_significant)
  }
}

perform_go_enrichment <- function(genes_list) {
  # Perform GO enrichment analysis
  go_results <- enrichGO(
    gene = genes_list,
    keyType = "ENSEMBL",
    OrgDb = org.Hs.eg.db,  # Human genome annotations
    ont = c("ALL")
  )
    # Organize the results
  all_go_results_df <- go_results@result
  go_results_df <- organize_enrichment_results(go_results)
  return(list(
    go_results_df = go_results_df,
    go_results = go_results,
    all_go_results_df = all_go_results_df
  ))
}

perform_kegg_enrichment <- function(entrez_ids, organism = "hsa", pvalue_cutoff = 0.05) {
  kegg_results <- enrichKEGG(
    gene = entrez_ids,
    organism = organism,
    pvalueCutoff = pvalue_cutoff
  )
  all_kegg_results_df <- kegg_results@result
  kegg_results_df <- organize_enrichment_results(kegg_results)
  return(list(
    kegg_results_df = kegg_results_df,
    kegg_results = kegg_results,
    all_kegg_results_df = all_kegg_results_df
  ))
}

perform_dgn_enrichment <- function(snv_ids) {
    # SNP Disease-Gene Network Visualization
    dgn_results <- enrichDGNv(snv_ids)
    all_dgn_results_df <- dgn_results@result
      dgn_results_df <- organize_enrichment_results(dgn_results)
      return(list(
        dgn_results_df = dgn_results_df,
        dgn_results = dgn_results,
        all_dgn_results_df = all_dgn_results_df
      ))
}


generate_enrichment_plots <- function(enrich_result, output_dir, plot_title, plot_file, enrich_type) {
  if (length(enrich_result) > 0) {
    # Bar plot
    barplot_file <- paste0(output_dir, "barplot_", plot_file, ".png")
    png(barplot_file, width = 1920, height = 2060, res = 150)
    print(barplot(enrich_result, showCategory = 20, title = plot_title, x = "GeneRatio"))
    dev.off()
    
    # Extract pathway data
    barplot_object <- print(barplot(enrich_result, showCategory = 20, title = plot_title, x = "GeneRatio"))
    barplot_pathway_id <- barplot_object[["data"]][["ID"]]
    barplot_pathway_desc <- barplot_object[["data"]][["Description"]]
    barplot_pathways <- data.frame(barplot_pathway_id, barplot_pathway_desc)
    
    assign(paste0(enrich_type, "_barplot_object"), barplot_object, envir = .GlobalEnv)
    assign(paste0(enrich_type, "_barplot_pathways"), barplot_pathways, envir = .GlobalEnv)
    # Dot plot
    dotplot_file <- paste0(output_dir, "dotplot_", plot_file, ".png")
    png(dotplot_file, width = 1920, height = 1080, res = 150)
    print(dotplot(enrich_result, showCategory = 20, title = plot_title, size = "Count", x = "GeneRatio"))
    dev.off()
  } 
}

process_pathways_in_plot <- function(barplot_data, results_df, bg_ratio_col = "BgRatio") {
  pathways_plot <- as.data.frame(barplot_data)
  pathways_plot <- inner_join(pathways_plot, results_df, 
                              by = c("barplot_pathway_id" = "ID", 
                                     "barplot_pathway_desc" = "Description"))
  pathways_plot <- separate(pathways_plot, bg_ratio_col, 
                            into = c("n_genes_pathway", "n_genes_homo_sapiens"), sep = "/")
  
  return(pathways_plot)
}

## Directories

allele_freq_dir <- "/home/yuri/liri/puzzle/comp_allele_freq/"
freq_go_dir <- paste0(allele_freq_dir, "enrichment_analysis/go/")
freq_kegg_dir <- paste0(allele_freq_dir, "enrichment_analysis/kegg/")
freq_dgn_dir <- paste0(allele_freq_dir, "enrichment_analysis/dgn/")
occur_dir <- "/home/yuri/liri/puzzle/comp_occur/all/3dp/"
occur_go_dir <- paste0(occur_dir, "enrichment_analysis/go/")
occur_kegg_dir <- paste0(occur_dir, "enrichment_analysis/kegg/")
occur_dgn_dir <- paste0(occur_dir, "enrichment_analysis/dgn/")

### Create directories if they don't exist
dirs <- c(allele_freq_dir, freq_go_dir, freq_kegg_dir, freq_dgn_dir,
          occur_dir, occur_go_dir, occur_kegg_dir, occur_dgn_dir)

#### Create directories recursively
sapply(dirs, function(d) if (!dir.exists(d)) dir.create(d, recursive = TRUE))
  
## Inputs

allele_freq <- read.csv(paste0(allele_freq_dir, "snvs_diff_all.csv"))
occur_rs_gt_sp <- read.csv(paste0(occur_dir, "diff_rs_gt_sp_all_chr.csv"))
occur_sp_gt_rs <- read.csv(paste0(occur_dir, "diff_sp_gt_rs_all_chr.csv"))
occur_diff_all <- read.csv(paste0(occur_dir, "different_all_chr.csv"))


## Retrieve gene information (chromosome, start, end positions, gene names)

ensembl = useMart("ensembl", dataset = "hsapiens_gene_ensembl",  host = "https://useast.ensembl.org")

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

## Enrichment analysis for differences in allele frequencies

snv_gr_freq <- GRanges(
  seqnames = allele_freq$CHR, 
  ranges = IRanges(
    start = allele_freq$BP,  # SNV positions
    end = allele_freq$BP  # Same position for the end
  )
)

genes_list_freq <- find_overlapping_genes(snv_gr_freq, gene_gr, "freq_all_")
write.csv(genes_list_freq, paste0(freq_go_dir, "genes_all_freq.csv"), quote = FALSE, row.names = FALSE)
genes_ensembl_ids <- unique(freq_all_overlap_gene_data$ensembl_id)  
### Convert to ENTREZ ids (necessary for KEGG enrichment)
  
entrez_ids_freq <- get_entrez_ids(freq_all_overlap_gene_data)
write.csv(entrez_ids_freq, paste0(freq_kegg_dir, "genes_kegg_all_freq.csv"), quote = FALSE, row.names = FALSE)
  
### GO
  
go_results_list_freq <- perform_go_enrichment(genes_ensembl_ids)
go_results_df_freq <- go_results_list_freq$go_results_df
go_results_freq <- go_results_list_freq$go_results
all_go_results_freq <- go_results_list_freq$all_go_results_df

  if(!is.null(go_results_df_freq)) {
    write.csv(go_results_df_freq, paste0(freq_go_dir, "go_results_all_freq.csv"), quote = FALSE, row.names = FALSE)
    
    ####Visualize the enrichment results
    title_go_freq <- paste0("Top enriched GO terms for high differences in allele freq.")
    plot_file_go_freq <- "go_results_freq"
    generate_enrichment_plots(go_results_freq, freq_go_dir, title_go_freq, plot_file_go_freq, "go_freq")
  } else {
    print("GO: No significant results")
  }

###  KEGG

kegg_results_list_freq <- perform_kegg_enrichment(entrez_ids_freq)
kegg_results_df_freq <- kegg_results_list_freq$kegg_results_df
kegg_results_freq <-kegg_results_list_freq$kegg_results
all_kegg_results_freq <- kegg_results_list_freq$all_kegg_results_df

if(!is.null(kegg_results_df_freq)) {
      write.csv(kegg_results_df_freq, paste0(freq_kegg_dir, "kegg_results_freq_all.csv"), quote = FALSE, row.names = FALSE)
      ####Visualize the enrichment results
      title_kegg_freq <- "Enriched KEGG pathways for high differences in allele freq."
      plot_file_kegg_freq <- "kegg_results_freq_all"
      generate_enrichment_plots(kegg_results_freq, freq_kegg_dir, title_kegg_freq, plot_file_kegg_freq, "kegg_freq")
} else {
    print("KEGG: No significant results")
  }

### DGN 


snv_ids_freq <- allele_freq$rsids

# Ensure there are SNP IDs to process
if (length(snv_ids_freq) > 0) {
  # SNP Disease-Gene Network Visualization
  dgn_results_list_freq <- perform_dgn_enrichment(snv_ids_freq)
  dgn_results_df_freq <- dgn_results_list_freq$dgn_results_df
  dgn_results_freq <-dgn_results_list_freq$dgn_results
  all_dgn_results_freq <- dgn_results_list_freq$all_dgn_results_df
  
  # Save results
  if (!is.null(dgn_results_freq)) {
    # Save as CSV
    write.csv(dgn_results_df_freq, paste0(freq_dgn_dir, "results_dgn_freq_all.csv"), quote = FALSE, row.names = FALSE)
    
    title_dgn_freq <- "DGN Enrichment for high differences in allele freq."
    plot_file_dgn_freq <- "dgn_results_freq_all"
    generate_enrichment_plots(dgn_results_freq, freq_dgn_dir, title_dgn_freq, plot_file_dgn_freq, "dgn_freq")
} else {
  print("No significant results")
} 
  } else {
  print("No SNP IDs available")
}

##Enrichment analysis for occurrences 

comparisions <- c("different positions","different positions (rs > sp)","different positions (sp > rs)")

for (comp in comparisions) {
 if (comp == "different positions") {
    snv_gr_occur <- GRanges(
      seqnames = occur_diff_all$chr,  # Single chromosome (e.g., "1")
      ranges = IRanges(
        start = occur_diff_all$pos,  # SNV positions
        end = occur_diff_all$pos  # Same position for the end
      )
    ) 
  } else if (comp == "different positions (rs > sp)") {
    snv_gr_occur <- GRanges(
      seqnames = occur_rs_gt_sp$chr,  # Single chromosome (e.g., "1")
      ranges = IRanges(
        start = occur_rs_gt_sp$pos ,  # SNV positions
        end = occur_rs_gt_sp$pos # Same position for the end
      )
    ) 
  } else if (comp == "different positions (sp > rs)") {
    snv_gr_occur <- GRanges(
      seqnames = occur_sp_gt_rs$chr,  # Single chromosome (e.g., "1")
      ranges = IRanges(
        start = occur_sp_gt_rs$pos,  # SNV positions
        end = occur_sp_gt_rs$pos  # Same position for the end
      )
    )
  }
  
  comp_clean <- gsub("_+", "_", gsub(" ", "_", gsub("\\(|\\)", "", gsub(">", "_", comp))))
  
    ### Find Genes Overlapping SNVs
  
    genes_list_occur <- find_overlapping_genes(snv_gr_occur, gene_gr, "occur_")
    write.csv(genes_list_occur, paste0(occur_go_dir, "genes_", comp_clean, ".csv"), quote = FALSE, row.names = FALSE)
    genes_ensembl_ids <- unique(occur_overlap_gene_data$ensembl_id)  
    
    
    ### Convert to ENTREZ ids (necessary for KEGG enrichment)
    
    entrez_ids_occur <- get_entrez_ids(occur_overlap_gene_data)
    write.csv(entrez_ids_occur, paste0(occur_kegg_dir, "genes_kegg_", comp_clean, ".csv"), quote = FALSE, row.names = FALSE)
    
    
    ### GO
    go_results_list_occur <- perform_go_enrichment(genes_ensembl_ids)
    go_results_df_occur <- go_results_list_occur$go_results_df
    assign(paste0("go_results_df_occur_", comp_clean), go_results_df_occur)
    all_go_results_occur <- go_results_list_occur$all_go_results_df
    assign(paste0("all_go_results_occur_", comp_clean), all_go_results_occur)
    go_results_occur <- go_results_list_occur$go_results
    go_results_file <- paste0("go_results_3dp_",  comp_clean)
  
    if(!is.null(go_results_df_occur)) {
      write.csv(go_results_df_occur, paste0(occur_go_dir, go_results_file, ".csv"), quote = FALSE, row.names = FALSE)
      
      ####Visualize the enrichment results
      title_go_occur <- paste0("Top enriched GO terms for ", comp)
      
     generate_enrichment_plots(go_results_occur, occur_go_dir, title_go_occur, go_results_file, paste0("go_occur_", comp_clean)) 
    }
  
    ### KEGG 
  
    if(!is.null(entrez_ids_occur) && length(entrez_ids_occur) != 0) {
      kegg_results_list_occur <- perform_kegg_enrichment(entrez_ids_occur)
      kegg_results_df_occur <- kegg_results_list_occur$kegg_results_df
      assign(paste0("kegg_results_df_occur_", comp_clean),kegg_results_df_occur)
      all_kegg_results_occur <- kegg_results_list_occur$all_kegg_results_df
      assign(paste0("all_kegg_results_df_occur_", comp_clean), all_kegg_results_occur)
      kegg_results_occur <- kegg_results_list_occur$kegg_results
      kegg_results_file <- paste0("kegg_results_3dp_", comp_clean)
      if(!is.null(kegg_results_df_occur)) {
        write.csv(kegg_results_df_occur, paste0(occur_kegg_dir, kegg_results_file, ".csv"), quote = FALSE, row.names = FALSE)
        ####Visualize the enrichment results
        title_kegg_occur <- paste0("Enriched KEGG pathways for ", comp)
        generate_enrichment_plots(kegg_results_occur, occur_kegg_dir, title_kegg_occur, kegg_results_file, paste0("kegg_occur_", comp_clean))
      } else {
        print(paste0("KEGG: No significant results for comp ", comp))
      }
    
    }
} 

###DGN 
  
#### Define comparisons
comparisions_snvs <- c("different positions snvs", 
                       "different positions snvs (rs > sp)", "different positions snvs (sp > rs)")

for (comps in comparisions_snvs) {
  #### Select appropriate SNP data based on the comparison
  if (comps == "different positions snvs") {
    snv_ids_occur <- occur_diff_all$rsid
  } else if (comps == "different positions snvs (rs > sp)") {
    snv_ids_occur <- occur_rs_gt_sp$rsid
  } else if (comps == "different positions snvs (sp > rs)") {
    snv_ids_occur <- occur_sp_gt_rs$rsid
  }

  comps_clean <-  gsub("_+", "_", gsub(" ", "_", gsub("\\(|\\)", "", gsub(">", "_", comps))))
  #### Ensure there are SNP IDs to process
  if (length(snv_ids_occur) > 0) {
    dgn_results_list_occur <- perform_dgn_enrichment(snv_ids_occur)
    dgn_results_df_occur <- dgn_results_list_occur$dgn_results_df
    assign(paste0("dgn_results_df_occur_", comps_clean), dgn_results_df_occur)
    all_dgn_results_occur <- dgn_results_list_occur$all_dgn_results_df
    assign(paste0("all_dgn_results_df_occur_", comps_clean), all_dgn_results_occur)
    dgn_results_occur <- dgn_results_list_occur$dgn_results
    if (!is.null(dgn_results_occur)) {
      # Save as CSV
      dgn_results_file <- paste0("results_dgn_3dp_", comps_clean, ".csv")
      write.csv(dgn_results_df_occur, paste0(occur_dgn_dir, dgn_results_file), quote = FALSE, row.names = FALSE)
            plot_file <- paste0("dgn_3dp_", comps_clean)
      dgn_title_occur <- paste0("DGN Enrichment for ", comps)
      generate_enrichment_plots(dgn_results_occur, occur_dgn_dir, dgn_title_occur, plot_file, paste0("dgn_occur_", comps_clean))
    } else {
      print(paste0("SNP-DGNV: No significant results for comp ", comps))
    }
  } else {
    print(paste0("No SNP IDs available for comp", comps))
  }
}

## Detailed results

pathways_in_plot <- list(
  go_freq    = list(go_freq_barplot_pathways, go_results_df_freq, c(1,2,3,4,5,6,11,12,7,8,9,10)),
  kegg_freq  = list(kegg_freq_barplot_pathways, kegg_results_df_freq, c(1,2,3,4,5,12,13,6,7,8,9,10,11)),
  dgn_freq   = list(dgn_freq_barplot_pathways, dgn_results_df_freq, c(1,2,3,4,5,10,11,6,7,8,9)),
  go_occur_rs_gt_sp  = list(go_occur_different_positions_rs_sp_barplot_pathways, go_results_df_occur_different_positions_rs_sp, c(1,2,3,4,5,6,11,12,7,8,9,10)),
  go_occur_sp_gt_rs  = list(go_occur_different_positions_sp_rs_barplot_pathways, go_results_df_occur_different_positions_sp_rs, c(1,2,3,4,5,6,11,12,7,8,9,10)),
  go_occur_diff  = list(go_occur_different_positions_barplot_pathways, go_results_df_occur_different_positions, c(1,2,3,4,5,6,11,12,7,8,9,10)),
  dgn_occur_diff = list(dgn_occur_different_positions_snvs_barplot_pathways, dgn_results_df_occur_different_positions_snvs, c(1,2,3,4,5,10,11,6,7,8,9)),
  dgn_occur_rs_gt_sp = list(dgn_occur_different_positions_snvs_rs_sp_barplot_pathways, dgn_results_df_occur_different_positions_snvs_rs_sp, c(1,2,3,4,5,10,11,6,7,8,9)),
  dgn_occur_sp_gt_rs = list(dgn_occur_different_positions_snvs_sp_rs_barplot_pathways, dgn_results_df_occur_different_positions_snvs_sp_rs, c(1,2,3,4,5,10,11,6,7,8,9))
  )

pathways_in_plot_processed <- Map(function(barplot, results, order) {
  process_pathways_in_plot(barplot, results)[, order]
}, lapply(pathways_in_plot, `[[`, 1), lapply(pathways_in_plot, `[[`, 2), lapply(pathways_in_plot, `[[`, 3))

pathways_go_plot_freq    <- pathways_in_plot_processed$go_freq
pathways_kegg_plot_freq  <- pathways_in_plot_processed$kegg_freq
pathways_dgn_plot_freq   <- pathways_in_plot_processed$dgn_freq
pathways_go_plot_occur_rs_sp    <- pathways_in_plot_processed$go_occur_rs_gt_sp
pathways_go_plot_occur_sp_rs    <- pathways_in_plot_processed$go_occur_sp_gt_rs
pathways_go_plot_occur_diff    <- pathways_in_plot_processed$go_occur_diff
pathways_dgn_plot_occur_diff   <- pathways_in_plot_processed$dgn_occur_diff
pathways_dgn_plot_occur_rs_sp   <- pathways_in_plot_processed$dgn_occur_rs_gt_sp
pathways_dgn_plot_occur_sp_rs   <- pathways_in_plot_processed$dgn_occur_sp_gt_rs

write.csv(pathways_go_plot_freq, paste0(freq_go_dir, "pathways_go_plot_freq.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_kegg_plot_freq, paste0(freq_kegg_dir, "pathways_kegg_plot_freq.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_dgn_plot_freq, paste0(freq_dgn_dir, "pathways_dgn_plot_freq.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_go_plot_occur_rs_sp, paste0(occur_go_dir, "pathways_go_plot_occur_rs_sp.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_dgn_plot_occur_diff, paste0(occur_dgn_dir, "pathways_dgn_plot_occur_diff.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_dgn_plot_occur_rs_sp, paste0(occur_dgn_dir, "pathways_dgn_plot_occur_rs_sp.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_dgn_plot_occur_sp_rs, paste0(occur_dgn_dir, "pathways_dgn_plot_occur_sp_rs.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_go_plot_occur_diff, paste0(occur_dgn_dir, "pathways_go_plot_occur_diff.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_go_plot_occur_rs_sp, paste0(occur_dgn_dir, "pathways_go_plot_occur_rs_sp.csv"), row.names = FALSE, quote = FALSE)
write.csv(pathways_go_plot_occur_sp_rs, paste0(occur_dgn_dir, "pathways_go_plot_occur_sp_rs.csv"), row.names = FALSE, quote = FALSE)