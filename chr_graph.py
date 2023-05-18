import sys
import os
import pandas as pd
from pygenomeviz import GenomeViz

# Extract the positions file name, label, and output path from the command-line arguments
positions_file = "nat/chr_1_nat_sort_filt_size_gap.txt"
label = "NAT"
output_path = "nat/"

# Read fragment positions from file using pandas
fragments_df = pd.read_table(positions_file, header=None)

# Extract the chromosome number, start, and end columns
chromosome = fragments_df.iloc[0, 1]
start_positions = fragments_df.iloc[:, 2]
end_positions = fragments_df.iloc[:, 3]

# Retrieve cytoband information using pygenome
genome_viewer = GenomeViz("hg38")
genome_viewer.add_chromosome(chromosome)

# Plot the fragments
for start, end in zip(start_positions, end_positions):
    genome_viewer.add_feature(chromosome, start, end, color="red")

# Set labels and title
genome_viewer.set_labels(xlabel="Chromosome Position (hg38)")
genome_viewer.set_title(f"Fragment Positions on {chromosome} - Label: {label}")

# Save the plot
output_file = os.path.join(output_path, f"fragment_positions_{chromosome}_{label}.png")
genome_viewer.save(output_file)

print("Chromosome visualization with fragment positions saved successfully!")