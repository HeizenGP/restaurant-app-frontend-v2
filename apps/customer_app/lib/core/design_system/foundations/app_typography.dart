import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String displayFontFamily = 'Cormorant Garamond';
  static const String bodyFontFamily = 'DM Sans';

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        color: primary,
        fontFamily: displayFontFamily,
        fontSize: 31,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        color: primary,
        fontFamily: displayFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
      headlineLarge: TextStyle(
        color: primary,
        fontFamily: displayFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontFamily: displayFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.15,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontFamily: bodyFontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleSmall: TextStyle(
        color: primary,
        fontFamily: bodyFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        color: primary,
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        color: secondary,
        fontFamily: bodyFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        color: secondary,
        fontFamily: bodyFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      labelLarge: const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      labelMedium: TextStyle(
        color: secondary,
        fontFamily: bodyFontFamily,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      labelSmall: const TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 8,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }
}
