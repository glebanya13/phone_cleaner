import 'package:flutter/material.dart';

/// Design tokens inspired by Apple's Liquid Glass and ambient materials.
class LiquidTokens {
  // Brand & Semantic Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFF43F5E); // Coral Rose
  static const Color purple = Color(0xFF8B5CF6); // Purple

  // Background Canvas Colors
  static const Color bgDark = Color(0xFF0A0E17);
  static const Color bgSurface = Color(0xFF111827);
  static const Color bgCard = Color(0xFF161F30);

  // Liquid Glass Material Tints
  static const Color glassSurface = Color(0x18FFFFFF);
  static const Color glassSurfaceHighlight = Color(0x28FFFFFF);
  static const Color glassSurfaceSubtle = Color(0x0EFFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
  static const Color glassBorderSubtle = Color(0x18FFFFFF);

  // Text Colors with High Contrast Legibility
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textInverse = Color(0xFF0A0E17);

  // Spacing Scale (8pt grid)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;

  // Corner Radii
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 22.0;
  static const double radiusXl = 28.0;
  static const double radiusFull = 999.0;

  // Elevation & Shadows
  static List<BoxShadow> get ambientGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.20),
      blurRadius: 28,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 20,
      spreadRadius: -2,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get glassDropShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      spreadRadius: -4,
      offset: const Offset(0, 6),
    ),
  ];
}

/// Backwards compatibility alias for AppColors
class AppColors {
  static const primary = LiquidTokens.primary;
  static const secondary = Color(0xFFEC4899);
  static const accent = LiquidTokens.accent;
  static const bgTop = LiquidTokens.bgDark;
  static const bgBottom = Color(0xFF111827);
}

ThemeData buildLiquidTheme(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: LiquidTokens.bgDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: LiquidTokens.primary,
      brightness: brightness,
      primary: LiquidTokens.primary,
      secondary: LiquidTokens.accent,
      surface: LiquidTokens.bgSurface,
      error: LiquidTokens.danger,
    ),
    fontFamily: '.SF Pro Text', // Native iOS SF Pro fallback
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.37,
        color: LiquidTokens.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.36,
        color: LiquidTokens.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.35,
        color: LiquidTokens.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.38,
        color: LiquidTokens.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: LiquidTokens.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        color: LiquidTokens.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        color: LiquidTokens.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        color: LiquidTokens.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.08,
        color: LiquidTokens.textTertiary,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        color: LiquidTokens.textPrimary,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: LiquidTokens.textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: LiquidTokens.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: LiquidTokens.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LiquidTokens.radiusMd),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: LiquidTokens.glassBorderSubtle,
      thickness: 1,
      space: 1,
    ),
  );
}
