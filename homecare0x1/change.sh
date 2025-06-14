#!/bin/bash

# Script to move provider files to lib/providers and update imports in homecare0x1 project
# Run from the project root: /home/davis/Desktop/flutter_apps/HOMECARE/homecare0x1

# Exit on error
set -e

# Project root directory
PROJECT_ROOT="$(pwd)"
BACKUP_DIR="${PROJECT_ROOT}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backups directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Function to backup a file if it exists
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${BACKUP_DIR}/$(basename "$file")_${TIMESTAMP}"
        echo "Backed up $file to ${BACKUP_DIR}/$(basename "$file")_${TIMESTAMP}"
    fi
}

echo "Starting process to move provider files to lib/providers..."

# Step 1: Create providers directory
echo "Creating lib/providers directory..."
mkdir -p lib/providers

# Step 2: Move provider files to lib/providers
echo "Moving provider files..."
for file in lib/care_note_provider.dart lib/medication_record_provider.dart lib/user_provider.dart; do
    if [ -f "$file" ]; then
        mv "$file" lib/providers/
        echo "Moved $file to lib/providers/"
    else
        echo "Warning: $file not found, skipping..."
    fi
done

# Step 3: Update import statements in all .dart files
echo "Updating import statements in Dart files..."
find lib -type f -name "*.dart" | while read -r file; do
    backup_file "$file"
    # Update imports using sed
    sed -i \
        -e "s|import 'package:homecare0x1/care_note_provider.dart'|import 'package:homecare0x1/providers/care_note_provider.dart'|g" \
        -e "s|import 'package:homecare0x1/medication_record_provider.dart'|import 'package:homecare0x1/providers/medication_record_provider.dart'|g" \
        -e "s|import 'package:homecare0x1/user_provider.dart'|import 'package:homecare0x1/providers/user_provider.dart'|g" \
        "$file"
    echo "Updated imports in $file"
done

# Step 4: Display updated directory structure
echo "Updated lib directory structure:"
ls -R lib

echo "Process complete!"
echo "Backups of modified files are stored in ${BACKUP_DIR}."
echo "Next steps:"
echo "1. Verify the app with 'flutter run' to ensure imports are correct."
echo "2. Check that CaregiverDashboardScreen, CareNotesScreen, and EmarScreen function as expected."
echo "3. If issues arise, restore backups from ${BACKUP_DIR}."

exit 0