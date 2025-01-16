#!/bin/bash
LOG_DIR="/home/yuri/liri/puzzle/scripts"
# Function to check available disk space
check_disk_space() {
    # Check if there is more than 1 GB of available space
    available_space=$(df "$VCF_DIR" | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt 1048576 ]; then  # 1 GB in KB
        echo "Error: Insufficient disk space. Stopping the process." >> "$LOG_DIR/disk_space_error.log"
        exit 1
    fi
}

# Loop over chromosomes (1-22)
for CHR in {1..22}; do
    # Loop over states (you can modify this to match your state list or range)
    for STATE in "state1" "state2" "state3"; do
        # Before each iteration, check disk space
        check_disk_space
        
        # Call the genotype_files_nat.sh script
        echo "Processing chromosome $CHR and state $STATE..."
        /home/yuri/liri/puzzle/scripts/genotype_files_nat.sh "$CHR" "$STATE"

        # If no disk space issue, continue to the next state and chromosome
        echo "Completed processing for chromosome $CHR and state $STATE" >> "$LOG_DIR/processing.log"
    done
done
