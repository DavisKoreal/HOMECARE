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
