import 'package:homecare0x1/screens/schedule/day_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/widgets/dashboard_shell.dart';
import 'package:homecare0x1/theme/app_theme.dart';

// Import All Screens
import 'package:homecare0x1/screens/admin_overview_view.dart';
import 'package:homecare0x1/screens/admin_calendar_screen.dart';
import 'package:homecare0x1/screens/shift_assignment_screen.dart';
import 'package:homecare0x1/screens/client_list_screen.dart';
import 'package:homecare0x1/screens/admin_notes_management_screen.dart';
import 'package:homecare0x1/screens/audit_log_screen.dart';
import 'package:homecare0x1/screens/admin_initiate_shift.dart';
import 'package:homecare0x1/screens/admin_add_client.dart';
import 'package:homecare0x1/screens/admin_add_caregiver.dart';
import 'package:homecare0x1/screens/admin_caregiver_approval.dart';
import 'package:homecare0x1/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // State: The currently active route in the content area
  String _currentRoute = Routes.adminDashboard;

  // Method to switch views
  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  // Handle Android/Browser Back Button
  Future<bool> _onWillPop() async {
    if (_currentRoute != Routes.adminDashboard) {
      // If not on Overview, go back to Overview
      _navigateTo(Routes.adminDashboard);
      return false; // Prevent app exit
    }
    return true; // Allow app exit (or return to login if it was previous)
  }

  @override
  Widget build(BuildContext context) {
    // Using WillPopScope to intercept the back button
    return WillPopScope(
      onWillPop: _onWillPop,
      child: DashboardShell(
        title: _getTitleForRoute(_currentRoute),
        activeRoute: _currentRoute,
        onNavigate: _navigateTo, 
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
            onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
          ),
        ],
        content: _getViewForRoute(_currentRoute),
      ),
    );
  }

  String _getTitleForRoute(String route) {
    switch (route) {
      case Routes.adminDashboard: return 'Overview';
      case Routes.adminCalendar: return 'Calendar';
      case Routes.shiftAssignment: return 'Shift Assignments';
      case Routes.clientList: return 'Recipients';
      case Routes.adminNotesManagement: return 'Care Notes';
      case Routes.auditLog: return 'System Logs';
      case Routes.adminInitiateShift: return 'New Shift';
      case Routes.adminAddClient: return 'Add Recipient';
      case Routes.adminAddCaregiver: return 'Add Staff';
      case Routes.adminCaregiverApproval: return 'Staff Approval';
      case Routes.daySchedule: return 'Schedule Builder';
      case Routes.daySchedule:
        return const DayScheduleScreen();

      default: return 'HomeCare';
    }
  }

  Widget _getViewForRoute(String route) {
    switch (route) {
      case Routes.adminDashboard:
        return AdminOverviewView(onNavigate: _navigateTo);
        
      case Routes.adminCalendar:
        return const AdminCalendarScreen();
        
      case Routes.shiftAssignment:
        return const ShiftAssignmentScreen();
        
      case Routes.clientList:
        return const ClientListScreen();
        
      case Routes.adminNotesManagement:
        return const AdminNotesManagementScreen();
        
      case Routes.auditLog:
        return const AuditLogScreen();

      case Routes.adminInitiateShift:
        return AdminInitiateShift(onBack: () => _navigateTo(Routes.adminDashboard));

      case Routes.adminAddClient:
        return AdminAddClientScreen(onBack: () => _navigateTo(Routes.adminDashboard));

      case Routes.adminAddCaregiver:
        return AdminAddCaregiverPage(onBack: () => _navigateTo(Routes.adminDashboard));

      case Routes.adminCaregiverApproval:
        final adminId = Provider.of<UserProvider>(context, listen: false).user?.id ?? '';
        return AdminCaregiverApprovalPage(adminId: adminId);

      case Routes.daySchedule:
        return const DayScheduleScreen();

      default:
        // Fallback to Overview if route is unknown, solving "Page not found"
        return AdminOverviewView(onNavigate: _navigateTo);
    }
  }
}
