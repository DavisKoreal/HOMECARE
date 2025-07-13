#!/bin/bash

# Script: print.sh
# Purpose: Recursively find all .dart files and print their contents to state.txt

# Define project directory
PROJECT_DIR="$(pwd)"
OUTPUT_FILE="$PROJECT_DIR/state.txt"

# Clear state.txt if it exists
> "$OUTPUT_FILE"

# Find all .dart files, sort them, and print their contents to state.txt
echo "Finding all .dart files and printing contents..."
find "$PROJECT_DIR" -type f -name "*.dart" | sort | while read -r file; do
    echo "=== $file ===" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo -e "\n" >> "$OUTPUT_FILE"
done

echo "Contents of .dart files written to $OUTPUT_FILE"
