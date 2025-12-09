import 'package:flutter/material.dart';

class AppTheme {
  // Dark Theme Colors
  static const Color primaryGlowDark = Color(0xFF9D4EDD);
  static const Color secondaryGlowDark = Color(0xFF5E2CA5);
  static const Color accentNeonDark = Color(0xFFFF2A6D);
  static const Color bgDark = Color(0xFF0F0F1A);
  static const Color cardBgDark = Color(0x99191932);
  static const Color borderLightDark = Color(0x4D9D4EDD);
  static const Color textPrimaryDark = Color(0xFFE6E6FF);
  static const Color textSecondaryDark = Color(0xFFA0A0C0);
  static const Color textMutedDark = Color(0xFF707090);

  // Light Theme Colors
  static const Color primaryGlowLight = Color(0xFF7B2CBF);
  static const Color secondaryGlowLight = Color(0xFF5A189A);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color cardBgLight = Color(0xD9FFFFFF);
  static const Color borderLightLight = Color(0x337B2CBF);
  static const Color textPrimaryLight = Color(0xFF212529);
  static const Color textSecondaryLight = Color(0xFF495057);
  static const Color textMutedLight = Color(0xFF6C757D);
}

class AppColors {
  final bool isDark;

  AppColors({required this.isDark});

  Color get primaryGlow =>
      isDark ? AppTheme.primaryGlowDark : AppTheme.primaryGlowLight;
  Color get secondaryGlow =>
      isDark ? AppTheme.secondaryGlowDark : AppTheme.secondaryGlowLight;
  Color get cardBg => isDark ? AppTheme.cardBgDark : AppTheme.cardBgLight;
  Color get borderLight =>
      isDark ? AppTheme.borderLightDark : AppTheme.borderLightLight;
  Color get textPrimary =>
      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
  Color get textSecondary =>
      isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
  Color get textMuted =>
      isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;
  Color get background => isDark ? AppTheme.bgDark : AppTheme.bgLight;
}
