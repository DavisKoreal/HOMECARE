#!/bin/bash

# Script: apply_changes.sh
# Purpose: Fix RenderFlex overflow in family_portal_screen.dart by adjusting GridView childAspectRatio and maintain routing fixes in homecare0x1 project

# Define project directory
PROJECT_DIR="$(pwd)"
CONSTANTS_FILE="$PROJECT_DIR/lib/constants.dart"
FAMILY_PORTAL_FILE="$PROJECT_DIR/lib/screens/family_portal_screen.dart"
PRINT_SCRIPT="$PROJECT_DIR/print.sh"

# Step 1: Backup existing constants.dart
if [ -f "$CONSTANTS_FILE" ]; then
    echo "Backing up existing $CONSTANTS_FILE to $CONSTANTS_FILE.bak"
    cp "$CONSTANTS_FILE" "$CONSTANTS_FILE.bak"
fi

# Step 2: Write updated constants.dart with all required routes
echo "Updating $CONSTANTS_FILE with corrected Routes class"
cat > "$CONSTANTS_FILE" << 'EOF'
class Routes {
  static const String login = '/login';
  static const String adminDashboard = '/admin_dashboard';
  static const String caregiverDashboard = '/caregiver_dashboard';
  static const String familyPortal = '/family_portal';
  static const String clientList = '/client_list';
  static const String clientProfile = '/client_profile';
  static const String taskList = '/task_list';
  static const String messages = '/messages';
  static const String careNotes = '/care_notes';
  static const String emar = '/emar';
  static const String visitCheckIn = '/visit_check_in';
  static const String visitCheckOut = '/visit_check_out';
  static const String billingDashboard = '/billing_dashboard';
  static const String reportsDashboard = '/reports_dashboard';
  static const String auditLog = '/audit_log';
  static const String shiftAssignment = '/shift_assignment';
  static const String payrollProcessing = '/payroll_processing';
  static const String invoiceGeneration = '/invoice_generation';
  static const String paymentStatus = '/payment_status';
  static const String userProfile = '/user_profile';
  static const String offlineMode = '/offline_mode';
  static const String syncStatus = '/sync_status';
  static const String shiftManagement = '/shift_management';
  static const String clientDirectory = '/client_directory';
  static const String systemAudit = '/system_audit';
}
EOF

# Step 3: Backup existing family_portal_screen.dart
if [ -f "$FAMILY_PORTAL_FILE" ]; then
    echo "Backing up existing $FAMILY_PORTAL_FILE to $FAMILY_PORTAL_FILE.bak"
    cp "$FAMILY_PORTAL_FILE" "$FAMILY_PORTAL_FILE.bak"
else
    echo "Error: $FAMILY_PORTAL_FILE not found"
    exit 1
fi

# Step 4: Modify family_portal_screen.dart to adjust GridView childAspectRatio
echo "Modifying $FAMILY_PORTAL_FILE to adjust GridView childAspectRatio"
if ! command -v sed >/dev/null 2>&1; then
    echo "Error: sed command not found. Please install sed."
    exit 1
fi

# Update childAspectRatio in GridView.count (around line 374)
sed -i 's/childAspectRatio: 0.85/childAspectRatio: 0.65/g' "$FAMILY_PORTAL_FILE"

# Step 5: Write updated print.sh
echo "Updating $PRINT_SCRIPT"
cat > "$PRINT_SCRIPT" << 'EOF'
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
EOF

# Step 6: Make print.sh executable
echo "Making $PRINT_SCRIPT executable"
chmod +x "$PRINT_SCRIPT"

# Step 7: Run print.sh to generate updated state.txt
echo "Running $PRINT_SCRIPT to generate state.txt"
./print.sh

# Step 8: Verify changes
if [ -f "$CONSTANTS_FILE" ]; then
    echo "Successfully updated $CONSTANTS_FILE"
else
    echo "Error: Failed to update $CONSTANTS_FILE"
    exit 1
fi

if [ -f "$FAMILY_PORTAL_FILE" ]; then
    echo "Successfully updated $FAMILY_PORTAL_FILE"
else
    echo "Error: Failed to update $FAMILY_PORTAL_FILE"
    exit 1
fi

if [ -f "$PROJECT_DIR/state.txt" ]; then
    echo "Successfully generated state.txt with updated .dart files"
else
    echo "Error: Failed to generate state.txt"
    exit 1
fi

echo "Changes applied successfully! You can now run 'flutter run' to test the app."
echo "Note: If the overflow error persists, please share the output of 'flutter run' and the updated state.txt."