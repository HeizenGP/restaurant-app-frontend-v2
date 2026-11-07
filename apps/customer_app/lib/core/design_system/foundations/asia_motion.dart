import 'package:flutter/animation.dart';

/// Motion tokens for KAIRO's restrained, responsive interaction language.
abstract final class AsiaMotion {
  static const Duration instant = Duration.zero;
  static const Duration press = Duration(milliseconds: 90);
  static const Duration feedback = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration entrance = Duration(milliseconds: 640);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve entranceCurve = Curves.easeOutQuart;
}
