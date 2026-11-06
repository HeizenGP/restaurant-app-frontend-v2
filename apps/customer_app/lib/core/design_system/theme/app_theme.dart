import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_radii.dart';
import '../foundations/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light =>
      _build(brightness: Brightness.light, palette: AppPalette.light);

  static ThemeData get dark =>
      _build(brightness: Brightness.dark, palette: AppPalette.dark);

  static ThemeData _build({
    required Brightness brightness,
    required AppPalette palette,
  }) {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: palette.brandRed,
          brightness: brightness,
        ).copyWith(
          primary: palette.brandSurface,
          onPrimary: palette.onBrand,
          secondary: palette.accentGold,
          onSecondary: palette.onAccent,
          surface: palette.surface,
          onSurface: palette.textPrimary,
          error: palette.brandSurface,
          onError: palette.onBrand,
          outline: palette.border,
        );

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.control),
      borderSide: BorderSide(color: palette.controlBorder, width: 1.0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      dividerColor: palette.border,
      fontFamily: AppTypography.bodyFontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          fontFamily: AppTypography.bodyFontFamily,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary, size: 20),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: palette.border, width: 1.0),
        ),
      ),
      textTheme: AppTypography.textTheme(
        primary: palette.textPrimary,
        secondary: palette.textSecondary,
      ),
      extensions: <ThemeExtension<dynamic>>[palette],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.controlSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.disabled),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: palette.brandRed, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 1.2),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
        labelStyle: TextStyle(color: palette.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.brandSurface,
          foregroundColor: palette.onBrand,
          disabledBackgroundColor: palette.disabled,
          disabledForegroundColor: palette.textSecondary,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          backgroundColor: palette.secondarySurface,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: BorderSide(color: palette.controlBorder, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.brandRed,
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
