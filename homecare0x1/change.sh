#!/bin/bash

# Script to fix Chrome web run, onPopInvoked deprecation, and critical lints in homecare0x1
# Run in the project's root folder

# Exit on any error
set -e

# Check if lib and test directories exist
if [ ! -d "lib" ] || [ ! -d "test" ]; then
  echo "Error: 'lib' or 'test' directory not found. Please run this script in the project's root folder."
  exit 1
fi

# Create backups of files to be modified
for file in lib/screens/admin_dashboard.dart lib/screens/login_screen.dart lib/screens/caregiver_dashboard.dart lib/screens/family_portal_screen.dart pubspec.yaml; do
  if [ -f "$file" ]; then
    cp "$file" "${file}.bak"
    echo "Backup created: ${file}.bak"
  fi
done

# Update admin_dashboard.dart to use onPopInvokedWithResult
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
      onPopInvokedWithResult: (didPop, result) async {
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

# Update login_screen.dart to fix use_build_context_synchronously
cat > lib/screens/login_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/services/auth_service.dart';
import 'package:homecare0x1/user_provider.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';
import 'package:provider/provider.dart';

// ignore: library_private_types_in_public_api
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final authService = AuthService();
      final user = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      setState(() => _isLoading = false);
      if (user != null && context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(user);
        Navigator.pushReplacementNamed(context, userProvider.getInitialRoute());
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome to Homecare Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to access your dashboard',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ModernButton(
                            text: 'Login',
                            icon: Icons.login,
                            width: double.infinity,
                            onPressed: _login,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

# Update caregiver_dashboard.dart to fix use_build_context_synchronously
cat > lib/screens/caregiver_dashboard.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/user_provider.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';
import 'package:homecare0x1/widgets/cards/stats_card.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:provider/provider.dart';

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
            StatsCard(
              title: 'Tasks Completed',
              value: '8',
              change: '+2',
              isPositive: true,
              icon: Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            StatsCard(
              title: 'Upcoming Tasks',
              value: '3',
              change: '0',
              isPositive: true,
              icon: Icons.schedule,
              color: Theme.of(context).colorScheme.secondary,
            ),
            StatsCard(
              title: 'Clients Assigned',
              value: '5',
              change: '+1',
              isPositive: true,
              icon: Icons.people,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Client List',
              subtitle: 'View clients',
              icon: Icons.person,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, Routes.clientList),
            ),
            DashboardCard(
              title: 'Task List',
              subtitle: 'View tasks',
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
              onTap: () => Navigator.pushNamed(context, Routes.visitCheckIn),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Update family_portal_screen.dart to fix use_build_context_synchronously
cat > lib/screens/family_portal_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/user_provider.dart';
import 'package:homecare0x1/widgets/cards/dashboard_card.dart';
import 'package:homecare0x1/widgets/cards/stats_card.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:provider/provider.dart';

class FamilyPortalScreen extends StatelessWidget {
  const FamilyPortalScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.user?.name ?? 'Family Member';

    return ModernScreenLayout(
      title: 'Family Portal',
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
              'Stay updated with caregiving services',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            StatsCard(
              title: 'Recent Visits',
              value: '4',
              change: '+1',
              isPositive: true,
              icon: Icons.event,
              color: Theme.of(context).colorScheme.primary,
            ),
            StatsCard(
              title: 'Care Notes',
              value: '12',
              change: '+3',
              isPositive: true,
              icon: Icons.note,
              color: Theme.of(context).colorScheme.secondary,
            ),
            StatsCard(
              title: 'Messages',
              value: '5',
              change: '+2',
              isPositive: true,
              icon: Icons.message,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Client Profile',
              subtitle: 'View profile',
              icon: Icons.person,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, Routes.clientProfile),
            ),
            DashboardCard(
              title: 'Messages',
              subtitle: 'View messages',
              icon: Icons.message,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => Navigator.pushNamed(context, Routes.messages),
            ),
            DashboardCard(
              title: 'Care Notes',
              subtitle: 'View notes',
              icon: Icons.note,
              iconColor: Theme.of(context).colorScheme.primary,
              onTap: () => Navigator.pushNamed(context, Routes.careNotes),
            ),
            DashboardCard(
              title: 'Payment Status',
              subtitle: 'View payments',
              icon: Icons.payment,
              iconColor: Theme.of(context).colorScheme.secondary,
              onTap: () => Navigator.pushNamed(context, Routes.paymentStatus),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

# Update pubspec.yaml to remove unnecessary dev dependency
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
  provider: ^6.0.0
  intl: ^0.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
EOF

# Clean Flutter cache to fix canvaskit.js issue
echo "Cleaning Flutter cache..."
flutter clean
flutter pub cache repair

# Set file permissions
chmod 644 lib/screens/admin_dashboard.dart
chmod 644 lib/screens/login_screen.dart
chmod 644 lib/screens/caregiver_dashboard.dart
chmod 644 lib/screens/family_portal_screen.dart
chmod 644 pubspec.yaml

# Run flutter analyze to check for issues
echo "Running flutter analyze..."
flutter analyze

# Run flutter pub get to ensure dependencies are resolved
echo "Fetching dependencies..."
flutter pub get

echo "Changes applied successfully!"
echo "Updated files:"
echo "- lib/screens/admin_dashboard.dart"
echo "- lib/screens/login_screen.dart"
echo "- lib/screens/caregiver_dashboard.dart"
echo "- lib/screens/family_portal_screen.dart"
echo "- pubspec.yaml"
echo "Backups created:"
echo "- lib/screens/admin_dashboard.dart.bak"
echo "- lib/screens/login_screen.dart.bak"
echo "- lib/screens/caregiver_dashboard.dart.bak"
echo "- lib/screens/family_portal_screen.dart.bak"
echo "- pubspec.yaml.bak"
echo "Next steps:"
echo "- Run 'flutter run -d chrome --web-renderer html' to test the updated app on Chrome."
echo "- If Chrome fails, run 'flutter run -d linux' and verify the app."
echo "- Log in as a caregiver (e.g., caregiver@example.com, password: care123), family member (e.g., family@example.com, password: fam123), and admin (e.g., admin@example.com, password: admin123)."
echo "- Verify that the Caregiver Dashboard, Family Portal, and Admin Dashboard load without errors."
echo "- Check that back buttons prompt logout (Caregiver, Family) or exit (Admin)."
echo "- If issues persist, share the output of 'flutter run' or describe the error."