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

# Update LoginScreen with navigation
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
                // Mock authentication
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
if [ $? -eq 0 ]; then
  echo "Updated $SCREENS_DIR/login_screen.dart with login and navigation"
else
  echo "Error updating $SCREENS_DIR/login_screen.dart"
  exit 1
fi

# Update AdminDashboardScreen with navigation buttons
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ),
      ),
    );
  }
}
EOL
if [ $? -eq 0 ]; then
  echo "Updated $SCREENS_DIR/admin_dashboard.dart with navigation buttons"
else
  echo "Error updating $SCREENS_DIR/admin_dashboard.dart"
  exit 1
fi

# Update CaregiverDashboardScreen with navigation buttons
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
          ],
        ),
      ),
    );
  }
}
EOL
if [ $? -eq 0 ]; then
  echo "Updated $SCREENS_DIR/caregiver_dashboard.dart with navigation buttons"
else
  echo "Error updating $SCREENS_DIR/caregiver_dashboard.dart"
  exit 1
fi

# Update FamilyPortalScreen with navigation buttons
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
          ],
        ),
      ),
    );
  }
}
EOL
if [ $? -eq 0 ]; then
  echo "Updated $SCREENS_DIR/family_portal_screen.dart with navigation buttons"
else
  echo "Error updating $SCREENS_DIR/family_portal_screen.dart"
  exit 1
fi

# Verify constants.dart
check_file "$LIB_DIR/constants.dart"
echo "Verified $LIB_DIR/constants.dart"

# Verify user.dart
cat > "$MODELS_DIR/user.dart" <<EOL
class User {
  final String id;
  final String role; // e.g., 'admin', 'caregiver', 'family'

  User({required this.id, required this.role});
}
EOL
check_file "$MODELS_DIR/user.dart"
echo "Verified $MODELS_DIR/user.dart"

# Verify user_provider.dart
cat > "$LIB_DIR/user_provider.dart" <<EOL
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
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
echo "Verified $LIB_DIR/user_provider.dart"

# Verify main.dart
check_file "$LIB_DIR/main.dart"
echo "Verified $LIB_DIR/main.dart"

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

echo "Script complete! Navigate from LoginScreen to dashboards and test buttons."