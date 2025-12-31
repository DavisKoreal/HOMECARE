import 'package:flutter/material.dart';
class Routes {
  static const String login = '/login';
  static const String adminDashboard = '/admin_dashboard';
  static const String clientProfile = '/client_profile';
  static const String messages = '/messages';
  static const String careNotes = '/care_notes';
  static const String auditLog = '/audit_log';
  static const String paymentStatus = '/payment_status';
  static const String userProfile = '/user_profile';
  static const String caregiverDashboard = '/caregiver_dashboard';
  static const String familyPortal = '/family_portal';
  static const String clientList = '/client_list';
  static const String taskList = '/task_list';
  static const String emar = '/emar';
  static const String visitCheckIn = '/visit_check_in';
  static const String visitCheckOut = '/visit_check_out';
  static const String billingDashboard = '/billing_dashboard';
  static const String reportsDashboard = '/reports_dashboard';
  static const String shiftAssignment = '/shift_assignment';
  static const String payrollProcessing = '/payroll_processing';
  static const String invoiceGeneration = '/invoice_generation';
  static const String offlineMode = '/offline_mode';
  static const String shiftList = '/shift_list';
  static const String syncStatus = '/sync_status';
  static const String adminCalendar = '/admin_calendar';
  static const String caregiverCalendar = '/caregiver_calendar';
  static const String adminNotesManagement = '/admin_notes_management';
  static const String familyCareNotes = '/family_care_notes';
  static const String caregiverProfile = '/caregiver_profile';
  static const String clientViewShiftHistory = '/client_view_shift_history';
  static const String caregiverCompleteProfile = '/caregiver_complete_profile';
  static const String adminCaregiverApproval = '/admin_caregiver_approval';
  static const String adminInitiateShift = '/admin_initiate_shift';
  static const String adminAddClient = '/admin_add_client';
  static const String adminAddCaregiver = '/admin_add_caregiver';
}

import 'package:flutter/material.dart';

// Centralized Navigation Configuration to avoid repetition
class NavigationConfig {
  static const List<Map<String, dynamic>> sidebarItems = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'route': Routes.adminDashboard,
    },
    {
      'title': 'Calendar',
      'icon': Icons.calendar_today_outlined,
      'route': Routes.adminCalendar,
    },
    {
      'title': 'Shifts',
      'icon': Icons.schedule_outlined,
      'route': Routes.shiftAssignment,
    },
    {
      'title': 'Recipients',
      'icon': Icons.people_outline,
      'route': Routes.clientList,
    },
    {
      'title': 'Care Notes',
      'icon': Icons.event_note_outlined,
      'route': Routes.adminNotesManagement,
    },
    {
      'title': 'System',
      'icon': Icons.settings_outlined, // Changed to settings/system icon
      'route': Routes.auditLog,
    },
  ];
}
