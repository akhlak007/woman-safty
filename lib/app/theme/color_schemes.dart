import 'package:flutter/material.dart';

class AppColorSchemes {
  const AppColorSchemes._();

  static const Color seedColor = Color(0xFFC2185B); // Deep Rose (Safety & Care)
  static const Color secondaryColor = Color(0xFF1565C0); // Calm Medical Blue
  static const Color tertiaryColor = Color(0xFFFF6F00); // Amber / Attention
  static const Color errorColor = Color(0xFFD32F2F); // Critical / Error

  // Neutral tones
  static const Color lightBackground = Color(0xFFFFF8F9);
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
