check_overlap <- function(row_1, row_2){
  last_bp_row_1 <- row_1["Column2"]
  first_bp_row_2 <- row_2["Column1"]
  if(!is.na(first_bp_row_2) && last_bp_row_1 > first_bp_row_2) {
    overlapping_rows <- list(row_1, row_2)
    return(overlapping_rows)
  } else {
    return(NULL)
  }
}

subset_dataframe <- function(df, row_A_index, df2 = NULL) {
  # Get the value of the second column for row A
  x <- df[row_A_index, "Column2"]
  
  # Find values from the first column greater than x
  y_values <- subset(df, df$Column1 > x)
  
  # See if there is overlaps in y values
  if(nrow(y_values) != 0){
    row_1 <- y_values[1,]
    print(row_1)
    row_2 <- y_values[2,]
    print(row_2)
      overlap_result <- check_overlap(row_1, row_2)
  } else {
      overlap_result <- NULL
    }
   
 
  
  # Determine y rows to be analysed
    
    
    if(length(overlap_result) == 0 && exists("row_1")) {
      only_y_row <- row_1
    } else {
      y_rows <- overlap_result  
    }
  
  # Initialize an empty list to store subsets
  subset_list <- list()

  if (!is.null(df2) && nrow(y_values) == 0) {
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

# Example usage:
# Create a sample dataframe (replace this with your actual dataframe)
df <- data.frame(
  Column1 = c(1, 2, 3, 19, 20, 27, 35, 35, 40, 60, 90),
  Column2 = c(10, 18, 18, 25, 26, 30, 40, 39, 50, 90, 100) 
) 

# Apply the function to generate subsets
all_subsets <- generate_subsets(df)

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


#index <- find_last_row_indices(df, all_subsets)

# Initialize a list to store the modified subsets
#modified_subsets <- list()
last_row <- nrow(df)
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
 #     modified_subset <- modified_subset[[1]]
      
      # Update the original all_subsets with the modified subset
      all_subsets[[i]] <- modified_subset
    }
  } 
  all_subsets <- unlist(all_subsets, recursive = FALSE)
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

all_subsets <- process_subsets(df, all_subsets)
  
