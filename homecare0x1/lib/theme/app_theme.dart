import 'package:flutter/material.dart';

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
