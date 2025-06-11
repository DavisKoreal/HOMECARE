#!/bin/bash

# Check if directory is provided as argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Check if the provided argument is a valid directory
if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a valid directory"
    exit 1
fi

# Define common source file extensions, including .dart
# Add or remove extensions as needed
source_extensions=("*.dart")

# Iterate through source file extensions
for ext in "${source_extensions[@]}"; do
    # Find and process each source file
    find "$1" -type f -name "$ext" -exec sh -c '
        for file; do
            echo "===== $file ====="
            cat "$file"
            echo -e "\n"
        done
    ' sh {} +
done