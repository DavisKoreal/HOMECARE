#!/bin/bash

# Output file
output="directory.txt"

# Clear or create the output file
> "$output"

# Find all directories containing .dart or .yaml files
find . -type d | while read -r dir; do
    # Find matching files in this directory
    files=$(find "$dir" -maxdepth 1 -type f \( -name "*.dart" -o -name "*.yaml" \) -exec basename {} \; | sort)
    
    # If there are matching files in this directory
    if [ -n "$files" ]; then
        # Print directory header
        echo "directory: ${dir#./}" >> "$output"
        
        # Print each file with indentation
        echo "$files" | while read -r file; do
            echo "    |---$file" >> "$output"
        done
        
        # Add empty line between directories
        echo >> "$output"
    fi
done

echo "Directory structure has been saved to $output"