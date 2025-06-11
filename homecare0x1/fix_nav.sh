#!/bin/bash

# Define project directory
PROJECT_DIR="/home/davis/dev/homecare0x1"
LIB_DIR="$PROJECT_DIR/lib"
SCREENS_DIR="$LIB_DIR/screens"
MODELS_DIR="$LIB_DIR/models"

# Ensure directories exist
mkdir -p "$SCREENS_DIR" "$MODELS_DIR"

# Function to check if a file exists
check_file() {
    if [ ! -f "$1" ]; then
        echo "Error: $1 is missing!"
        exit 1
    fi
}

# Fix LoginScreen (replace getLastRoute with getInitialRoute)
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
              decoration: const InputDecoration(labelText: 'Email')),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                String role = emailController.text.contains('admin') ? 'admin' :
                              emailController.text.contains('caregiver') ? 'caregiver' : 'family';
                userProvider.setUser(User(id: emailController.text, role: role));
                Navigator.pushReplacementNamed(context, userProvider.getInitialRoute());
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
echo "Fixed LoginScreen (getLastRoute → getInitialRoute)"

# Fix UserProfileScreen
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
check_file "$SCREENS_DIR/user_profile_screen.dart"
echo "Fixed UserProfileScreen (getLastRoute → getInitialRoute)"

# Update AdminDashboardScreen with logout
cat > "$SCREENS_DIR/admin_dashboard.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';

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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => {
                Provider.of<UserProvider>(context, listen: false).setUser(null);
                Navigator.pushReplacementNamed(context, Routes.login);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/admin_dashboard.dart"
echo "Updated AdminDashboardScreen with logout"

# Update CaregiverDashboardScreen with logout
cat > "$SCREENS_DIR/caregiver_dashboard.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';

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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => {
                Provider.of<UserProvider>(context, listen: false).setUser(null);
                Navigator.pushReplacementNamed(context, Routes.login);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/caregiver_dashboard.dart"
echo "Updated CaregiverDashboardScreen with logout"

# Update FamilyPortalScreen with logout
cat > "$SCREENS_DIR/family_portal_screen.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/constants.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/user_provider.dart';

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
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => {
                Provider.of<UserProvider>(context, listen: false).setUser(null);
                Navigator.pushReplacementNamed(context, Routes.login);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
EOL
check_file "$SCREENS_DIR/family_portal_screen.dart"
echo "Updated FamilyPortalScreen with logout"

# Verify user_provider.dart (add setUser to accept null)
cat > "$LIB_DIR/user_provider.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  String getInitialRoute() {
    switch (_user?.role) {
      case 'admin':
        return '/admin_dashboard';
      case 'caregiver':
        return '/caregiver_dashboard';
      case 'family':
        return '/family_portal';
      default:
        return '/login';
    }
  }
}
EOL
check_file "$LIB_DIR/user_provider.dart"
echo "Updated user_provider.dart to support null user for logout"

# Verify other files
for file in constants.dart main.dart screens/reports_dashboard.dart screens/visit_check_in_screen.dart \
    screens/audit_log_screen.dart screens/billing_dashboard.dart screens/payment_status_screen.dart \
    screens/task_list_screen.dart screens/schedule_overview_screen.dart screens/invoice_generation_screen.dart \
    screens/sync_status_screen.dart screens/client_profile_screen.dart screens/visit_check_out_screen.dart \
    screens/client_list_screen.dart screens/messages_screen.dart screens/shift_assignment_screen.dart \
    screens/emar_screen.dart screens/offline_mode_screen.dart screens/payroll_processing_screen.dart \
    screens/care_notes_screen.dart; do
    check_file "$LIB_DIR/$file"
    echo "Verified $file"
done

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

echo "Script complete! Test navigation workflows with logout functionality."