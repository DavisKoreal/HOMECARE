#!/bin/bash

# Define the project directory
PROJECT_DIR="/home/davis/Desktop/flutter_apps/homecare0x1"
LIB_DIR="$PROJECT_DIR/lib"
SCREENS_DIR="$LIB_DIR/screens"
MODELS_DIR="$LIB_DIR/models"

# Ensure directories exist
mkdir -p "$SCREENS_DIR" "$MODELS_DIR"

# Function to check if a file exists and report
check_file() {
  if [ ! -f "$1" ]; then
    echo "Error: $1 is missing!"
    exit 1
  fi
}

# Update LoginScreen
cat > "$SCREENS_DIR/login_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/user.dart';
import 'package:homecare0x1/user_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to LoginScreen'),
            const SizedBox(height: 10),
            const Text(
              'Sign in with your credentials to access your role-specific dashboard.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                String role = emailController.text.contains('admin') ? 'admin' :
                              emailController.text.contains('caregiver') ? 'caregiver' : 'family';
                userProvider.setUser(User(id: emailController.text, role: role));
                Navigator.pushReplacementNamed(context, userProvider.getLastRoute());
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/login_screen.dart"
echo "Updated LoginScreen with description"

# Update UserProfileScreen
cat > "$SCREENS_DIR/user_profile_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to UserProfileScreen'),
            const SizedBox(height: 10),
            const Text(
              'View and edit your profile details (e.g., name, email, contact info).',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, userProvider.getLastRoute()),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
    }
}
EOL
check_file "$SCREENS_DIR/user_profile_screen.dart"
echo "Updated UserProfileScreen with description and navigation"

# Update AdminDashboardScreen
cat > "$SCREENS_DIR/admin_dashboard.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('Welcome to AdminDashboardScreen'),
            const SizedBox(height: 10),
            const Text(
              'Central hub for managing clients, shifts, staff, billing, and reports.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.clientList),
              child: const Text('Manage Clients'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.shiftAssignment),
              child: const Text('Assign Shifts'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.billingDashboard),
              child: const Text('View Billing'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.reportsDashboard),
              child: const Text('View Reports'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/admin_dashboard.dart"
echo "Updated AdminDashboardScreen with description and navigation"

# Update ClientListScreen
cat > "$SCREENS_DIR/client_list_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client List')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ClientListScreen'),
            const SizedBox(height: 10),
            const Text(
              'View a list of all clients or add a new client.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.clientProfile),
              child: const Text('View Client Profile'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/client_list_screen.dart"
echo "Updated ClientListScreen with description and navigation"

# Update ClientProfileScreen
cat > "$SCREENS_DIR/client_profile_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Client Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ClientProfileScreen'),
            const SizedBox(height: 10),
            const Text(
              'View and edit detailed client information, including care plans.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Client List'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/client_profile_screen.dart"
echo "Updated ClientProfileScreen with description and navigation"

# Update ShiftAssignmentScreen
cat > "$SCREENS_DIR/shift_assignment_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class ShiftAssignmentScreen extends StatelessWidget {
  const ShiftAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shift Assignment')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ShiftAssignmentScreen'),
            const SizedBox(height: 10),
            const Text(
              'Assign caregivers to client shifts based on availability.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/shift_assignment_screen.dart"
echo "Updated ShiftAssignmentScreen with description and navigation"

# Update BillingDashboardScreen
cat > "$SCREENS_DIR/billing_dashboard.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class BillingDashboardScreen extends StatelessWidget {
  const BillingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to BillingDashboardScreen'),
            const SizedBox(height: 10),
            const Text(
              'Overview of billing status with options to generate invoices or process payroll.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.invoiceGeneration),
              child: const Text('Generate Invoice'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.payrollProcessing),
              child: const Text('Process Payroll'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/billing_dashboard.dart"
echo "Updated BillingDashboardScreen with description and navigation"

# Update InvoiceGenerationScreen
cat > "$SCREENS_DIR/invoice_generation_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class InvoiceGenerationScreen extends StatelessWidget {
  const InvoiceGenerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Generation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to InvoiceGenerationScreen'),
            const SizedBox(height: 10),
            const Text(
              'Create and send invoices to clients for services rendered.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Billing'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/invoice_generation_screen.dart"
echo "Updated InvoiceGenerationScreen with description and navigation"

# Update PayrollProcessingScreen
cat > "$SCREENS_DIR/payroll_processing_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class PayrollProcessingScreen extends StatelessWidget {
  const PayrollProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payroll Processing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to PayrollProcessingScreen'),
            const SizedBox(height: 10),
            const Text(
              'Calculate and process payroll for caregivers.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Billing'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/payroll_processing_screen.dart"
echo "Updated PayrollProcessingScreen with description and navigation"

# Update ReportsDashboardScreen
cat > "$SCREENS_DIR/reports_dashboard.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ReportsDashboardScreen'),
            const SizedBox(height: 10),
            const Text(
              'View analytics and reports on services, revenue, and performance.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.auditLog),
              child: const Text('View Audit Logs'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/reports_dashboard.dart"
echo "Updated ReportsDashboardScreen with description and navigation"

# Update AuditLogScreen
cat > "$SCREENS_DIR/audit_log_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to AuditLogScreen'),
            const SizedBox(height: 10),
            const Text(
              'View a log of system actions for compliance and auditing.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/audit_log_screen.dart"
echo "Updated AuditLogScreen with description and navigation"

# Update CaregiverDashboardScreen
cat > "$SCREENS_DIR/caregiver_dashboard.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class CaregiverDashboardScreen extends StatelessWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to CaregiverDashboardScreen'),
            const SizedBox(height: 10),
            const Text(
              'Manage your schedule, check in/out of visits, and communicate with clients.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.scheduleOverview),
              child: const Text('View Schedule'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.visitCheckIn),
              child: const Text('Check In to Visit'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.messages),
              child: const Text('Messages'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/caregiver_dashboard.dart"
echo "Updated CaregiverDashboardScreen with description and navigation"

# Update ScheduleOverviewScreen
cat > "$SCREENS_DIR/schedule_overview_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';

class ScheduleOverviewScreen extends StatelessWidget {
  const ScheduleOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Overview')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to ScheduleOverviewScreen'),
            const SizedBox(height: 10),
            const Text(
              'View your upcoming shifts or care schedule.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, userProvider.getInitialRoute()),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/schedule_overview_screen.dart"
echo "Updated ScheduleOverviewScreen with description and navigation"

# Update VisitCheckInScreen
cat > "$SCREENS_DIR/visit_check_in_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class VisitCheckInScreen extends StatelessWidget {
  const VisitCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Check-In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to VisitCheckInScreen'),
            const SizedBox(height: 10),
            const Text(
              'Check in to a client visit, recording start time and location.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.taskList),
              child: const Text('View Tasks'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.emar),
              child: const Text('Log Medication'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.careNotes),
              child: const Text('Add Care Notes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.visitCheckOut),
              child: const Text('Check Out'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/visit_check_in_screen.dart"
echo "Updated VisitCheckInScreen with description and navigation"

# Update TaskListScreen
cat > "$SCREENS_DIR/task_list_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task List')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to TaskListScreen'),
            const SizedBox(height: 10),
            const Text(
              'View and complete tasks for a specific client visit.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Check-In'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/task_list_screen.dart"
echo "Updated TaskListScreen with description and navigation"

# Update EmarScreen
cat > "$SCREENS_DIR/emar_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class EmarScreen extends StatelessWidget {
  const EmarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('eMAR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to EmarScreen'),
            const SizedBox(height: 10),
            const Text(
              'Log medication administration for a client.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Check-In'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/emar_screen.dart"
echo "Updated EmarScreen with description and navigation"

# Update CareNotesScreen
cat > "$SCREENS_DIR/care_notes_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class CareNotesScreen extends StatelessWidget {
  const CareNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Care Notes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to CareNotesScreen'),
            const SizedBox(height: 10),
            const Text(
              'Record notes about a client\'s condition or visit.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Check-In'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/care_notes_screen.dart"
echo "Updated CareNotesScreen with description and navigation"

# Update VisitCheckOutScreen
cat > "$SCREENS_DIR/visit_check_out_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class VisitCheckOutScreen extends StatelessWidget {
  const VisitCheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Check-Out')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to VisitCheckOutScreen'),
            const SizedBox(height: 10),
            const Text(
              'Check out of a client visit, recording end time and summary.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.caregiverDashboard),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/visit_check_out_screen.dart"
echo "Updated VisitCheckOutScreen with description and navigation"

# Update FamilyPortalScreen
cat > "$SCREENS_DIR/family_portal_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class FamilyPortalScreen extends StatelessWidget {
  const FamilyPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Portal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to FamilyPortalScreen'),
            const SizedBox(height: 10),
            const Text(
              'Monitor care schedules, communicate, and manage payments.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.scheduleOverview),
              child: const Text('View Schedule'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.messages),
              child: const Text('Messages'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.paymentStatus),
              child: const Text('Payment Status'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.userProfile),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/family_portal_screen.dart"
echo "Updated FamilyPortalScreen with description and navigation"

# Update MessagesScreen
cat > "$SCREENS_DIR/messages_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to MessagesScreen'),
            const SizedBox(height: 10),
            const Text(
              'Communicate with caregivers, families, or admins.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, userProvider.getInitialRoute()),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/messages_screen.dart"
echo "Updated MessagesScreen with description and navigation"

# Update PaymentStatusScreen
cat > "$SCREENS_DIR/payment_status_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to PaymentStatusScreen'),
            const SizedBox(height: 10),
            const Text(
              'View payment history and outstanding balances.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Family Portal'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/payment_status_screen.dart"
echo "Updated PaymentStatusScreen with description and navigation"

# Update OfflineModeScreen
cat > "$SCREENS_DIR/offline_mode_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class OfflineModeScreen extends StatelessWidget {
  const OfflineModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Mode')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to OfflineModeScreen'),
            const SizedBox(height: 10),
            const Text(
              'Access cached data and limited functionality while offline.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, Routes.syncStatus),
              child: const Text('Check Sync Status'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/offline_mode_screen.dart"
echo "Updated OfflineModeScreen with description and navigation"

# Update SyncStatusScreen
cat > "$SCREENS_DIR/sync_status_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to SyncStatusScreen'),
            const SizedBox(height: 10),
            const Text(
              'View the status of data synchronization with the server.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Offline Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/sync_status_screen.dart"
echo "Updated SyncStatusScreen with description and navigation"

# Verify constants.dart
check_file "$LIB_DIR/constants.dart"
echo "Verified constants.dart"

# Verify user.dart
check_file "$MODELS_DIR/user.dart"
echo "Verified user.dart"

# Verify user_provider.dart
check_file "$LIB_DIR/user_provider.dart"
echo "Verified user_provider.dart"

# Verify main.dart
check_file "$LIB_DIR/main.dart"
echo "Verified main.dart"

# Verify provider dependency in pubspec.yaml
if ! grep -q "provider:" "$PROJECT_DIR/pubspec.yaml"; then
  sed -i '/dependencies:/a\  provider: ^6.1.0' "$PROJECT_DIR/pubspec.yaml"
  echo "Added provider to pubspec.yaml"
else
  echo "Provider already in pubspec.yaml"
fi

# Clean Flutter build cache
cd "$PROJECT_DIR"
flutter clean
if [ $? -eq 0 ]; then
  echo "Cleaned Flutter build cache"
else
  echo "Error cleaning build cache"
  exit 1
fi

# Run flutter pub get
flutter pub get
if [ $? -eq 0 ]; then
  echo "Ran flutter pub get"
else
  echo "Error running flutter pub get"
  exit 1
fi

# Attempt to run the app with verbose output
echo "Running the app with verbose output..."
flutter run -d chrome -v > flutter_run_log.txt 2>&1
if [ $? -eq 0 ]; then
  echo "App launched successfully! Check Chrome for the LoginScreen."
else
  echo "Failed to run the app. Check flutter_run_log.txt for details."
  exit 1
fi

echo "Script complete! Test navigation workflows starting from LoginScreen."