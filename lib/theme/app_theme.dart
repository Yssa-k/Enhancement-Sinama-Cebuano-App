import 'package:flutter/material.dart';

/// Color constants for the Sinama Translator App
/// Modern, minimal, and culturally inspired design system
class AppColors {
  // Primary Colors
  static const Color primaryForestGreen = Color(
    0xFF2F5D50,
  ); // Deep forest green - trust & language identity
  static const Color secondarySageGreen = Color(
    0xFF8FB8A8,
  ); // Soft sage green - accents & highlights

  // Background & Text
  static const Color backgroundWarmOffWhite = Color(
    0xFFF6F4EE,
  ); // Warm off-white - modern & calm
  static const Color textCharcoalGray = Color(0xFF2E2E2E); // Primary text
  static const Color textMutedGray = Color(0xFF6B6B6B); // Secondary text

  // Accent
  static const Color accentMutedGold = Color(
    0xFFC8A75E,
  ); // Muted gold - emphasis & active states

  // Additional utilities
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color shadowColor = Color(0x1F000000); // Subtle shadow
  static const Color dividerColor = Color(0xFFE5E1D9); // Light divider
}

/// App Theme - Centralized theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryForestGreen,
        primary: AppColors.primaryForestGreen,
        secondary: AppColors.secondarySageGreen,
        tertiary: AppColors.accentMutedGold,
        surface: AppColors.backgroundWarmOffWhite,
        surfaceContainerHighest: AppColors.backgroundWarmOffWhite,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onTertiary: AppColors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.backgroundWarmOffWhite,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryForestGreen,
        foregroundColor: AppColors.white,
        elevation: 4,
        shadowColor: AppColors.shadowColor,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryForestGreen.withOpacity(0.95),
        selectedItemColor: AppColors.accentMutedGold,
        unselectedItemColor: AppColors.textMutedGray.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryForestGreen,
          foregroundColor: AppColors.white,
          elevation: 6,
          shadowColor: AppColors.shadowColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textCharcoalGray,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textCharcoalGray,
          letterSpacing: 0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textCharcoalGray,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textCharcoalGray,
          letterSpacing: 0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textCharcoalGray,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textCharcoalGray,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textCharcoalGray,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMutedGray,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textCharcoalGray,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textCharcoalGray,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMutedGray,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.1,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryForestGreen,
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMutedGray,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          color: AppColors.primaryForestGreen,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textCharcoalGray,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
        space: 16,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  /// Utility function to create a modern pill-shaped button
  static ButtonStyle modernPillButtonStyle({
    Color backgroundColor = AppColors.primaryForestGreen,
    Color textColor = AppColors.white,
    double elevation = 6,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: elevation,
      shadowColor: AppColors.shadowColor,
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
