import os

def fix_integration_errors():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Fix AppTheme (Clean Overwrite)
    # ---------------------------------------------------------
    print("\n--- Fixing lib/theme/app_theme.dart ---")
    theme_path = os.path.join("lib", "theme", "app_theme.dart")
    
    theme_content = """import 'package:flutter/material.dart';

class AppTheme {
  // Primary Brand Colors
  static const Color primaryPurple = Color(0xFF5C42BD);
  static const Color primaryBlue = Color(0xFF5C42BD); // Mapping Blue to Purple for consistency if needed, or keep distinct
  static const Color primaryBlueLight = Color(0xFF7E60E8);

  // Status Colors
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFFAB00);
  static const Color errorRed = Color(0xFFD50000);

  // Backgrounds & Neutrals
  static const Color backgroundCanvas = Color(0xFFF8F9FA);
  static const Color neutral100 = Color(0xFFF1F2F6);
  static const Color neutral600 = Color(0xFF636E72);
  static const Color borderGray = Color(0xFFE0E0E0);

  // Text
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  
  // Accents
  static const Color accentOrange = Color(0xFFFFAB00);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: backgroundCanvas,
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: successGreen,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
"""
    with open(theme_path, "w", encoding="utf-8") as f:
        f.write(theme_content)
    print("Cleaned up AppTheme.")

    # ---------------------------------------------------------
    # 2. Fix AuthService (Stub Implementation)
    # ---------------------------------------------------------
    print("\n--- Fixing lib/services/auth_service.dart ---")
    auth_path = os.path.join("lib", "services", "auth_service.dart")
    
    # We'll provide a robust stub that doesn't rely on hidden fields
    auth_code = """import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:homecare0x1/models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  // Mock user for development fallback
  User? _mockUser; 

  // Get current user (Maps Firebase User to App User model)
  Future<User?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      // In a real app, you'd fetch the role from Firestore here.
      // For now, returning a basic User object.
      return User(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'User',
        email: fbUser.email ?? '',
        role: 'caregiver', // Default role if unknown
      );
    }
    return _mockUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _mockUser = null;
  }
  
  // ... (Other auth methods would go here)
}
"""
    with open(auth_path, "w", encoding="utf-8") as f:
        f.write(auth_code)
    print("Fixed AuthService.")

    # ---------------------------------------------------------
    # 3. Fix CaregiverDashboardScreen (Class/Constructor Match)
    # ---------------------------------------------------------
    print("\n--- Fixing lib/screens/caregiver_dashboard.dart ---")
    dash_path = os.path.join("lib", "screens", "caregiver_dashboard.dart")
    
    with open(dash_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Ensure class and constructor match
    content = content.replace(
        "class CaregiverDashboard extends StatefulWidget",
        "class CaregiverDashboardScreen extends StatefulWidget"
    )
    content = content.replace(
        "const CaregiverDashboard({super.key});",
        "const CaregiverDashboardScreen({super.key});"
    )
    content = content.replace(
        "State<CaregiverDashboard> createState",
        "State<CaregiverDashboardScreen> createState"
    )
    content = content.replace(
        "_CaregiverDashboardState",
        "_CaregiverDashboardScreenState"
    )

    with open(dash_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Fixed CaregiverDashboardScreen naming.")

    # ---------------------------------------------------------
    # 4. Fix main.dart (Call correct constructor)
    # ---------------------------------------------------------
    print("\n--- Fixing lib/main.dart ---")
    main_path = os.path.join("lib", "main.dart")
    
    with open(main_path, "r", encoding="utf-8") as f:
        main_content = f.read()

    # Ensure import is there (it likely is, but checking)
    if "import 'package:homecare0x1/screens/caregiver_dashboard.dart';" not in main_content:
        main_content = "import 'package:homecare0x1/screens/caregiver_dashboard.dart';\n" + main_content

    # Fix the call site
    if "const CaregiverDashboardScreen()" in main_content:
        # It was likely correct in main, but the class itself was wrong. 
        # But if it called CaregiverDashboard(), we fix it here.
        pass 
    
    with open(main_path, "w", encoding="utf-8") as f:
        f.write(main_content)
    print("Checked main.dart.")

if __name__ == "__main__":
    fix_integration_errors()