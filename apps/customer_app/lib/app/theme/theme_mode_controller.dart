import 'package:flutter/material.dart';

final class ThemeModeController extends ValueNotifier<ThemeMode> {
  ThemeModeController({ThemeMode initialMode = ThemeMode.light})
    : super(initialMode);

  void toggle() {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setMode(ThemeMode mode) {
    value = mode;
  }
}
