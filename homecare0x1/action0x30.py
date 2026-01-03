import os

def fix_missing_theme_and_auth():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    # ---------------------------------------------------------
    # 1. Restore AppTheme (Add missing fields/methods)
    # ---------------------------------------------------------
    print("\n--- Restoring lib/theme/app_theme.dart ---")
    theme_path = os.path.join("lib", "theme", "app_theme.dart")
    
    theme_content = """import 'package:flutter/material.dart';

class AppTheme {
  // Primary Brand Colors
  static const Color primaryPurple = Color(0xFF5C42BD);
  static const Color primaryBlue = Color(0xFF5C42BD); 
  static const Color primaryBlueLight = Color(0xFF7E60E8);

  // Status Colors
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFFAB00);
  static const Color errorRed = Color(0xFFD50000);
  
  // Legacy/Other Colors (Restored)
  static const Color secondaryTeal = Color(0xFF00BFA5); 

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

  // Helper method to get color based on status string (Restored)
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
      case 'active':
        return successGreen;
      case 'pending':
      case 'in_progress':
      case 'in_session':
        return warningOrange;
      case 'cancelled':
      case 'rejected':
      case 'error':
      case 'critical':
        return errorRed;
      case 'request':
        return secondaryTeal;
      default:
        return neutral600;
    }
  }
}
"""
    with open(theme_path, "w", encoding="utf-8") as f:
        f.write(theme_content)
    print("Restored AppTheme fields and methods.")

    # ---------------------------------------------------------
    # 2. Enhance AuthService (Add login/register)
    # ---------------------------------------------------------
    print("\n--- Updating lib/services/auth_service.dart ---")
    auth_path = os.path.join("lib", "services", "auth_service.dart")
    
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
      return User(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'User',
        email: fbUser.email ?? '',
        role: 'caregiver', // Default role logic should ideally fetch from DB
      );
    }
    return _mockUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _mockUser = null;
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        return await getCurrentUser();
      }
    } catch (e) {
      print("Login failed: $e");
      // Fallback for dev mode if needed, or rethrow
    }
    return null;
  }

  // Register
  Future<User?> register(String email, String password, String name, String role) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        // Here you would typically also create a User document in Firestore
        return User(id: result.user!.uid, name: name, email: email, role: role);
      }
    } catch (e) {
      print("Registration failed: $e");
    }
    return null;
  }
}
"""
    with open(auth_path, "w", encoding="utf-8") as f:
        f.write(auth_code)
    print("Updated AuthService with login and register methods.")

if __name__ == "__main__":
    fix_missing_theme_and_auth()