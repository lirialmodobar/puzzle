library(rrapply)

# Function to check overlap between two rows
check_overlap <- function(row_1, row_2){
  last_bp_row_1 <- row_1["last_bp"]
  first_bp_row_2 <- row_2["first_bp"]
  if(!is.na(first_bp_row_2) && last_bp_row_1 >= first_bp_row_2) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

# Function to count overlaps and non-overlaps
count_overlaps_and_non_overlaps <- function(df){
  n <- nrow(df)
  if (n == 0) {
    print("Dataframe is empty.")
    return(list(overlap_blocks = 0, non_overlap_rows = 0))
  }
  
  overlap_count <- 0
  non_overlap_count <- 0
  i <- 1
  
  while (i < n) {
    # Check for overlap
    is_overlap <- check_overlap(df[i, ], df[i + 1, ])
    print(paste("Checking overlap between row", i, "and row", i + 1, ":", is_overlap))
    
    if (is_overlap) {
      overlap_count <- overlap_count + 1
      print("Overlap block detected:")
      print(df[i, ])
      
      # Skip all consecutive overlapping rows and print them
      while (i < n && check_overlap(df[i, ], df[i + 1, ])) {
        i <- i + 1
        print(paste("Continuing overlap block with row", i))
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
    print(paste("Checking last row:", i))
    if (n == 1 || !check_overlap(df[i - 1, ], df[i, ])) {
      non_overlap_count <- non_overlap_count + 1
      print(paste("Non-overlapping last row:", paste(df[i, ], collapse = " ")))
    } else {
      print("Last row is part of an overlap block:")
      print(df[i, ])
    }
  }
  
  print(paste("Total overlap blocks:", overlap_count))
  print(paste("Total non-overlapping rows:", non_overlap_count))
  
  return(list(overlap_blocks = overlap_count, non_overlap_rows = non_overlap_count))
}

# Function to determine if y_0 matters
y_0_matters <- function(df, min_val, max_val) {
  
  if(min_val != max_val && min_val < nrow(df) && nrow(df) <= max_val) {
    print("y_0_matters: Condition 1 met.")
    return(TRUE)
  } 
  else if ((min_val == max_val && nrow(df) == min_val) || (min_val == 1 && max_val == 1)) {
    print("y_0_matters: Condition 2 met.")
    return(TRUE)
  }
  else {
    print("y_0_matters: No conditions met.")
    return(FALSE)
  }
}

# Function to subset the dataframe
subset_dataframe <- function(df, row_A_index, df2 = NULL) {
  print(paste("Subsetting dataframe with row_A_index =", row_A_index))
  
  # Get the value of the 'last_bp' column for row A
  x <- df[row_A_index, "last_bp"]
  print(paste("Value of last_bp for row", row_A_index, ":", x))
  
  # Find rows where 'first_bp' is greater than x
  y_values <- subset(df, df$first_bp > x)
  print(paste("Number of y_values where first_bp >", x, ":", nrow(y_values)))
  
  # Initialize overlap_result
  overlap_result <- list()
  
  if(nrow(y_values) != 0){
    encountered_rows <- list()
    overlap_result <- list()
    previous_row <- y_values[1, ]
    encountered_rows[[1]] <- previous_row
    print("Starting overlap checks within y_values.")
    
    for (i in 2:nrow(y_values)) {
      current_row <- y_values[i, ]
      print(paste("Checking overlap between y_values row", i - 1, "and row", i))
      
      # Check overlap
      overlap <- check_overlap(previous_row, current_row)
      print(paste("Overlap:", overlap))
      
      if (overlap) {
        # Check for duplicates
        is_duplicate <- any(sapply(encountered_rows, function(row) all(row[c("first_bp", "last_bp")] == current_row[c("first_bp", "last_bp")])))
        print(paste("Is duplicate:", is_duplicate))
        
        if (is_duplicate) {
          overlap_result <- c(overlap_result, list(current_row))
        } else {
          overlap_result <- c(overlap_result, list(previous_row, current_row))
        }
        
        encountered_rows <- c(encountered_rows, list(current_row))
        previous_row <- current_row
      } else {
        print("No overlap detected, stopping overlap checks.")
        break
      }
    }
    
  } else {
    print("No y_values found with first_bp > x.")
    overlap_result <- NULL
  }
  
  # Determine y rows to be analysed
  if(length(overlap_result) == 0 && nrow(y_values) != 0) {
    only_y_row <- y_values[1,]
    print("Only y_row to be analysed:")
    print(only_y_row)
  } else {
    y_rows <- overlap_result  
    print("Overlapping y_rows to be analysed:")
    print(y_rows)
  }
  
  # Initialize an empty list to store subsets
  subset_list <- list()
  
  if (!is.null(df2) && nrow(y_values) == 0 && y_0_matters(df2, min_val, max_val)) {
    print("Adding df2 to subset_list based on y_0_matters condition.")
    subset_list[[length(subset_list) + 1]] <- df2
  } 
  
  # Iterate over y rows 
  if(exists("only_y_row")){
    if(is.null(df2)){
      # Generate subset dataframe
      subset_df <- rbind(df[row_A_index, , drop = FALSE], only_y_row)
      print("Created subset dataframe by combining row_A and only_y_row:")
      print(subset_df)
      subset_list[[length(subset_list) + 1]] <- subset_df
    } else {
      subset_df <- rbind(df2, only_y_row)
      print("Created subset dataframe by combining df2 and only_y_row:")
      print(subset_df)
      subset_list[[length(subset_list) + 1]] <- subset_df  
    }
  }  else {
    for (y_row in y_rows) {
      if(is.null(df2)){
        # Generate subset dataframe
        subset_df <- rbind(df[row_A_index, , drop = FALSE], y_row)
        print("Created subset dataframe by combining row_A and y_row:")
        print(subset_df)
        subset_list[[length(subset_list) + 1]] <- subset_df
      } else {
        subset_df <- rbind(df2, y_row)
        print("Created subset dataframe by combining df2 and y_row:")
        print(subset_df)
        subset_list[[length(subset_list) + 1]] <- subset_df  
      }
    }
  }
  
  # Return the list of subsets
  print(paste("Number of subsets created:", length(subset_list)))
  return(subset_list)
}

# Function to generate subsets for all rows
generate_subsets <- function(df) {
  print("Generating subsets for all rows.")
  subsets <- lapply(1:(nrow(df)-1), function(i) {
    print(paste("Generating subset for row", i))
    subset_dataframe(df, i)
  })
  flattened_subsets <- unlist(subsets, recursive = FALSE)
  print(paste("Total subsets generated:", length(flattened_subsets)))
  return(flattened_subsets)
}

# Function to find last row indices
find_last_row_indices <- function(df1, df_list) {
  print("Finding last row indices for all subsets.")
  last_row_indices <- sapply(df_list, function(df_subset) {
    last_row_df <- df_subset[nrow(df_subset), ]
    for (j in 1:nrow(df1)) {
      if (all(df1[j,] == last_row_df)) {
        return(j)
      }
    }
    return(NA)
  })
  print("Last row indices found:")
  print(last_row_indices)
  return(last_row_indices)
}

# Function to process subsets recursively
process_subsets <- function(df, all_subsets){
  print("Processing subsets recursively.")
  index <- find_last_row_indices(df, all_subsets)
  
  print("Indices corresponding to subsets:")
  print(index)
  
  # Iterate over each subset and its corresponding index
  for (i in seq_along(all_subsets)) {
    # Get the subset
    subset_df <- all_subsets[[i]]
    
    # Get the corresponding index
    row <- index[i]
    
    print(paste("Processing subset", i, "with corresponding row index:", row))
    
    if (!is.na(row) && row != last_row) {
      # Apply the function with the corresponding index from find_last_row_indices
      modified_subset <- subset_dataframe(df, row, subset_df)
      all_subsets[[i]] <- modified_subset
      print(paste("Modified subset", i, ":"))
      print(modified_subset)
    } 
    else if (!is.na(row) && y_0_matters(subset_df, min_val, max_val)) {
      all_subsets[[i]] <- modified_subset
      print(paste("Subset", i, "modified based on y_0_matters condition."))
    }
    else{
      all_subsets[[i]] <- "not relevant"
      print(paste("Subset", i, "marked as 'not relevant'."))
    }
  } 
  
  # Flatten the list
  all_subsets <- rrapply(all_subsets, classes = "data.frame", how = "flatten")
  print("Flattened all_subsets after processing:")
  print(all_subsets)
  
  new_index <- find_last_row_indices(df, all_subsets)
  print("New indices after processing:")
  print(new_index)
  
  # Check if all last row indices match last_row
  if (identical(new_index, index))  {
    print("Base case met: All last row indices match. Stopping recursion.")
    return(all_subsets)
  } else {
    print("Recursion needed: Indices do not match. Continuing recursion.")
    return(process_subsets(df, all_subsets))
  }
}

# Function to write dataframes to TSV files
write_dfs <- function(df, comb_number, directory) {
  print(paste("Writing dataframe", comb_number, "to directory:", directory))
  
  # Ensure the directory exists
  if (!dir.exists(directory)) {
    print(paste("Directory does not exist. Creating directory:", directory))
    dir.create(directory, recursive = TRUE)
  }
  
  # Extracting the values from the columns to create the file name
  chr_number <- df$chr[1]
  state_table <- df$state[1]
  anc_table_upper <- df$anc[1]
  anc_table <- tolower(anc_table_upper)
  
  # Creating the file name
  file_name <- paste0("chr_", chr_number, "_", anc_table, "_", state_table, "_comb_", comb_number, ".tsv")
  print(paste("Generated file name:", file_name))
  
  file_path <- file.path(directory, file_name)
  print(paste("Full file path:", file_path))
  
  # Writing the data frame to a TSV file
  tryCatch({
    write.table(df, file = file_path, sep = "\t", row.names = FALSE, col.names = TRUE)
    print(paste("Successfully wrote to", file_path))
  }, error = function(e){
    print(paste("Error writing to", file_path, ":", e$message))
  })
}

#################################################################################################

# Main script

# Add a debug statement to indicate the start of the script
print("Script started.")

args <- commandArgs(trailingOnly = TRUE)
print(paste("Command-line arguments received:", paste(args, collapse = ", ")))

# Ensure that the correct number of arguments are provided
if(length(args) < 3){
  stop("Insufficient arguments provided. Required: chr, state, anc.")
}

chr <- args[1]
state <- args[2]
anc <- args[3]
base_dir <- "/scratch/unifesp/pgt/liriel.almodobar"

print(paste("Parameters - chr:", chr, ", state:", state, ", anc:", anc))
print(paste("Base directory:", base_dir))

collapse_dir <- file.path(base_dir, "puzzle", state, anc, "chr_info_unfilt")
collapse_file <- paste0("chr_", chr, "_", anc, "_", state, "_unfilt.txt")
collapse_info_path <- file.path(collapse_dir, collapse_file)

print(paste("Collapse info file path:", collapse_info_path))

# Check if the file exists
if(!file.exists(collapse_info_path)){
  stop(paste("Collapse info file does not exist at path:", collapse_info_path))
}

# Read the collapse info
collapse_info <- read.table(collapse_info_path, header = FALSE, sep = "\t")[c(-5, -6)]
colnames(collapse_info) <- c("id", "chr", "first_bp", "last_bp", "anc", "state")
print("Collapse info dataframe loaded:")
print(head(collapse_info))

# Count overlaps and non-overlaps
overlap_non_overlap <- count_overlaps_and_non_overlaps(collapse_info)
overlap_blocks <- overlap_non_overlap[[1]]
non_overlap_rows <- overlap_non_overlap[[2]]
print(paste("Overlap blocks:", overlap_blocks, ", Non-overlapping rows:", non_overlap_rows))

min_val <- overlap_blocks
max_val <- overlap_blocks + non_overlap_rows
print(paste("min_val set to:", min_val, ", max_val set to:", max_val))

# Apply the function to generate subsets
all_subsets <- generate_subsets(collapse_info)

# Initialize a list to store the modified subsets
last_row <- nrow(collapse_info)
print(paste("Last row index set to:", last_row))

# Process subsets
all_subsets <- process_subsets(collapse_info, all_subsets)

# Define the directory to write the sequences
seq_directory <- file.path(collapse_dir, "seq_info")  # Specify your directory here
print(paste("Sequence directory set to:", seq_directory))

# Write all subsets to files
print("Starting to write all subsets to files.")
lapply(seq_along(all_subsets), function(i) {
  subset <- all_subsets[[i]]
  
  if (is.data.frame(subset)) {
    print(paste("Writing subset", i))
    write_dfs(subset, i, seq_directory)
  } else {
    print(paste("Subset", i, "is not a dataframe. Skipping write. Content:", subset))
  }
})

print("Script completed.")



