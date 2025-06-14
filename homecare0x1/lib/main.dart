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
      debugShowCheckedModeBanner: false,
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
        Routes.clientList: (context) => ClientListScreen(),
        Routes.clientProfile: (context) => const ClientProfileScreen(),
        Routes.shiftAssignment: (context) => const ShiftAssignmentScreen(),
        Routes.billingDashboard: (context) => const BillingDashboardScreen(),
        Routes.invoiceGeneration: (context) => const InvoiceGenerationScreen(),
        Routes.payrollProcessing: (context) => const PayrollProcessingScreen(),
        Routes.reportsDashboard: (context) => const ReportsDashboardScreen(),
        Routes.auditLog: (context) => const AuditLogScreen(),
        Routes.caregiverDashboard: (context) =>
            const CaregiverDashboardScreen(),
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
