import 'package:flutter/material.dart';

import '../foundations/asia_colors.dart';
import '../foundations/asia_typography.dart';

@immutable
class AsiaTheme extends ThemeExtension<AsiaTheme> {
  const AsiaTheme({
    required this.bg,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brandCrimson,
    required this.brandGold,
    required this.brandGoldMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.isDark,
  });

  final Color bg;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color brandCrimson;
  final Color brandGold;
  final Color brandGoldMuted;
  final Color success;
  final Color warning;
  final Color error;
  final bool isDark;

  static const AsiaTheme light = AsiaTheme(
    bg: AsiaColors.lightBg,
    surface: AsiaColors.lightSurface,
    surfaceSubtle: AsiaColors.lightSurfaceSubtle,
    border: AsiaColors.lightBorder,
    borderSubtle: AsiaColors.lightBorderSubtle,
    textPrimary: AsiaColors.lightTextPrimary,
    textSecondary: AsiaColors.lightTextSecondary,
    textTertiary: AsiaColors.lightTextTertiary,
    brandCrimson: AsiaColors.brandCrimson,
    brandGold: AsiaColors.brandGold,
    brandGoldMuted: AsiaColors.brandGoldMuted,
    success: AsiaColors.success,
    warning: AsiaColors.warning,
    error: AsiaColors.error,
    isDark: false,
  );

  static const AsiaTheme dark = AsiaTheme(
    bg: AsiaColors.darkBg,
    surface: AsiaColors.darkSurface,
    surfaceSubtle: AsiaColors.darkSurfaceSubtle,
    border: AsiaColors.darkBorder,
    borderSubtle: AsiaColors.darkBorderSubtle,
    textPrimary: AsiaColors.darkTextPrimary,
    textSecondary: AsiaColors.darkTextSecondary,
    textTertiary: AsiaColors.darkTextTertiary,
    brandCrimson: AsiaColors.brandCrimsonLight,
    brandGold: AsiaColors.brandGoldLight,
    brandGoldMuted: AsiaColors.brandGoldDarkMuted,
    success: AsiaColors.success,
    warning: AsiaColors.warning,
    error: AsiaColors.error,
    isDark: true,
  );

  static AsiaTheme of(BuildContext context) {
    final AsiaTheme? theme = Theme.of(context).extension<AsiaTheme>();
    return theme ?? (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AsiaTheme copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceSubtle,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? brandCrimson,
    Color? brandGold,
    Color? brandGoldMuted,
    Color? success,
    Color? warning,
    Color? error,
    bool? isDark,
  }) {
    return AsiaTheme(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      brandCrimson: brandCrimson ?? this.brandCrimson,
      brandGold: brandGold ?? this.brandGold,
      brandGoldMuted: brandGoldMuted ?? this.brandGoldMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AsiaTheme lerp(ThemeExtension<AsiaTheme>? other, double t) {
    if (other is! AsiaTheme) return this;
    return AsiaTheme(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      brandCrimson: Color.lerp(brandCrimson, other.brandCrimson, t)!,
      brandGold: Color.lerp(brandGold, other.brandGold, t)!,
      brandGoldMuted: Color.lerp(brandGoldMuted, other.brandGoldMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      isDark: other.isDark,
    );
  }
}

extension AsiaThemeContextX on BuildContext {
  AsiaTheme get asiaTheme => AsiaTheme.of(this);
}

abstract final class AsiaAppTheme {
  static ThemeData get light => _build(AsiaTheme.light, Brightness.light);
  static ThemeData get dark => _build(AsiaTheme.dark, Brightness.dark);

  static ThemeData _build(AsiaTheme tokens, Brightness brightness) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: tokens.brandCrimson,
      onPrimary: Colors.white,
      secondary: tokens.brandGold,
      onSecondary: Colors.white,
      error: tokens.error,
      onError: Colors.white,
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: 0.8,
        space: 1,
      ),
      extensions: <ThemeExtension<dynamic>>[tokens],
      textTheme: TextTheme(
        displayLarge: AsiaTypography.displayLarge.copyWith(color: tokens.textPrimary),
        titleLarge: AsiaTypography.titleLarge.copyWith(color: tokens.textPrimary),
        titleMedium: AsiaTypography.titleMedium.copyWith(color: tokens.textPrimary),
        titleSmall: AsiaTypography.titleSmall.copyWith(color: tokens.textPrimary),
        bodyLarge: AsiaTypography.bodyLarge.copyWith(color: tokens.textPrimary),
        bodyMedium: AsiaTypography.bodyMedium.copyWith(color: tokens.textSecondary),
        bodySmall: AsiaTypography.bodySmall.copyWith(color: tokens.textTertiary),
        labelLarge: AsiaTypography.labelLarge.copyWith(color: tokens.textPrimary),
        labelMedium: AsiaTypography.labelMedium.copyWith(color: tokens.textSecondary),
        labelSmall: AsiaTypography.labelSmall.copyWith(color: tokens.textTertiary),
      ),
    );
  }
}
