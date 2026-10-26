import 'package:flutter/material.dart';

/// Japanese Minimalist Warm Monochrome & Bauhaus Theme
/// Inspired by "Muchi Neko" Concept Design:
/// Color Palette: #111111, #333333, #777777, #BEB8AD, #E6E1D7, #F6F4EE
class AppTheme {
  // Core Washi Minimalist Palette
  static const Color inkBlack = Color(0xFF111111);
  static const Color charcoal = Color(0xFF333333);
  static const Color mutedGrey = Color(0xFF777777);
  static const Color sandAccent = Color(0xFFBEB8AD);
  static const Color warmBorder = Color(0xFFE6E1D7);
  static const Color washiCream = Color(0xFFF6F4EE);

  // Japanese Traditional Accent Touches
  static const Color vermilionRed = Color(0xFFC84B31); // Traditional Inkan / Emergency red
  static const Color matchaTeal = Color(0xFF2E6F68);   // Traditional deep green-teal
  static const Color goldOchre = Color(0xFFD4A373);    // Subtle gold highlight

  // Aliases for compatibility
  static const Color primary = inkBlack;
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color accentRose = vermilionRed;
  static const Color accentTeal = matchaTeal;
  static const Color backgroundDark = washiCream;
  // Dark utility surfaces are used by maps, chat, planner, vault, and emergency
  // detail views while the main dashboard remains light.
  static const Color surfaceDark = Color(0xFF1C1C1C);
  static const Color surfaceLightDark = Color(0xFF333333);

  static ThemeData get darkTheme => washiTheme;

  static ThemeData get washiTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: washiCream,
      colorScheme: const ColorScheme.light(
        primary: inkBlack,
        secondary: matchaTeal,
        error: vermilionRed,
        surface: Colors.white,
        onSurface: inkBlack,
        outline: warmBorder,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: warmBorder, width: 1.2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: washiCream,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: inkBlack),
        titleTextStyle: TextStyle(
          color: inkBlack,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: inkBlack,
          foregroundColor: washiCream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkBlack,
          side: const BorderSide(color: inkBlack, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: washiCream,
        selectedColor: inkBlack,
        disabledColor: washiCream,
        secondarySelectedColor: inkBlack,
        labelStyle: const TextStyle(color: inkBlack, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: washiCream, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: warmBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warmBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warmBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inkBlack, width: 1.8),
        ),
      ),
    );
  }
}
