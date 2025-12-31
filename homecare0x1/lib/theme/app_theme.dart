import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ---------------------------------------------------------------------------
  // NEW SaaS DESIGN SYSTEM (Homebase Style)
  // ---------------------------------------------------------------------------
  static const Color primaryPurple = Color(0xFF7B16FF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color backgroundCanvas = Color(0xFFF4F5F7);
  static const Color borderGray = Color(0xFFDFE6E9);
  
  // ---------------------------------------------------------------------------
  // LEGACY COLORS (Restored for Backward Compatibility)
  // Mapping old colors to new palette where possible to start unifying the look.
  // ---------------------------------------------------------------------------
  
  // Old 'primaryBlue' is now mapped to 'primaryPurple' so old screens get the new brand color.
  static const Color primaryBlue = primaryPurple; 
  static const Color primaryBlueLight = Color(0xFFD1C4E9); // Light purple-ish
  
  // Standard SaaS Status Colors
  static const Color successGreen = Color(0xFF00B894); 
  static const Color errorRed = Color(0xFFD63031);     
  static const Color accentOrange = Color(0xFFFF7675); 
  static const Color secondaryTeal = Color(0xFF00CEC9); 
  
  // Neutrals
  static const Color neutral600 = textSecondary;
  static const Color neutral100 = Color(0xFFF5F6FA); // Light gray background used in old cards

  // ---------------------------------------------------------------------------
  // THEME DATA
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundCanvas,
      colorScheme: ColorScheme.light(
        primary: primaryPurple,
        surface: Colors.white,
        onSurface: textPrimary,
        error: errorRed,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      
      // Button Styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderGray),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      
      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER METHODS (Restored)
  // ---------------------------------------------------------------------------
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
      case 'paid':
        return successGreen;
      case 'pending':
      case 'request':
      case 'scheduled':
        return accentOrange; 
      case 'cancelled':
      case 'missed':
      case 'late':
        return errorRed;
      default:
        return neutral600;
    }
  }
}
