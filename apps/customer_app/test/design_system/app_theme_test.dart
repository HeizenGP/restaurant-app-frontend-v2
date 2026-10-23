import 'package:customer_app/app/theme/theme_mode_controller.dart';
import 'package:customer_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light and dark themes preserve the configured semantic palette', () {
    final AppPalette light = AppTheme.light.extension<AppPalette>()!;
    final AppPalette dark = AppTheme.dark.extension<AppPalette>()!;

    expect(light.background, const Color(0xFFFCF9F5));
    expect(light.brandRed, const Color(0xFF8E292E));
    expect(light.accentGold, const Color(0xFFC3934F));
    expect(light.textAccent, const Color(0xFF95692A));
    expect(light.controlBorder, const Color(0xFFE4DFD7));
    expect(dark.background, const Color(0xFF151718));
    expect(dark.brandRed, const Color(0xFFC35350));
    expect(dark.accentGold, const Color(0xFFE3BD73));
    expect(dark.brandSurface, const Color(0xFFBB4548));
    expect(dark.selectedForeground, const Color(0xFFE57B76));
    expect(dark.controlSurface, const Color(0xFF232526));
    expect(dark.controlBorder, const Color(0xFF3B3F3E));
  });

  test('readable semantic colors meet WCAG AA contrast', () {
    const double minimumNormalTextContrast = 4.5;

    for (final AppPalette palette in <AppPalette>[
      AppPalette.light,
      AppPalette.dark,
    ]) {
      expect(
        _contrastRatio(palette.textAccent, palette.background),
        greaterThanOrEqualTo(minimumNormalTextContrast),
      );
      expect(
        _contrastRatio(palette.selectedForeground, palette.iconTile),
        greaterThanOrEqualTo(minimumNormalTextContrast),
      );
      expect(
        _contrastRatio(palette.onBrand, palette.brandSurface),
        greaterThanOrEqualTo(minimumNormalTextContrast),
      );
      expect(
        _contrastRatio(palette.onAccent, palette.accentGold),
        greaterThanOrEqualTo(minimumNormalTextContrast),
      );
    }

    expect(AppTheme.dark.colorScheme.onSecondary, AppPalette.dark.onAccent);
  });

  test('themes use the approved display and body font families', () {
    final TextTheme lightText = AppTheme.light.textTheme;
    final TextTheme darkText = AppTheme.dark.textTheme;

    expect(lightText.displayLarge?.fontFamily, AppTypography.displayFontFamily);
    expect(lightText.bodyMedium?.fontFamily, AppTypography.bodyFontFamily);
    expect(darkText.displayLarge?.fontFamily, AppTypography.displayFontFamily);
    expect(darkText.bodyMedium?.fontFamily, AppTypography.bodyFontFamily);
  });

  test('theme controller toggles without changing application data', () {
    final ThemeModeController controller = ThemeModeController();
    addTearDown(controller.dispose);

    expect(controller.value, ThemeMode.light);
    controller.toggle();
    expect(controller.value, ThemeMode.dark);
    controller.toggle();
    expect(controller.value, ThemeMode.light);
  });
}

double _contrastRatio(Color foreground, Color background) {
  final double foregroundLuminance = foreground.computeLuminance();
  final double backgroundLuminance = background.computeLuminance();
  final double lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final double darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;

  return (lighter + 0.05) / (darker + 0.05);
}
