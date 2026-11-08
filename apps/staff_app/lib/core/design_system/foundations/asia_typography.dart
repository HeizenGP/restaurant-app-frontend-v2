import 'package:flutter/material.dart';

abstract final class AsiaTypography {
  static const String serifFamily = 'Cormorant Garamond';
  static const String sansFamily = 'DM Sans';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: serifFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: serifFamily,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: serifFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.45,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.35,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle metricLarge = TextStyle(
    fontFamily: serifFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const TextStyle metricMedium = TextStyle(
    fontFamily: serifFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.15,
  );
}
