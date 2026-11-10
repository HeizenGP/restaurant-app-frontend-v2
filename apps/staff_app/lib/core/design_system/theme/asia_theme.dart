import 'package:flutter/material.dart';

import '../foundations/asia_colors.dart';
import '../foundations/asia_radii.dart';
import '../foundations/asia_typography.dart';

abstract final class AsiaTheme {
  static ThemeData dark() {
    const AsiaThemeTokens tokens = AsiaThemeTokens.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AsiaTypography.sansFamily,
      scaffoldBackgroundColor: tokens.canvas,
      cardColor: tokens.card,
      dividerColor: tokens.border,
      colorScheme: ColorScheme.dark(
        surface: tokens.card,
        primary: tokens.brandCrimson,
        secondary: tokens.brandGold,
        error: tokens.error,
        onSurface: tokens.textPrimary,
        outline: tokens.border,
      ),
      extensions: const <ThemeExtension<dynamic>>[tokens],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.cardElevated,
        border: OutlineInputBorder(
          borderRadius: AsiaRadii.md,
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AsiaRadii.md,
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AsiaRadii.md,
          borderSide: BorderSide(color: tokens.brandCrimson, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AsiaRadii.md,
          borderSide: BorderSide(color: tokens.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.card,
        shape: const RoundedRectangleBorder(borderRadius: AsiaRadii.lg),
        elevation: 12,
      ),
    );
  }

  static ThemeData light() {
    const AsiaThemeTokens tokens = AsiaThemeTokens.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AsiaTypography.sansFamily,
      scaffoldBackgroundColor: tokens.canvas,
      cardColor: tokens.card,
      dividerColor: tokens.border,
      colorScheme: ColorScheme.light(
        surface: tokens.card,
        primary: tokens.brandCrimson,
        secondary: tokens.brandGold,
        error: tokens.error,
        onSurface: tokens.textPrimary,
        outline: tokens.border,
      ),
      extensions: const <ThemeExtension<dynamic>>[tokens],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.cardElevated,
        border: OutlineInputBorder(
          borderRadius: AsiaRadii.md,
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AsiaRadii.md,
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AsiaRadii.md,
          borderSide: BorderSide(color: tokens.brandCrimson, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AsiaRadii.md,
          borderSide: BorderSide(color: tokens.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.card,
        shape: const RoundedRectangleBorder(borderRadius: AsiaRadii.lg),
        elevation: 8,
      ),
    );
  }
}
