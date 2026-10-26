import 'package:flutter/material.dart';

/// Japanese Minimalist Warm Monochrome & Bauhaus Theme
/// Inspired by "Muchi Neko" Concept Design:
/// Color Palette: #111111, #333333, #777777, #BEB8AD, #E6E1D7, #F6F4EE
class AppTheme {
  // AIBO Core Warm Japanese Palette
  static const Color washiCream = Color(0xFFFAF7EE);  // Main background (Warm ivory)
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Content surfaces (Soft white)
  static const Color charcoal = Color(0xFF1E232A);    // Primary text (Charcoal)
  static const Color secondaryText = Color(0xFF57534E); // Secondary metadata
  static const Color mutedText = Color(0xFF78716C);    // Muted timestamps / hints
  static const Color warmBorder = Color(0xFFEAE5D9);  // Subtle borders (Subtle craft)
  static const Color surfaceHover = Color(0xFFF5F1E5); // Tap feedback surface

  // Semantic Accents (Traditional Japanese Pigments)
  static const Color matchaGreen = Color(0xFF2F5D44); // Success states & verified items
  static const Color vermilionRed = Color(0xFFC84B31); // Traditional Inkan & emergency alerts
  static const Color yamabukiGold = Color(0xFFD97706); // Attention & pending reminders
  static const Color aizomeIndigo = Color(0xFF1E3A8A); // Transit & official links

  // Backward compatibility aliases
  static const Color inkBlack = charcoal;
  static const Color sandAccent = Color(0xFFBEB8AD);
  static const Color mutedGrey = mutedText;
  static const Color matchaTeal = matchaGreen;
  static const Color goldOchre = yamabukiGold;
  static const Color primary = charcoal;
  static const Color primaryDark = Color(0xFF14171C);
  static const Color accentRose = vermilionRed;
  static const Color accentTeal = matchaGreen;
  static const Color backgroundDark = washiCream;
  static const Color surfaceDark = Color(0xFF1C1C1C);
  static const Color surfaceLightDark = Color(0xFF333333);

  // Restrained Radius System
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusPill = 999.0;

  static ThemeData get darkTheme => washiTheme;

  static ThemeData get washiTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: washiCream,
      colorScheme: const ColorScheme.light(
        primary: charcoal,
        secondary: matchaGreen,
        error: vermilionRed,
        surface: surfaceWhite,
        onSurface: charcoal,
        outline: warmBorder,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: warmBorder, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: washiCream,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: charcoal),
        titleTextStyle: TextStyle(
          color: charcoal,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: charcoal,
          foregroundColor: washiCream,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoal,
          side: const BorderSide(color: warmBorder, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: washiCream,
        selectedColor: charcoal,
        disabledColor: washiCream,
        secondarySelectedColor: charcoal,
        labelStyle: const TextStyle(color: charcoal, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: washiCream, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
          side: const BorderSide(color: warmBorder, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: warmBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: warmBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: charcoal, width: 1.5),
        ),
      ),
    );
  }
}
