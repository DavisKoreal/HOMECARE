#!/bin/bash

# File to modify
FILE="lib/theme/app_theme.dart"
BACKUP_FILE="lib/theme/app_theme.dart.bak_$(date +%Y%m%d_%H%M%S)"

# Check if the file exists
if [ ! -f "$FILE" ]; then
  echo "Error: $FILE not found!"
  exit 1
fi

# Create a backup of the original file
cp "$FILE" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# Replace CardTheme with CardThemeData
sed -i 's/cardTheme: CardTheme(/cardTheme: CardThemeData(/' "$FILE"
echo "Applied fix: Replaced 'CardTheme(' with 'CardThemeData(' in $FILE"

# Run flutter clean to clear build artifacts
echo "Running flutter clean..."
flutter clean
if [ $? -eq 0 ]; then
  echo "flutter clean completed successfully."
else
  echo "Error: flutter clean failed!"
  exit 1
fi

# Run flutter pub get to ensure dependencies are resolved
echo "Running flutter pub get..."
flutter pub get
if [ $? -eq 0 ]; then
  echo "flutter pub get completed successfully."
else
  echo "Error: flutter pub get failed!"
  exit 1
fi

# Optionally run flutter run to test the fix (targeting Linux)
echo "Running flutter run on Linux..."
flutter run -d linux
if [ $? -eq 0 ]; then
  echo "flutter run completed successfully."
else
  echo "Error: flutter run failed! Check the output for details."
  exit 1
fi

echo "Script completed. Please verify the app runs correctly."