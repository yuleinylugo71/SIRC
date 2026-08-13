import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SircColors {
  // Primary palette (Vibrant Blue)
  static const blue = Color(0xFF2563EB); // Modern Royal Blue
  static const blueDark = Color(0xFF1D4ED8); // Deep Blue
  static const blueLight = Color(0xFF60A5FA); // Light Blue
  static const blueAccent = Color(0xFF3B82F6);

  // Backgrounds & Surfaces
  static const background = Color(0xFFF8FAFC); // Very light slate
  static const surface = Colors.white;
  static const sky = Color(0xFFEFF6FF); // Tinted blue surface

  // Text & Inks
  static const ink = Color(0xFF0F172A); // Very dark slate (almost black)
  static const inkLight = Color(0xFF334155); // Slate text
  static const muted = Color(0xFF64748B); // Muted text

  // Borders & Dividers
  static const border = Color(0xFFE2E8F0);

  // Status Colors
  static const success = Color(0xFF10B981); // Emerald
  static const successBg = Color(0xFFD1FAE5);
  static const error = Color(0xFFEF4444); // Red
  static const errorBg = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B); // Amber
}

class SircTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: SircColors.blue,
      primary: SircColors.blue,
      secondary: SircColors.blueDark,
      surface: SircColors.surface,
      error: SircColors.error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SircColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor:
            SircColors.background, // Clean transparent-like app bar
        foregroundColor: SircColors.ink,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0, // Prevent color change on scroll
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Dark status bar icons
        iconTheme: IconThemeData(color: SircColors.ink),
        titleTextStyle: TextStyle(
          color: SircColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
      ),
      cardTheme: CardThemeData(
        color: SircColors.surface,
        elevation:
            0, // We use box shadows explicitly where needed, or minimal elevation
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SircColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SircColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: const TextStyle(color: SircColors.muted, fontSize: 15),
        hintStyle: const TextStyle(color: SircColors.muted, fontSize: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SircColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SircColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SircColors.blueAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: SircColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SircColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(56), // Taller buttons
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SircColors.blue,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: SircColors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SircColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          color: SircColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: SircColors.ink,
        contentTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}
