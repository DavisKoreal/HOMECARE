#!/bin/bash

# Script to update TaskListScreen in homecare0x1 project
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

echo "Starting process to update TaskListScreen..."

# Step 1: Create task_provider.dart
echo "Creating lib/providers/task_provider.dart..."
mkdir -p lib/providers
cat > lib/providers/task_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Check Vitals',
      dueDate: DateTime.now().add(const Duration(hours: 2)),
      isCompleted: false,
      clientId: '1',
      clientName: 'John Doe',
      description: 'Check blood pressure and heart rate',
    ),
    Task(
      id: '2',
      title: 'Medication Admin',
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      isCompleted: true,
      clientId: '1',
      clientName: 'John Doe',
      description: 'Administer morning medications',
    ),
    Task(
      id: '3',
      title: 'Physical Therapy',
      dueDate: DateTime.now().add(const Duration(hours: 6)),
      isCompleted: false,
      clientId: '2',
      clientName: 'Jane Smith',
      description: 'Assist with mobility exercises',
    ),
    Task(
      id: '4',
      title: 'Meal Prep',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      isCompleted: false,
      clientId: '3',
      clientName: 'Alice Johnson',
      description: 'Prepare lunch and dinner',
    ),
  ];

  List<Task> get tasks => _tasks;

  void toggleTaskCompletion(String taskId) {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.isCompleted = !task.isCompleted;
    notifyListeners();
  }
}
EOF

# Step 2: Update task.dart model to include clientName
echo "Updating lib/models/task.dart..."
backup_file lib/models/task.dart

cat > lib/models/task.dart << 'EOF'
class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  bool isCompleted;
  final String clientId;
  final String clientName;
  final String description;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.isCompleted,
    required this.clientId,
    required this.clientName,
    required this.description,
  });
}
EOF

# Step 3: Update task_list_screen.dart
echo "Updating lib/screens/task_list_screen.dart..."
backup_file lib/screens/task_list_screen.dart

cat > lib/screens/task_list_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/task_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final tasks = taskProvider.tasks;

    return ModernScreenLayout(
      title: 'Task List',
      showBackButton: true,
      onBackPressed: () => Navigator.pushReplacementNamed(
        context,
        userProvider.getInitialRoute(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Tasks',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage your assigned tasks.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.neutral600,
                  ),
            ),
            const SizedBox(height: 24),
            tasks.isEmpty
                ? const Center(child: Text('No tasks assigned'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) {
                              taskProvider.toggleTaskCompletion(task.id);
                            },
                            activeColor: AppTheme.successGreen,
                          ),
                          title: Text(
                            task.title,
                            style:
                                Theme.of(context).textTheme.titleMedium?.copyWith(
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Client: ${task.clientName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.neutral600,
                                    ),
                              ),
                              Text(
                                'Due: ${DateFormat('MMM d, h:mm a').format(task.dueDate)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.neutral600,
                                    ),
                              ),
                              Text(
                                task.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.neutral600,
                                    ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.task,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Back to Dashboard',
              icon: Icons.arrow_back,
              isOutlined: true,
              width: double.infinity,
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                userProvider.getInitialRoute(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Step 4: Update main.dart to include TaskProvider
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
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/providers/care_note_provider.dart';
import 'package:homecare0x1/providers/medication_record_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/task_provider.dart';
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
        ChangeNotifierProvider(create: (_) => ShiftAssignmentProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
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

# Step 5: Display updated file info
echo "Updated files:"
echo "- lib/providers/task_provider.dart (new)"
echo "- lib/models/task.dart"
echo "- lib/screens/task_list_screen.dart"
echo "- lib/main.dart"

# Step 6: Provide next steps
echo "Process complete!"
echo "Backups of modified files are stored in ${BACKUP_DIR}."
echo "Next steps:"
echo "1. Run 'flutter pub get' to ensure dependencies (intl, provider) are installed."
echo "2. Perform a hot restart (not hot reload) to apply provider changes:"
echo "   - Run 'flutter run' or press 'R' in the terminal while the app is running."
echo "3. Test the TaskListScreen:"
echo "   - Navigate to TaskListScreen from CaregiverDashboardScreen."
echo "   - Verify that tasks display with client names, due dates, and descriptions."
echo "   - Toggle task completion with the Checkbox and confirm UI updates."
echo "   - Ensure the back button and ModernButton navigate to the appropriate dashboard."
echo "   - Check styling matches ClientListScreen (e.g., Card, typography, colors)."
echo "4. If issues arise, restore backups from ${BACKUP_DIR}."
echo "5. Ensure pubspec.yaml includes 'intl: ^0.19.0' and 'provider: ^6.0.5'."

exit 0