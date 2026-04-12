import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF4A7BCC);
  static const Color primaryDark = Color(0xFF3A5FA0);
  static const Color accent = Color(0xFF5B9BD5);
  static const Color background = Color(0xFFF5F7FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF999999);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color starGold = Color(0xFFFFC107);
  static const Color canvasBorder = Color(0xFFE0E0E0);
  static const Color ghostStroke = Color(0xFFB0D4F1);
  static const Color drawnStroke = Color(0xFF333333);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: primaryDark,
        secondary: accent,
        surface: card,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: canvasBorder,
        thickness: 1,
      ),
    );
  }

  // Lao text style for displaying Lao script
  static TextStyle get laoTextStyle => GoogleFonts.notoSansLao(
        fontSize: 24,
        color: textPrimary,
      );

  static TextStyle get laoTextStyleLarge => GoogleFonts.notoSansLao(
        fontSize: 48,
        color: textPrimary,
      );

  static TextStyle get laoTextStyleSmall => GoogleFonts.notoSansLao(
        fontSize: 16,
        color: textPrimary,
      );
}
