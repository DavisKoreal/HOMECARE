#!/bin/bash

# Modern UI Design Shell Script for Flutter Homecare App
# This script fixes errors in the UI components and styling

echo "🎨 Fixing modern UI design issues in your Flutter homecare app..."

# Update AppTheme to use CardThemeData
cat > lib/theme/app_theme.dart << 'EOF'
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryBlueLight = Color(0xFF6AB7F5);
  static const Color secondaryTeal = Color(0xFF26A69A);
  static const Color secondaryTealLight = Color(0xFF80CBC4);
  static const Color accentOrange = Color(0xFFF57C00);
  static const Color warningYellow = Color(0xFFFFCA28);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral100 = Color(0xFFF5F5F5);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryTeal,
      ),
      scaffoldBackgroundColor: neutral100,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
EOF

# Update LoginScreen to include ModernScreenLayout import
cat > lib/screens/login_screen.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/user.dart';
import 'package:homecare0x1/user_provider.dart';
import 'package:homecare0x1/theme/app_theme.dart';
import 'package:homecare0x1/widgets/common/modern_screen_layout.dart';
import 'package:homecare0x1/widgets/common/modern_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return ModernScreenLayout(
      title: 'Login',
      showBackButton: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Homecare Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sign in with your credentials to access your role-specific dashboard.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ModernButton(
              text: 'Login',
              icon: Icons.login,
              width: double.infinity,
              onPressed: () {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                String role = emailController.text.contains('admin')
                    ? 'admin'
                    : emailController.text.contains('caregiver')
                        ? 'caregiver'
                        : 'family';
                userProvider.setUser(User(id: emailController.text, role: role));
                Navigator.pushReplacementNamed(context, userProvider.getInitialRoute());
              },
            ),
          ],
        ),
      ),
    );
  }
}
EOF

echo "✅ Fixed UI components and styling issues in the homecare app"
echo "Changes include:"
echo "- Corrected CardTheme to CardThemeData in AppTheme"
echo "- Added missing import for ModernScreenLayout in LoginScreen"
echo "To apply these changes:"
echo "1. Run 'flutter pub get' to ensure all dependencies are installed"
echo "2. Test the app with 'flutter run'"
echo "3. Verify the new UI components and styling"
echo "Note: Ensure pubspec.yaml includes required dependencies (flutter, provider)"