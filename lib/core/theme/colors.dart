import 'package:flutter/material.dart';

class AppColors {
  // === Base Backgrounds ===
  static const Color background = Color(0xFF0e0e0e);
  static const Color surface = Color(0xFF0e0e0e);
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF131313);
  static const Color surfaceContainer = Color(0xFF1a1919);
  static const Color surfaceContainerHigh = Color(0xFF201f1f);
  static const Color surfaceContainerHighest = Color(0xFF262626);
  static const Color surfaceBright = Color(0xFF2c2c2c);

  // Glassmorphic variant (60% opacity)
  static const Color surfaceVariant = Color(0x99262626);

  // === Primary (Teal/Neon "Safe" Glow) ===
  static const Color primary = Color(0xFF73ffe3);
  static const Color primaryContainer = Color(0xFF00f5d4);
  static const Color primaryDim = Color(0xFF00e8c9);
  static const Color primaryFixed = Color(0xFF12f8d7);
  static const Color onPrimary = Color(0xFF006152);
  static const Color onPrimaryContainer = Color(0xFF00574a);
  static const Color inversePrimary = Color(0xFF006c5c);

  // === Secondary (Liability/Warning/Red) ===
  static const Color secondary = Color(0xFFff706e);
  static const Color secondaryContainer = Color(0xFF91081a);
  static const Color secondaryDim = Color(0xFFd23e42);
  static const Color onSecondary = Color(0xFF490007);
  static const Color onSecondaryContainer = Color(0xFFffc1be);

  // === Tertiary (Insights/Blue) ===
  static const Color tertiary = Color(0xFF69daff);
  static const Color tertiaryContainer = Color(0xFF00cffc);
  static const Color tertiaryDim = Color(0xFF00c0ea);
  static const Color onTertiary = Color(0xFF004a5d);

  // === Text ===
  static const Color onSurface = Color(0xFFffffff);
  static const Color onSurfaceVariant = Color(0xFFadaaaa);
  static const Color onBackground = Color(0xFFffffff);

  // === Borders ===
  static const Color outline = Color(0xFF777575);
  static const Color outlineVariant = Color(0xFF494847);
  // Ghost border: outlineVariant at 15% opacity
  static Color get ghostBorder => outlineVariant.withOpacity(0.15);

  // === Error ===
  static const Color error = Color(0xFFff716c);
  static const Color errorContainer = Color(0xFF9f0519);
  static const Color onError = Color(0xFF490006);

  // === Utility ===
  static const Color surfaceTint = Color(0xFF73ffe3);

  // Glow helper: primary at low opacity for ambient glow
  static Color get primaryGlow => primary.withOpacity(0.12);
  static Color get primaryAreaFill => primary.withOpacity(0.20);
}
