import 'package:flutter/material.dart';

/// App Theme Configuration
class AppTheme {
  // Default Theme Colors (Green - may mắn)
  static const Color defaultLightPrimary = Color(0xFF4CAF50);
  static const Color defaultLightSecondary = Color(0xFFFF9800);
  static const Color defaultDarkPrimary = Color(0xFF66BB6A);
  static const Color defaultDarkSecondary = Color(0xFFFFB74D);

  // Spring Theme Colors (Pink - mùa xuân)
  static const Color springLightPrimary = Color(0xFFE91E63);
  static const Color springLightSecondary = Color(0xFFFF6B9D);
  static const Color springDarkPrimary = Color(0xFFF06292);
  static const Color springDarkSecondary = Color(0xFFFF8FA3);

  // Summer Theme Colors (Blue - mùa hạ)
  static const Color summerLightPrimary = Color(0xFF2196F3);
  static const Color summerLightSecondary = Color(0xFF64B5F6);
  static const Color summerDarkPrimary = Color(0xFF42A5F5);
  static const Color summerDarkSecondary = Color(0xFF90CAF9);

  // Autumn Theme Colors (Orange - mùa thu)
  static const Color autumnLightPrimary = Color(0xFFFF9800);
  static const Color autumnLightSecondary = Color(0xFFFFB74D);
  static const Color autumnDarkPrimary = Color(0xFFFFA726);
  static const Color autumnDarkSecondary = Color(0xFFFFCC80);

  // Winter Theme Colors (Cyan - mùa đông)
  static const Color winterLightPrimary = Color(0xFF00BCD4);
  static const Color winterLightSecondary = Color(0xFF4DD0E1);
  static const Color winterDarkPrimary = Color(0xFF26C6DA);
  static const Color winterDarkSecondary = Color(0xFF80DEEA);

  // Tet Theme Colors (Red - Tết)
  static const Color tetLightPrimary = Color(0xFFF44336);
  static const Color tetLightSecondary = Color(0xFFEF5350);
  static const Color tetDarkPrimary = Color(0xFFE57373);
  static const Color tetDarkSecondary = Color(0xFFEF9A9A);

  // Common Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF212121);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Color(0xFFFFFFFF);

  /// Get theme colors based on theme name
  static (Color primary, Color secondary) getThemeColors(String themeName, bool isDark) {
    switch (themeName) {
      case 'spring':
        return isDark
            ? (springDarkPrimary, springDarkSecondary)
            : (springLightPrimary, springLightSecondary);
      case 'summer':
        return isDark
            ? (summerDarkPrimary, summerDarkSecondary)
            : (summerLightPrimary, summerLightSecondary);
      case 'autumn':
        return isDark
            ? (autumnDarkPrimary, autumnDarkSecondary)
            : (autumnLightPrimary, autumnLightSecondary);
      case 'winter':
        return isDark
            ? (winterDarkPrimary, winterDarkSecondary)
            : (winterLightPrimary, winterLightSecondary);
      case 'tet':
        return isDark
            ? (tetDarkPrimary, tetDarkSecondary)
            : (tetLightPrimary, tetLightSecondary);
      default: // 'default'
        return isDark
            ? (defaultDarkPrimary, defaultDarkSecondary)
            : (defaultLightPrimary, defaultLightSecondary);
    }
  }

  static ThemeData getLightTheme([String themeName = 'default']) {
    final (primary, secondary) = getThemeColors(themeName, false);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: lightSurface,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: lightSurface,
      ),
    );
  }

  static ThemeData getDarkTheme([String themeName = 'default']) {
    final (primary, secondary) = getThemeColors(themeName, true);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: darkSurface,
      ),
    );
  }

  // Backward compatibility
  static ThemeData get lightTheme => getLightTheme('default');
  static ThemeData get darkTheme => getDarkTheme('default');
}

