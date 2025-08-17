import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/providers/care_note_provider.dart';
import 'package:homecare0x1/providers/location_provider.dart';
import 'package:homecare0x1/providers/medication_record_provider.dart';
import 'package:homecare0x1/providers/payment_provider.dart';
import 'package:homecare0x1/providers/shift_assignment_provider.dart';
import 'package:homecare0x1/providers/task_provider.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:homecare0x1/screens/admin_calendar_screen.dart';
import 'package:homecare0x1/screens/admin_dashboard.dart';
import 'package:homecare0x1/screens/admin_notes_management_screen.dart';
import 'package:homecare0x1/screens/audit_log_screen.dart';
import 'package:homecare0x1/screens/care_notes_screen.dart';
import 'package:homecare0x1/screens/caregiver_calendar_screen.dart';
import 'package:homecare0x1/screens/caregiver_dashboard.dart';
import 'package:homecare0x1/screens/caregiver_profile.dart';
import 'package:homecare0x1/screens/client_list_screen.dart';
import 'package:homecare0x1/screens/client_profile_screen.dart';
import 'package:homecare0x1/screens/client_view_shift_history.dart';
import 'package:homecare0x1/screens/emar_screen.dart';
import 'package:homecare0x1/screens/family_care_notes.dart';
import 'package:homecare0x1/screens/family_portal_screen.dart';
import 'package:homecare0x1/screens/invoice_generation_screen.dart';
import 'package:homecare0x1/screens/login_screen.dart';
import 'package:homecare0x1/screens/payment_status.dart';
import 'package:homecare0x1/screens/shift_assignment_screen.dart';
import 'package:homecare0x1/screens/shift_list_screen.dart';
import 'package:homecare0x1/screens/task_list_screen.dart';
import 'package:homecare0x1/screens/user_profile_screen.dart';
import 'package:homecare0x1/screens/visit_check_in_screen.dart';
import 'package:homecare0x1/screens/visit_check_out_screen.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize mock data in Firestore
  await setupMockData();

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
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'Homecare App',
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.login,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case Routes.login:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case Routes.adminDashboard:
              return MaterialPageRoute(
                  builder: (_) => const AdminDashboardScreen());
            case Routes.caregiverDashboard:
              return MaterialPageRoute(
                  builder: (_) => const CaregiverDashboardScreen());
            case Routes.familyPortal:
              return MaterialPageRoute(
                  builder: (_) => const FamilyPortalScreen());
            case Routes.clientList:
              return MaterialPageRoute(
                  builder: (_) => const ClientListScreen());
            case Routes.clientProfile:
              return MaterialPageRoute(
                  builder: (_) => const ClientProfileScreen());
            case Routes.taskList:
              return MaterialPageRoute(builder: (_) => const TaskListScreen());
            case Routes.careNotes:
              return MaterialPageRoute(builder: (_) => const CareNotesScreen());
            case Routes.emar:
              return MaterialPageRoute(builder: (_) => const EmarScreen());
            case Routes.paymentStatus:
              return MaterialPageRoute(
                  builder: (_) => const PaymentStatusScreen());
            case Routes.visitCheckIn:
              return MaterialPageRoute(
                  builder: (_) => const VisitCheckInScreen());
            case Routes.visitCheckOut:
              return MaterialPageRoute(
                  builder: (_) => const VisitCheckOutScreen());
            case Routes.auditLog:
              return MaterialPageRoute(builder: (_) => const AuditLogScreen());
            case Routes.shiftAssignment:
              return MaterialPageRoute(
                  builder: (_) => const ShiftAssignmentScreen());
            case Routes.invoiceGeneration:
              return MaterialPageRoute(
                  builder: (_) => const InvoiceGenerationScreen());
            case Routes.userProfile:
              return MaterialPageRoute(
                  builder: (_) => const UserProfileScreen());
            case Routes.shiftList:
              return MaterialPageRoute(
                  builder: (_) => ShiftListScreen(
                      selectedDay: settings.arguments as DateTime));
            case Routes.adminCalendar:
              return MaterialPageRoute(
                  builder: (_) => const AdminCalendarScreen());
            case Routes.adminNotesManagement:
              return MaterialPageRoute(
                  builder: (_) => const AdminNotesManagementScreen());
            case Routes.familyCareNotes:
              return MaterialPageRoute(
                  builder: (_) => const FamilyCareNotesScreen());
            case Routes.caregiverProfile:
              return MaterialPageRoute(
                  builder: (_) => const CaregiverProfileScreen());
            case Routes.caregiverCalendar:
              return MaterialPageRoute(
                  builder: (_) => const CaregiverCalendarScreen());
            case Routes.clientViewShiftHistory:
              return MaterialPageRoute(
                  builder: (_) => const ClientViewShiftHistoryScreen());
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