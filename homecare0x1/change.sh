#!/bin/bash

# Script to update the homecare0x1 Flutter project with new providers and integrations
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

echo "Starting update process for homecare0x1 project..."

# Step 1: Update pubspec.yaml
echo "Updating pubspec.yaml..."
backup_file pubspec.yaml

cat > pubspec.yaml << 'EOF'
name: homecare0x1
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  permission_handler: ^11.3.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
EOF

# Step 2: Create care_note_provider.dart
echo "Creating lib/care_note_provider.dart..."
cat > lib/care_note_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/care_note.dart';

class CareNoteProvider with ChangeNotifier {
  List<CareNote> _notes = [
    CareNote(
      id: '1',
      clientId: '1',
      caregiverId: 'caregiver1',
      note: 'Client was in good spirits, assisted with mobility.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CareNote(
      id: '2',
      clientId: '1',
      caregiverId: 'caregiver1',
      note: 'Noticed slight fatigue, recommended rest.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<CareNote> get notes => _notes;

  void addNote(CareNote note) {
    _notes.insert(0, note);
    notifyListeners();
  }
}
EOF

# Step 3: Create medication_record_provider.dart
echo "Creating lib/medication_record_provider.dart..."
cat > lib/medication_record_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/medication_record.dart';

class MedicationRecordProvider with ChangeNotifier {
  List<MedicationRecord> _records = [
    MedicationRecord(
      id: '1',
      clientId: '1',
      medicationName: 'Aspirin',
      dosage: '100mg',
      administrationTime: DateTime.now().subtract(const Duration(hours: 2)),
      notes: 'Taken with water',
    ),
    MedicationRecord(
      id: '2',
      clientId: '1',
      medicationName: 'Lisinopril',
      dosage: '10mg',
      administrationTime: DateTime.now().subtract(const Duration(hours: 4)),
      notes: 'No side effects',
    ),
  ];

  List<MedicationRecord> get records => _records;

  void addRecord(MedicationRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }
}
EOF

# Step 4: Update main.dart
echo "Updating lib/main.dart..."
backup_file lib/main.dart

cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/screens/admin_dashboard.dart';
import 'package:homecare0x1/screens/audit_log_screen.dart';
import 'package:homecare0x1/screens/billing_dashboard.dart';
import 'package:homecare0x1/screens/care_notes_screen.dart';
import 'package:homecare0x1/screens/caregiver_dashboard.dart';
import 'package:homecare0x1/screens/client_list_screen.dart';
import 'package:homecare0x1/screens/client_profile_screen.dart';
import 'package:homecare0x1/screens/emar_screen.dart';
import 'package:homecare0x1/screens/family_portal_screen.dart';
import 'package:homecare0x1/screens/invoice_generation_screen.dart';
import 'package:homecare0x1/screens/login_screen.dart';
import 'package:homecare0x1/screens/messages_screen.dart';
import 'package:homecare0x1/screens/offline_mode_screen.dart';
import 'package:homecare0x1/screens/payment_status_screen.dart';
import 'package:homecare0x1/screens/payroll_processing_screen.dart';
import 'package:homecare0x1/screens/reports_dashboard.dart';
import 'package:homecare0x1/screens/shift_assignment_screen.dart';
import 'package:homecare0x1/screens/sync_status_screen.dart';
import 'package:homecare0x1/screens/task_list_screen.dart';
import 'package:homecare0x1/screens/user_profile_screen.dart';
import 'package:homecare0x1/screens/visit_check_in_screen.dart';
import 'package:homecare0x1/screens/visit_check_out_screen.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/user_provider.dart';
import 'package:homecare0x1/care_note_provider.dart';
import 'package:homecare0x1/medication_record_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const HomecareApp());
}

class HomecareApp extends StatelessWidget {
  const HomecareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CareNoteProvider()),
        ChangeNotifierProvider(create: (_) => MedicationRecordProvider()),
      ],
      child: MaterialApp(
        title: 'Homecare App',
        theme: AppTheme.theme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.login,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.login:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case Routes.adminDashboard:
              return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
            case Routes.caregiverDashboard:
              return MaterialPageRoute(builder: (_) => const CaregiverDashboardScreen());
            case Routes.familyPortal:
              return MaterialPageRoute(builder: (_) => const FamilyPortalScreen());
            case Routes.clientList:
              return MaterialPageRoute(builder: (_) => ClientListScreen());
            case Routes.clientProfile:
              return MaterialPageRoute(builder: (_) => const ClientProfileScreen());
            case Routes.taskList:
              return MaterialPageRoute(builder: (_) => const TaskListScreen());
            case Routes.messages:
              return MaterialPageRoute(builder: (_) => const MessagesScreen());
            case Routes.careNotes:
              return MaterialPageRoute(builder: (_) => const CareNotesScreen());
            case Routes.emar:
              return MaterialPageRoute(builder: (_) => const EmarScreen());
            case Routes.visitCheckIn:
              return MaterialPageRoute(builder: (_) => const VisitCheckInScreen());
            case Routes.visitCheckOut:
              return MaterialPageRoute(builder: (_) => const VisitCheckOutScreen());
            case Routes.billingDashboard:
              return MaterialPageRoute(builder: (_) => const BillingDashboardScreen());
            case Routes.reportsDashboard:
              return MaterialPageRoute(builder: (_) => const ReportsDashboardScreen());
            case Routes.auditLog:
              return MaterialPageRoute(builder: (_) => AuditLogScreen());
            case Routes.shiftAssignment:
              return MaterialPageRoute(builder: (_) => const ShiftAssignmentScreen());
            case Routes.payrollProcessing:
              return MaterialPageRoute(builder: (_) => const PayrollProcessingScreen());
            case Routes.invoiceGeneration:
              return MaterialPageRoute(builder: (_) => const InvoiceGenerationScreen());
            case Routes.paymentStatus:
              return MaterialPageRoute(builder: (_) => const PaymentStatusScreen());
            case Routes.userProfile:
              return MaterialPageRoute(builder: (_) => const UserProfileScreen());
            case Routes.offlineMode:
              return MaterialPageRoute(builder: (_) => const OfflineModeScreen());
            case Routes.syncStatus:
              return MaterialPageRoute(builder: (_) => const SyncStatusScreen());
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('Page not found: ${settings.name}'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
EOF

# Step 5: Update care_notes_screen.dart
echo "Updating lib/screens/care_notes_screen.dart..."
backup_file lib/screens/care_notes_screen.dart

cat > lib/screens/care_notes_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/care_note_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CareNotesScreen extends StatelessWidget {
  const CareNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final careNoteProvider = Provider.of<CareNoteProvider>(context);
    final notes = careNoteProvider.notes;

    return ModernScreenLayout(
      title: 'Care Notes',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Notes',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'View notes about client care',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            notes.isEmpty
                ? const Center(child: Text('No notes found'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(note.note),
                          subtitle: Text(
                            'Time: ${DateFormat('MMM d, h:mm a').format(note.timestamp)}',
                          ),
                          leading: Icon(Icons.note, color: AppTheme.primaryBlue),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Back to Check-In',
              icon: Icons.arrow_back,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Step 6: Update emar_screen.dart
echo "Updating lib/screens/emar_screen.dart..."
backup_file lib/screens/emar_screen.dart

cat > lib/screens/emar_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/medication_record.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:homecare0x1/medication_record_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EmarScreen extends StatelessWidget {
  const EmarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = Provider.of<MedicationRecordProvider>(context);
    final records = medicationProvider.records;

    return ModernScreenLayout(
      title: 'eMAR',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medication Administration',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'View medication records',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            records.isEmpty
                ? const Center(child: Text('No records found'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(record.medicationName),
                          subtitle: Text(
                            'Dosage: ${record.dosage}\nTime: ${DateFormat('MMM d, h:mm a').format(record.administrationTime)}\nNotes: ${record.notes}',
                          ),
                          leading: Icon(
                            Icons.medical_services,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Back to Check-In',
              icon: Icons.arrow_back,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Step 7: Update caregiver_dashboard_screen.dart
echo "Updating lib/screens/caregiver_dashboard.dart..."
backup_file lib/screens/caregiver_dashboard.dart

cat > lib/screens/caregiver_dashboard.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/user_provider.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/models/medication_record.dart';
import 'package:homecare0x1/care_note_provider.dart';
import 'package:homecare0x1/medication_record_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CaregiverDashboardScreen extends StatelessWidget {
  const CaregiverDashboardScreen({super.key});

  Future<bool> _confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _requestLocationPermission(BuildContext context) async {
    try {
      var status = await Permission.location.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        status = await Permission.location.request();
      }
      if (status.isGranted) {
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permission is required to check in'),
              action: status.isPermanentlyDenied
                  ? SnackBarAction(
                      label: 'Open Settings',
                      onPressed: () => openAppSettings(),
                    )
                  : null,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error accessing location permissions')),
        );
      }
      return false;
    }
  }

  Future<bool> _confirmCheckIn(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Check-In'),
            content: const Text('Do you want to check in for your visit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Check-In'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmCheckOut(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-Out'),
        content: const Text('Do you want to check out from your visit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Check-Out'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<String?> _addCareNote(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Care Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Enter care note or observation',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>?> _logMedication(BuildContext context) async {
    final TextEditingController medController = TextEditingController();
    final TextEditingController doseController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: medController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: doseController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (medController.text.trim().isNotEmpty &&
                  doseController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'medication': medController.text.trim(),
                  'dosage': doseController.text.trim(),
                  'notes': notesController.text.trim(),
                });
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _handleCheckIn(BuildContext context) async {
    final hasPermission = await _requestLocationPermission(context);
    if (!hasPermission || !context.mounted) return;

    final confirmed = await _confirmCheckIn(context);
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully checked in')),
      );
      Navigator.pushNamed(context, Routes.visitCheckIn);
    }
  }

  void _handleCheckOut(BuildContext context) async {
    final confirmed = await _confirmCheckOut(context);
    if (confirmed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully checked out')),
      );
      Navigator.pushNamed(context, Routes.visitCheckOut);
    }
  }

  void _handleAddCareNote(BuildContext context) async {
    final noteText = await _addCareNote(context);
    if (noteText != null && context.mounted) {
      final careNoteProvider = Provider.of<CareNoteProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      careNoteProvider.addNote(
        CareNote(
          id: (careNoteProvider.notes.length + 1).toString(),
          clientId: '1', // Mock client ID
          caregiverId: userProvider.user?.id ?? 'caregiver1',
          note: noteText,
          timestamp: DateTime.now(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Care note added successfully')),
      );
      Navigator.pushNamed(context, Routes.careNotes);
    }
  }

  void _handleLogMedication(BuildContext context) async {
    final medication = await _logMedication(context);
    if (medication != null && context.mounted) {
      final medicationProvider = Provider.of<MedicationRecordProvider>(context, listen: false);
      medicationProvider.addRecord(
        MedicationRecord(
          id: (medicationProvider.records.length + 1).toString(),
          clientId: '1', // Mock client ID
          medicationName: medication['medication']!,
          dosage: medication['dosage']!,
          administrationTime: DateTime.now(),
          notes: medication['notes'] ?? '',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication logged successfully')),
      );
      Navigator.pushNamed(context, Routes.emar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Caregiver';

    return ModernScreenLayout(
      title: 'Caregiver Dashboard',
      showBackButton: true,
      onBackPressed: () async {
        final shouldLogout = await _confirmLogout(context);
        if (shouldLogout && context.mounted) {
          userProvider.clearUser();
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your caregiving tasks for today',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Client List',
              subtitle: 'View clients',
              value: '5',
              change: '+1',
              isPositive: true,
              icon: Icons.person,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, Routes.clientList),
            ),
            DashboardCard(
              title: 'Task List',
              subtitle: 'View tasks',
              value: '3',
              change: '0',
              isPositive: true,
              icon: Icons.task,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => Navigator.pushNamed(context, Routes.taskList),
            ),
            DashboardCard(
              title: 'Messages',
              subtitle: 'View messages',
              icon: Icons.message,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, Routes.messages),
            ),
            DashboardCard(
              title: 'Check-In',
              subtitle: 'Start visit',
              icon: Icons.login,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => _handleCheckIn(context),
            ),
            DashboardCard(
              title: 'Check-Out',
              subtitle: 'End visit',
              icon: Icons.logout,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => _handleCheckOut(context),
            ),
            DashboardCard(
              title: 'Add Care Note',
              subtitle: 'Record observation',
              icon: Icons.note_add,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => _handleAddCareNote(context),
            ),
            DashboardCard(
              title: 'Log Medication',
              subtitle: 'Record medication',
              icon: Icons.medical_services,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => _handleLogMedication(context),
            ),
            DashboardCard(
              title: 'Tasks Completed',
              subtitle: 'View completed tasks',
              value: '8',
              change: '+2',
              isPositive: true,
              icon: Icons.check_circle,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, Routes.taskList),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Step 8: Run flutter pub get
echo "Running flutter pub get..."
flutter pub get

# Step 9: Provide instructions for platform-specific permissions
echo "Update complete! Please configure platform-specific permissions manually:"
echo "For Android:"
echo "  Add to android/app/src/main/AndroidManifest.xml:"
echo "    <uses-permission android:name=\"android.permission.ACCESS_FINE_LOCATION\" />"
echo "    <uses-permission android:name=\"android.permission.ACCESS_COARSE_LOCATION\" />"
echo "  Ensure minSdkVersion in android/app/build.gradle is at least 21."
echo "For iOS:"
echo "  Add to ios/Runner/Info.plist:"
echo "    <key>NSLocationWhenInUseUsageDescription</key>"
echo "    <string>We need your location to verify check-in for visits.</string>"
echo ""
echo "Next steps:"
echo "1. Test the app with 'flutter run'."
echo "2. Verify that care notes and medication records are added and displayed in CareNotesScreen and EmarScreen."
echo "3. Check that check-in requires location permission and navigates to VisitCheckInScreen."
echo "4. Ensure check-out navigates to VisitCheckOutScreen without permission prompt."
echo ""
echo "Backups of modified files are stored in ${BACKUP_DIR}."

exit 0