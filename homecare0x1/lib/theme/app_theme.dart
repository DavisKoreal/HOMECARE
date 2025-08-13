import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color primaryBlueLight = Color(0xFF5DADE2);
  static const Color secondaryTeal = Color(0xFF1ABC9C);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF2ECC71);
  static const Color accentOrange = Color(0xFFF39C12);
  static const Color neutral600 = Color(0xFF7F8C8D);
  static const Color neutral100 = Color(0xFFF8F9FA);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        secondary: secondaryTeal,
        error: errorRed,
      ),
      scaffoldBackgroundColor: neutral100,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E50),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF2C3E50),
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: neutral600,
        ),
      ),
    );
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return accentOrange;
      case 'in_session':
        return primaryBlue;
      case 'completed':
        return successGreen;
      case 'request':
        return errorRed;
      default:
        return neutral600;
    }
  }
}
