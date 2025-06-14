#!/bin/bash

# Script to fix test error and WillPopScope deprecation in homecare0x1
# Run in the project's root folder

# Exit on any error
set -e

# Check if lib and test directories exist
if [ ! -d "lib" ] || [ ! -d "test" ]; then
  echo "Error: 'lib' or 'test' directory not found. Please run this script in the project's root folder."
  exit 1
fi

# Create backups of files to be modified
for file in test/widget_test.dart lib/screens/admin_dashboard.dart lib/screens/audit_log_screen.dart lib/screens/care_notes_screen.dart; do
  if [ -f "$file" ]; then
    cp "$file" "${file}.bak"
    echo "Backup created: ${file}.bak"
  fi
done

# Update widget_test.dart
cat > test/widget_test.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homecare0x1/main.dart';
import 'package:homecare0x1/screens/login_screen.dart';

void main() {
  testWidgets('HomecareApp renders LoginScreen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const HomecareApp());

    // Verify that the LoginScreen is displayed.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome to Homecare Management'), findsOneWidget);

    // Verify the email and password fields exist.
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
EOF

# Update admin_dashboard.dart to replace WillPopScope with PopScope
cat > lib/screens/admin_dashboard.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget _buildCircularStat({
    required String title,
    required String value,
    required double percent,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white10,
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Icon(icon, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  List<Widget> _buildDashboardActions(BuildContext context) {
    return [
      DashboardCard(
        title: 'Clients',
        subtitle: 'Profiles',
        icon: Icons.people_outline,
        iconColor: AppTheme.primaryBlue,
        onTap: () => Navigator.pushNamed(context, Routes.clientList),
      ),
      DashboardCard(
        title: 'Shifts',
        subtitle: 'Assign caregivers',
        icon: Icons.schedule,
        iconColor: AppTheme.secondaryTeal,
        onTap: () => Navigator.pushNamed(context, Routes.shiftAssignment),
      ),
      DashboardCard(
        title: 'Billing',
        subtitle: 'Payments & tracking',
        icon: Icons.payment,
        iconColor: AppTheme.accentOrange,
        onTap: () => Navigator.pushNamed(context, Routes.billingDashboard),
      ),
      DashboardCard(
        title: 'Reports',
        subtitle: 'Insights',
        icon: Icons.analytics_outlined,
        iconColor: AppTheme.successGreen,
        onTap: () => Navigator.pushNamed(context, Routes.reportsDashboard),
      ),
      DashboardCard(
        title: 'Audit Logs',
        subtitle: 'User activity',
        icon: Icons.history,
        iconColor: AppTheme.neutral600,
        badge: '3',
        onTap: () => Navigator.pushNamed(context, Routes.auditLog),
      ),
      DashboardCard(
        title: 'Invoices',
        subtitle: 'Manage',
        icon: Icons.receipt_long,
        iconColor: AppTheme.warningYellow,
        onTap: () => Navigator.pushNamed(context, Routes.invoiceGeneration),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Exit the dashboard?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Exit')),
            ],
          ),
        );
        if (shouldExit ?? false) SystemNavigator.pop();
      },
      child: ModernScreenLayout(
        title: '',
        showBackButton: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.userProfile)),
        ],
        body: RefreshIndicator(
          onRefresh: () async =>
              await Future.delayed(const Duration(seconds: 1)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.7),
                        AppTheme.primaryBlueLight.withOpacity(0.4)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome Back, Admin!",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text("Here's your overview for today.",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // KPI Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildCircularStat(
                        title: 'Active Clients',
                        value: '24',
                        percent: 0.75,
                        color: AppTheme.primaryBlue,
                        icon: Icons.people,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCircularStat(
                        title: 'Caregivers',
                        value: '15',
                        percent: 0.6,
                        color: AppTheme.secondaryTeal,
                        icon: Icons.medical_services,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCircularStat(
                        title: 'Invoices',
                        value: '8',
                        percent: 0.3,
                        color: AppTheme.accentOrange,
                        icon: Icons.receipt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Quick Actions
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                  children: _buildDashboardActions(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
EOF

# Update audit_log_screen.dart to remove unused import
cat > lib/screens/audit_log_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/audit_log.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatelessWidget {
  AuditLogScreen({super.key});

  // Mock audit logs
  final List<AuditLog> _logs = [
    AuditLog(
      id: '1',
      userId: 'admin1',
      action: 'Client Profile Updated',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      details: 'Updated care plan for John Doe',
    ),
    AuditLog(
      id: '2',
      userId: 'caregiver1',
      action: 'Medication Logged',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      details: 'Logged Aspirin for John Doe',
    ),
    AuditLog(
      id: '3',
      userId: 'admin1',
      action: 'Shift Assigned',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      details: 'Assigned caregiver to Jane Smith',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ModernScreenLayout(
      title: 'Audit Log',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Log',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'View system actions for compliance',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _logs.isEmpty
                  ? const Center(child: Text('No logs found'))
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(log.action),
                            subtitle: Text(
                              'By: ${log.userId}\nTime: ${DateFormat('MMM d, h:mm a').format(log.timestamp)}\nDetails: ${log.details}',
                            ),
                            leading: Icon(
                              Icons.history,
                              color: AppTheme.neutral600,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Back to Reports',
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

# Update care_notes_screen.dart to suppress private type warning
cat > lib/screens/care_notes_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/care_note.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:intl/intl.dart';

// ignore: library_private_types_in_public_api
class CareNotesScreen extends StatefulWidget {
  const CareNotesScreen({super.key});

  @override
  _CareNotesScreenState createState() => _CareNotesScreenState();
}

class _CareNotesScreenState extends State<CareNotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  bool _isAdding = false;

  // Mock care notes
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

  void _toggleAddForm() {
    setState(() {
      _isAdding = !_isAdding;
      if (!_isAdding) {
        _noteController.clear();
      }
    });
  }

  void _addNote() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _notes.insert(
          0,
          CareNote(
            id: (_notes.length + 1).toString(),
            clientId: '1',
            caregiverId: 'caregiver1',
            note: _noteController.text,
            timestamp: DateTime.now(),
          ),
        );
        _toggleAddForm();
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'Record and view notes about client care',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ModernButton(
              text: _isAdding ? 'Cancel' : 'Add Note',
              icon: _isAdding ? Icons.cancel : Icons.add,
              width: double.infinity,
              isOutlined: _isAdding,
              onPressed: _toggleAddForm,
            ),
            if (_isAdding) ...[
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a note' : null,
                    ),
                    const SizedBox(height: 16),
                    ModernButton(
                      text: 'Save Note',
                      icon: Icons.save,
                      width: double.infinity,
                      onPressed: _addNote,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Note History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _notes.isEmpty
                ? const Center(child: Text('No notes found'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
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

# Set file permissions
chmod 644 test/widget_test.dart
chmod 644 lib/screens/admin_dashboard.dart
chmod 644 lib/screens/audit_log_screen.dart
chmod 644 lib/screens/care_notes_screen.dart

# Run flutter analyze to check for issues
echo "Running flutter analyze..."
flutter analyze

# Run flutter pub get to ensure dependencies are resolved
echo "Fetching dependencies..."
flutter pub get

echo "Changes applied successfully!"
echo "Updated files:"
echo "- test/widget_test.dart"
echo "- lib/screens/admin_dashboard.dart"
echo "- lib/screens/audit_log_screen.dart"
echo "- lib/screens/care_notes_screen.dart"
echo "Backups created:"
echo "- test/widget_test.dart.bak"
echo "- lib/screens/admin_dashboard.dart.bak"
echo "- lib/screens/audit_log_screen.dart.bak"
echo "- lib/screens/care_notes_screen.dart.bak"
echo "Next steps:"
echo "- Run 'flutter run -d chrome' to test the updated app."
echo "- Log in as a caregiver (e.g., caregiver@example.com, password: care123) and a family member (e.g., family@example.com, password: fam123)."
echo "- Verify that the Caregiver Dashboard and Family Portal load without errors."
echo "- Check that the Admin Dashboard back button works correctly."
echo "- If issues persist, share the output of 'flutter run' or describe the error."