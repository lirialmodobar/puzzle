#Initial input processing functions

get_positions_dir <- function(state, anc){
    positions_dir <- file.path(wd, state, anc, "chr_info_filt")
    return(positions_dir)
}

get_file_path <- function(positions_dir, chr){
    positions_file_prefix <- paste0("chr_", chr, "_", label, state, "_filt")
    positions_file_path <- file.path(positions_dir, paste0(positions_file_prefix, ".txt")
    return(positions_file_path)                                 
}

process_frags_file <- function(positions_file_path, chr){
    data <- read.table(positions_file_path, header = FALSE, sep = "\t")
    positions <- dados[1:4]
    positions[, 1] <- paste0("chr", positions[, 1])
    colnames(positions) <- c("sample_id", "chr", "first_bp", "last_bp")
    return(positions)
}    
                                 
get_processed_frags_file <- function(state, anc, chr){
    positions_dir <- get_positions_dir(state, anc)
    positions_file_path <- get_file_path(positions_dir, chr)
    processed_file <- process_frags_file(positions_file_path, chr)
    return(processed_file)
} #apply to each state and label, saving it to a var with the name anc_state

#Test-related functions

## Function to merge and process data for a specific state
process_state_data <- function(eur_state, nat_state, afr_state, unk_state) {
  ### Merge the data frames for each ancestry
  df_state <- Reduce(function(x, y) merge(x, y, by = "sample_id", all = TRUE),
                     list(eur_state, nat_state, afr_state, unk_state))
  
  ### Fill missing values with zeros
  df_state[is.na(df_state)] <- 0
  
  return(df_state)
}

## Function to count n of fragments per state for given ancestries
 
count_anc_frags <- function(df_state, anc) {
    col <- paste0("first_bp_", anc)
    frags_anc_state <- rowSums(df_state[col] != 0)
    return(frags_anc_state)
}
  

##Function to calculate ancestry proportions
calculate_proportions <- function(frags_anc_state, total_frags_state) {
  prop_anc_state <- frags_anc_state / (total_frags_state)
  return(prop_anc_state)
}

## Function to calculate weighted mean
adjust_frag_n_by_proportion <- function(frags_anc_state, prop_anc_state) {
    adjusted_frag_number <- frags_anc_state * prop_anc_state
    return(adjusted_frag_number)
} 

correct_frag_number <- function(df_state, anc,total_frags_state){
    frags_anc_state <- count_anc_frags(df_state, anc)
    prop_anc_state <- calculate_proportions(frags_anc_state, total_frags_state)
    corrected_frag_number <- adjusted_frag_n_by_proportion(frags_anc_state, total_frags_state) 
    return(corrected_frag_number)
}

#Plotting related functions

get_df_anc_state <- function(anc, state){
	df_name <- paste0(anc, "_", state)
	df_anc_state <- get(df_name)
	return(df_anc_state)
}

process_df_anc_state <- function(anc, state){
	df_anc_state <- get_df_anc_state(anc, state)
	df_anc_state <- df_anc_state[2:4]
	colnames(df_anc_state) <- NULL
	return(df_anc_state)
}


select_random_frags <- function(df_anc_state, n_frags){
    set.seed(123)
    random_indices <- sample(1:n_frags, n_frags)
    random_frags <- df_anc_state[random_indices, ]
    return(random_frags)
}    #apply to each df_anc_state and each n_frags, generating df_anc_state_n_random

get_df_anc_state_random <- function(anc, state, n_frags){
	df_anc_state <- process_df_anc_state(anc, state)
	df_anc_state_random <- select_random_frags(df_anc_state, n_frags)
	return(df_anc_state_random) 
}

create_plot_dir <- function(positions_dir){
    plot_dir <- "frags_plots"
    if (!file.exists(file.path(positions_dir, plot_dir))) {
        dir.create(file.path(positions_dir, plot_dir))
    }
    plot_dir <- file.path(positions_dir, plot_dir)
    return(plot_dir)
}                                 
                                 
create_pdf_path <- function(plot_dir){
    pdf_path <- file.path(plot_dir, paste0("teste_",n_frags, "_frags_plot"))
    return(pdf_path)
} 
                
get_pdf_path <- function(anc, state){
    positions_dir <- get_positions_dir(anc,state)
    plot_dir <- create_plot_dir(positions_dir)
    pdf <- create_pdf_path(plot_dir)
    return(pdf)
}  

create_fragments_plot <- function(anc, state, n_frags, color) {
    pdf_file <- get_pdf_path(positions_dir)
    df_anc_state_random <- get_df_anc_state_random(anc, state, n_frags) 
    # Start PDF device
    pdf(pdf_file)
    # Create a karyotype object for chromosome drawing with the extracted chromosome
    kp <- plotKaryotype(genome = "hg38", chromosomes = chromosome)
    kpAddLabels(kp, labels = paste("frag", anc, state))
    # Add fragments to the plot
    kpPlotRegions(kp, data = df_anc_state_random, col=color, border=darker(color), avoid.overlapping=TRUE)
    # End PDF device
    dev.off()
}

#Set chr var

args <- commandArgs(trailingOnly=TRUE)
chr = args[1]

#Process input data

## Define the list of ancestries and states 
    states <- c("rs","sp")    
    ancestries <- c("eur", "nat", "afr", "unk")

for (state in states){
	for (anc in ancestries){
		df_anc_state <- get_processed_frags_file(state, anc, chr)
		var_name <- paste0(anc, "_", state)
		assign(var_name, df_anc_state)
	}
}	

# Merge and process data for state 1

rs <- process_state_data(eur_rs, nat_rs, afr_rs, unk_rs)

# Merge and process data for state 2
sp <- process_state_data(eur_sp, nat_sp, afr_sp, unk_sp)

# Calculate total fragments per state

total_frags_rs <- nrows(rs)
total_frags_sp <- nrows(sp)

# Get weighted mean of all ancestries (one state) fragment numbers corrected by the proportion of each ancestry contribution to the total number of fragments
  
  ## Obtain fragment numbers per ancestry/state corrected by the proportion of each ancestry contribution to total number of fragments
    for (state in states) {
        df_state <- ifelse(state == "rs", rs, sp)
        total_frag <- ifelse(state == "rs", total_frags_rs, total_frags_sp)
        corrected_n_vector <- numeric(length(ancestries)) 
        names(corrected_n_vector) <- ancestries
            for (anc in ancestries){
                corrected_n <- correct_n_frags(df_state, anc, total_frag)
                corrected_n_vector[anc] <- corrected_n_vector[anc] + corrected_n
            }
    ## Get weighted mean
    var_name <- paste0("weighted_average", state)
    assign(var_name, sum(corrected_n_vector))    
    }

# Calculate each state contributions to the total amount of fragments

porc_frags_rs <- total_frags_rs/(total_frags_rs + total_frags_sp)
porc_frags_sp <- total_frags_sp/(total_frags_rs + total_frags_sp)

#Calculate average between states averages weighted by their contribution

ref_n_fragments <- weighted_average_rs*porc_frags_sp + weighted_average_rs*porc_frags_sp

# Calculate the standard deviation
​
sd_ref_n_frags <- sd(c(weighted_average_rs, weighted_average_sp), 
                         c(porc_frags_rs, porc_frags_sp))

#Based on the ref_n_fragments, derive 3 numbers of fragments to plot the graph with, so we can test which is better
​
test_n_frags <- c(ref_n_frags - 3*sd_ref_n_frags, ref_n_frags, ref_n_frags + 3*sd_ref_n_frags)

#Plotting

chromosome <- paste0("chr",chr)
colors <- c("darkblue", "red", "darkgreen", "darkgrey")

for (i in 1:length(states)) {
    state <- states[i]
    for (j in 1:lenght(ancestries)) {
        anc <- ancestries[j]
        color <- colors[j]
	for (n_frags in test_n_frags){
		create_frags_plot(anc, state, n_frags, color)
	}
    }
}

# Save current environment
renv::snapshot()
