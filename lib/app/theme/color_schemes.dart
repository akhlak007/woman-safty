import 'package:flutter/material.dart';

class AppColorSchemes {
  const AppColorSchemes._();

  static const Color seedColor = Color(0xFFC51620); // Emergency crimson
  static const Color secondaryColor = Color(0xFF146C94); // Calm medical blue
  static const Color tertiaryColor = Color(0xFFE56A18); // Dispatch amber
  static const Color errorColor = Color(0xFFC51620); // Critical / emergency

  // Neutral tones
  static const Color lightBackground = Color(0xFFF8F8F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    secondary: secondaryColor,
    tertiary: tertiaryColor,
    error: errorColor,
    surface: lightSurface,
    brightness: Brightness.light,
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    secondary: secondaryColor,
    tertiary: tertiaryColor,
    error: errorColor,
    surface: darkSurface,
    brightness: Brightness.dark,
  );
}
