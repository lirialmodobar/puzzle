library(rrapply)

check_overlap <- function(row_1, row_2){
  last_bp_row_1 <- row_1["last_bp"]
  first_bp_row_2 <- row_2["first_bp"]
  if(!is.na(first_bp_row_2) && last_bp_row_1 >= first_bp_row_2) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}


count_overlaps_and_non_overlaps <- function(df){
  n <- nrow(df)
  if (n == 0) return(list(overlap_blocks = 0, non_overlap_rows = 0))
  overlap_count <- 0
  non_overlap_count <- 0
  i <- 1
  
  while (i < n) {
    # Check for overlap
    is_overlap <- check_overlap(df[i, ], df[i + 1, ])
    if (is_overlap) {
      overlap_count <- overlap_count + 1
      print("Overlap block:")
      # Print the first row of the overlapping block
      print(df[i, ])
      # Skip all consecutive overlapping rows and print them
      while (i < n && check_overlap(df[i, ], df[i + 1, ])) {
        i <- i + 1
        print(df[i, ])
      }
    } else {
      non_overlap_count <- non_overlap_count + 1
      print(paste("Non-overlapping row:", paste(df[i, ], collapse = " ")))
    }
    i <- i + 1
  }
  
  # Check the last row
  if (i == n) {
    if (n == 1 && !check_overlap(df[i - 1, ], df[i, ])) {
      non_overlap_count <- non_overlap_count + 1
      print(paste("Non-overlapping row:", paste(df[i, ], collapse = " ")))
    } else {
      print(df[i, ])
    }
  }
  
  return(list(overlap_blocks = overlap_count, non_overlap_rows = non_overlap_count))
}

y_0_matters <- function(df, min, max) {
  if(min != max && min < nrow(df) && nrow(df) <= max) {
    return(TRUE)
  } 
  else if (min == max && nrow(df) == min) {
    return(TRUE)
  }
  else {
    return(FALSE)
  }
}

subset_dataframe <- function(df, row_A_index, df2 = NULL) {
  # Get the value of the second column for row A
  x <- df[row_A_index, "last_bp"]
  
  # Find values from the first column greater than x
  y_values <- subset(df, df$first_bp > x)
  
  # See if there is overlaps in y values
  if(nrow(y_values) != 0){
    encountered_rows <- list()
    overlap_result <- list()
    previous_row <- y_values[1, ]
    encountered_rows[[1]] <- previous_row
    
    
    for (i in 2:nrow(y_values)) {
      current_row <- y_values[i, ]
      
      # Check overlap based on specific columns
      overlap <- check_overlap(previous_row, current_row)
      
      if (overlap) {
        # Check if the current row is a duplicate based on specific columns
        is_duplicate <- any(sapply(encountered_rows, function(row) all(row[c("first_bp", "last_bp")] == current_row[c("first_bp", "last_bp")])))
        
        if (is_duplicate) {
          overlap_result <- c(overlap_result, list(current_row))
        } else {
          overlap_result <- c(overlap_result, list(previous_row, current_row))
        }
        
        encountered_rows <- c(encountered_rows, list(current_row))
        previous_row <- current_row
      } else {
        break
      }
    }
    
  } else {
      overlap_result <- NULL
    }
   
 
  # Determine y rows to be analysed
    
   if(length(overlap_result) == 0 && nrow(y_values != 0)) {
      only_y_row <- y_values[1,]
    } else {
      y_rows <- overlap_result  
    }
  
  # Initialize an empty list to store subsets
  subset_list <- list()

  if (!is.null(df2) && nrow(y_values) == 0 && y_0_matters(df2, min, max)) {
    subset_list[[length(subset_list) + 1]] <- df2
  } 
  

  
  # Iterate over y rows 
  if(exists("only_y_row")){
    if(is.null(df2)){
      # Generate subset dataframe
      subset_df <- rbind(df[row_A_index, , drop = FALSE], only_y_row)
      subset_list[[length(subset_list) + 1]] <- subset_df
      
    } else {
      subset_df <- rbind(df2, only_y_row)
      subset_list[[length(subset_list) + 1]] <- subset_df  
    }
  }  else {
  for (y_row in y_rows) {
    if(is.null(df2)){
      # Generate subset dataframe
      subset_df <- rbind(df[row_A_index, , drop = FALSE], y_row)
      subset_list[[length(subset_list) + 1]] <- subset_df
    } else {
      subset_df <- rbind(df2, y_row)
      subset_list[[length(subset_list) + 1]] <- subset_df  
    }
  }
  }
  # Return the list of subsets
  return(subset_list)
}

# Apply the function to all rows of the dataframe
generate_subsets <- function(df) {
  subsets <- lapply(1:(nrow(df)-1), function(i) subset_dataframe(df, i))
  flattened_subsets <- unlist(subsets, recursive = FALSE)
  return(flattened_subsets)
}

find_last_row_indices <- function(df1, df_list) {
  last_row_indices <- sapply(df_list, function(df) {
    last_row_df <- df[nrow(df), ]
    for (j in 1:nrow(df1)) {
      if (all(df1[j,] == last_row_df)) {
        return(j)
      }
    }
    return(NA)
  })
  
  return(last_row_indices)
}

process_subsets <- function(df, all_subsets){
  index <- find_last_row_indices(df, all_subsets)
  print(index)
  # Iterate over each subset and its corresponding index
  for (i in seq_along(all_subsets)) {
    # Get the subset
    subset_df <- all_subsets[[i]]
    
    # Get the corresponding index
    row <- index[i]
    
    if (row != last_row) {
      # Apply the function with the corresponding index from find_last_row_indices
      modified_subset <- subset_dataframe(df, row, subset_df)
      all_subsets[[i]] <- modified_subset
    } 
    else if (y_0_matters(subset_df, min, max)) {
      all_subsets[[i]] <- modified_subset
    }
    else{
      all_subsets[[i]] <- "not relevant"
    }
  } 
  all_subsets <- rrapply(all_subsets, classes = "data.frame", how = "flatten")
  new_index <- find_last_row_indices(df, all_subsets)
  print(index)
  # Check if all last row indices match last_row
  if (identical(new_index, index))  {
    # Base case: All last row indices match last_row, stop recursion
    return(all_subsets)
  } else {
    # Recursive case: Some subsets still need modification, continue recursion
    process_subsets(df, all_subsets)
  }
}

write_dfs <- function(df, comb_number, directory) {
  # Extracting the values from the columns to create the file name
  chr_number <- df$chr[1]
  state_table <- df$state[1]
  anc_table_upper <- df$anc[1]
  anc_table <- tolower(anc_table_upper)
  
  # Creating the file name
  file_name <- paste0("chr_", chr_number, "_", anc_table, "_", state_table, "_comb_", comb_number, ".tsv")
  
  file_path <- file.path(directory, file_name)
  
  # Writing the data frame to a TSV file
  write.table(df, file = file_path, sep = "\t", row.names = FALSE, col.names = TRUE)
}


#################################################################################################

#Main script

args <- commandArgs(trailingOnly = T)

chr <- args[1]
state <- args[2]
anc <- args[3]
base_dir <- "/scratch/unifesp/pgt/liriel.almodobar"


collapse_dir <- file.path(base_dir, "puzzle", state, anc, "chr_info_unfilt")
collapse_file <- paste0("chr_", chr, "_", anc, "_", state, "_unfilt.txt")
collapse_info <- file.path(collapse_dir, collapse_file)

collapse_info <- read.table(collapse_info, header = F, sep = "\t") [c(-5, -6)]
colnames(collapse_info) <- c("id", "chr", "first_bp", "last_bp", "anc", "state")

overlap_non_overlap <- count_overlaps_and_non_overlaps(collapse_info)
min <- overlap_non_overlap[[1]]
max <- overlap_non_overlap[[1]] + overlap_non_overlap[[2]]

# Apply the function to generate subsets
all_subsets <- generate_subsets(collapse_info)

# Initialize a list to store the modified subsets
last_row <- nrow(collapse_info)

all_subsets <- process_subsets(collapse_info, all_subsets)

seq_directory <- file.path(collapse_dir, "seq_info")  # Specify your directory here
lapply(seq_along(all_subsets), function(i) write_dfs(all_subsets[[i]], i, seq_directory))



