import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/design_system/foundations/asia_colors.dart';
import 'package:staff_app/core/design_system/foundations/asia_radii.dart';
import 'package:staff_app/core/design_system/foundations/asia_spacing.dart';
import 'package:staff_app/core/design_system/foundations/asia_typography.dart';
import 'package:staff_app/core/design_system/theme/asia_theme.dart';

void main() {
  group('Design System Foundations', () {
    test('AsiaPalette contains KAIRO brand colors', () {
      expect(AsiaPalette.crimson, const Color(0xFFE11D48));
      expect(AsiaPalette.gold, const Color(0xFFF59E0B));
      expect(AsiaPalette.jade, const Color(0xFF10B981));
      expect(AsiaPalette.darkCanvas, const Color(0xFF09090B));
      expect(AsiaPalette.lightCanvas, const Color(0xFFF8FAFC));
    });

    test('AsiaRadii defines consistent borders', () {
      expect(AsiaRadii.smRadius.x, 6.0);
      expect(AsiaRadii.mdRadius.x, 10.0);
      expect(AsiaRadii.lgRadius.x, 16.0);
      expect(AsiaRadii.xlRadius.x, 24.0);
      expect(AsiaRadii.pillRadius.x, 999.0);
    });

    test('AsiaSpacing defines 4px/8px grid values', () {
      expect(AsiaSpacing.xs, 4.0);
      expect(AsiaSpacing.sm, 8.0);
      expect(AsiaSpacing.md, 12.0);
      expect(AsiaSpacing.lg, 16.0);
      expect(AsiaSpacing.xl, 24.0);
      expect(AsiaSpacing.xxl, 32.0);
    });

    test('AsiaTypography uses DM Sans and Cormorant Garamond', () {
      expect(AsiaTypography.serifFamily, 'Cormorant Garamond');
      expect(AsiaTypography.sansFamily, 'DM Sans');
      expect(AsiaTypography.displayLarge.fontFamily, 'Cormorant Garamond');
      expect(AsiaTypography.headingLarge.fontFamily, 'DM Sans');
    });

    test(
      'AsiaTheme builds valid dark and light theme data with tokens extension',
      () {
        final ThemeData dark = AsiaTheme.dark();
        expect(dark.brightness, Brightness.dark);
        expect(dark.extension<AsiaThemeTokens>(), isNotNull);
        expect(
          dark.extension<AsiaThemeTokens>()?.canvas,
          AsiaPalette.darkCanvas,
        );

        final ThemeData light = AsiaTheme.light();
        expect(light.brightness, Brightness.light);
        expect(light.extension<AsiaThemeTokens>(), isNotNull);
        expect(
          light.extension<AsiaThemeTokens>()?.canvas,
          AsiaPalette.lightCanvas,
        );
      },
    );
  });
}
