#!/bin/bash

# Define the project directory
PROJECT_DIR="/home/davis/Desktop/flutter_apps/homecare0x1"
LIB_DIR="$PROJECT_DIR/lib"
SCREENS_DIR="$LIB_DIR/screens"

# Fix screen files to use correct class names
declare -a SCREENS=(
  "login_screen.dart:LoginScreen"
  "user_profile_screen.dart:UserProfileScreen"
  "admin_dashboard.dart:AdminDashboardScreen"
  "client_list_screen.dart:ClientListScreen"
  "client_profile_screen.dart:ClientProfileScreen"
  "shift_assignment_screen.dart:ShiftAssignmentScreen"
  "billing_dashboard.dart:BillingDashboardScreen"
  "invoice_generation_screen.dart:InvoiceGenerationScreen"
  "payroll_processing_screen.dart:PayrollProcessingScreen"
  "reports_dashboard.dart:ReportsDashboardScreen"
  "audit_log_screen.dart:AuditLogScreen"
  "caregiver_dashboard.dart:CaregiverDashboardScreen"
  "schedule_overview_screen.dart:ScheduleOverviewScreen"
  "visit_check_in_screen.dart:VisitCheckInScreen"
  "task_list_screen.dart:TaskListScreen"
  "emar_screen.dart:EmarScreen"
  "care_notes_screen.dart:CareNotesScreen"
  "visit_check_out_screen.dart:VisitCheckOutScreen"
  "family_portal_screen.dart:FamilyPortalScreen"
  "messages_screen.dart:MessagesScreen"
  "payment_status_screen.dart:PaymentStatusScreen"
  "offline_mode_screen.dart:OfflineModeScreen"
  "sync_status_screen.dart:SyncStatusScreen"
)

for SCREEN in "${SCREENS[@]}"; do
  FILE=$(echo "$SCREEN" | cut -d':' -f1)
  CLASS_NAME=$(echo "$SCREEN" | cut -d':' -f2)
  cat > "$SCREENS_DIR/$FILE" <<EOL
import 'package:flutter/material.dart';

class $CLASS_NAME extends StatelessWidget {
  const $CLASS_NAME({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$CLASS_NAME'),
      ),
      body: Center(
        child: Text('Welcome to $CLASS_NAME'),
      ),
    );
  }
}
EOL
  echo "Fixed $SCREENS_DIR/$FILE with class $CLASS_NAME"
done

# Update main.dart to fix routes and syntax
cat > "$LIB_DIR/main.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/screens/login_screen.dart';
import 'package:homecare0x1/screens/user_profile_screen.dart';
import 'package:homecare0x1/screens/admin_dashboard.dart';
import 'package:homecare0x1/screens/client_list_screen.dart';
import 'package:homecare0x1/screens/client_profile_screen.dart';
import 'package:homecare0x1/screens/shift_assignment_screen.dart';
import 'package:homecare0x1/screens/billing_dashboard.dart';
import 'package:homecare0x1/screens/invoice_generation_screen.dart';
import 'package:homecare0x1/screens/payroll_processing_screen.dart';
import 'package:homecare0x1/screens/reports_dashboard.dart';
import 'package:homecare0x1/screens/audit_log_screen.dart';
import 'package:homecare0x1/screens/caregiver_dashboard.dart';
import 'package:homecare0x1/screens/schedule_overview_screen.dart';
import 'package:homecare0x1/screens/visit_check_in_screen.dart';
import 'package:homecare0x1/screens/task_list_screen.dart';
import 'package:homecare0x1/screens/emar_screen.dart';
import 'package:homecare0x1/screens/care_notes_screen.dart';
import 'package:homecare0x1/screens/visit_check_out_screen.dart';
import 'package:homecare0x1/screens/family_portal_screen.dart';
import 'package:homecare0x1/screens/messages_screen.dart';
import 'package:homecare0x1/screens/payment_status_screen.dart';
import 'package:homecare0x1/screens/offline_mode_screen.dart';
import 'package:homecare0x1/screens/sync_status_screen.dart';
import 'package:homecare0x1/user_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homecare Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: Routes.login,
      routes: {
        Routes.login: (context) => const LoginScreen(),
        Routes.userProfile: (context) => const UserProfileScreen(),
        Routes.adminDashboard: (context) => const AdminDashboardScreen(),
        Routes.clientList: (context) => const ClientListScreen(),
        Routes.clientProfile: (context) => const ClientProfileScreen(),
        Routes.shiftAssignment: (context) => const ShiftAssignmentScreen(),
        Routes.billingDashboard: (context) => const BillingDashboardScreen(),
        Routes.invoiceGeneration: (context) => const InvoiceGenerationScreen(),
        Routes.payrollProcessing: (context) => const PayrollProcessingScreen(),
        Routes.reportsDashboard: (context) => const ReportsDashboardScreen(),
        Routes.auditLog: (context) => const AuditLogScreen(),
        Routes.caregiverDashboard: (context) => const CaregiverDashboardScreen(),
        Routes.scheduleOverview: (context) => const ScheduleOverviewScreen(),
        Routes.visitCheckIn: (context) => const VisitCheckInScreen(),
        Routes.taskList: (context) => const TaskListScreen(),
        Routes.emar: (context) => const EmarScreen(),
        Routes.careNotes: (context) => const CareNotesScreen(),
        Routes.visitCheckOut: (context) => const VisitCheckOutScreen(),
        Routes.familyPortal: (context) => const FamilyPortalScreen(),
        Routes.messages: (context) => const MessagesScreen(),
        Routes.paymentStatus: (context) => const PaymentStatusScreen(),
        Routes.offlineMode: (context) => const OfflineModeScreen(),
        Routes.syncStatus: (context) => const SyncStatusScreen(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Page Not Found')),
          ),
        );
      },
    );
  }
}
EOL
echo "Updated $LIB_DIR/main.dart"

# Verify provider dependency in pubspec.yaml
if ! grep -q "provider:" "$PROJECT_DIR/pubspec.yaml"; then
  sed -i '/dependencies:/a\  provider: ^6.1.0' "$PROJECT_DIR/pubspec.yaml"
  echo "Added provider to pubspec.yaml"
else
  echo "Provider already in pubspec.yaml"
fi

# Run flutter pub get to fetch dependencies
cd "$PROJECT_DIR"
flutter pub get
echo "Ran flutter pub get"

echo "Fix complete! You can now run the app with 'flutter run'."