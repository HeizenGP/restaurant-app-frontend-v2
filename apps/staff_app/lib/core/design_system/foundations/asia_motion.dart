import 'package:flutter/material.dart';

abstract final class AsiaMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration deliberate = Duration(milliseconds: 400);

  static const Curve standardEasing = Curves.easeOutCubic;
  static const Curve energeticEasing = Curves.easeOutBack;
}
