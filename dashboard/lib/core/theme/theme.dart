import 'package:flutter/material.dart';

class Themes {
  final lightTheme = ThemeData.light().copyWith(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      // Primary brand colors
      primary: Color(0xFF007AFF), // AppColors.blue
      secondary: Color(0xFF0A74FF), // AppColors.blueHeader
      // Surfaces
      surface: Color(0xFFFFFFFF), // AppColors.cardBackground
      surfaceContainerHighest: Color(0xFFFFFFFF),

      // Errors
      error: Colors.red,

      // Text colors on top of primary/secondary
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,

      // Normal text
      onSurface: Color(0xFF1D1D1F), // textPrimary
      onSurfaceVariant: Color(0xFF6B7280), // textSecondary
      // Border / Divider
      tertiary: Color(0xFFD1D5DB),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A74FF), // blueHeader
      elevation: 0,
      foregroundColor: Colors.white,
    ),

    scaffoldBackgroundColor: const Color(0xFFF2F2F7), // pageBackground
  );

  final darkTheme = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      primary: Color(0xFF007AFF),
      secondary: Color(0xFF0A74FF),

      // Dark mode surfaces (iOS-style)
      surface: Color(0xFF1C1C1E),
      surfaceContainerHighest: Color(0xFF2C2C2E),

      error: Colors.red,

      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,

      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFB0B0B0),

      tertiary: Color(0xFFD1D5DB),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C1E),
      elevation: 0,
      foregroundColor: Colors.white,
    ),

    scaffoldBackgroundColor: const Color(0xFF000000),
  );
}
