# Import the required libraries
import pyGenomeTracks as pygt
import pandas as pd

# Read the data file
data = pd.read_table("nat/chr_1_nat_sort_filt_size_gap.txt", header=None)

# Extract the chromosome from your data (assuming all values in the second column are the same)
chromosome = data.iloc[0, 1]

# Create a new track configuration
config = pygt.TrackConfig()
config.add_track("axis")
config.add_track("line", chromosome=chromosome, color="blue", linewidth=1)

# Add genomic regions to the track
for _, row in data.iterrows():
    start = row[2]
    end = row[3]
    config.add_region(chromosome, start, end)

# Plot the genome tracks
pygt.tracks.plot_tracks([config])
