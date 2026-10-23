import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color lightBackground = Color(0xFFFCF9F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceTint = Color(0xFFF5EFE7);
  static const Color lightIconTile = Color(0xFFF8F1E8);
  static const Color lightBorder = Color(0xFFE7DDD2);
  static const Color lightTextPrimary = Color(0xFF242120);
  static const Color lightTextSecondary = Color(0xFF746F6A);
  static const Color lightCardTextPrimary = Color(0xFF292422);
  static const Color lightCardTextSecondary = Color(0xFF77716B);
  static const Color lightBrandRed = Color(0xFF8E292E);
  static const Color lightSelectedForeground = Color(0xFF8E2930);
  static const Color lightAccentGold = Color(0xFFC3934F);
  static const Color lightTextAccent = Color(0xFF95692A);
  static const Color lightProfileCover = Color(0xFF902B33);

  static const Color darkBackground = Color(0xFF151718);
  static const Color darkSurface = Color(0xFF222426);
  static const Color darkSurfaceTint = Color(0xFF2B2423);
  static const Color darkIconTile = Color(0xFF332B2A);
  static const Color darkBorder = Color(0xFF393E3C);
  static const Color darkTextPrimary = Color(0xFFF5F1EA);
  static const Color darkTextSecondary = Color(0xFFADB0AD);
  static const Color darkCardTextSecondary = Color(0xFFB2B6B1);
  static const Color darkBrandRed = Color(0xFFC35350);
  static const Color darkAccentGold = Color(0xFFE3BD73);
  static const Color darkBrandSurface = Color(0xFFC35350);
  static const Color darkSelectedForeground = Color(0xFFC45350);
  static const Color darkProfileCover = Color(0xFF48252A);

  static const Color onBrand = Colors.white;
  static const Color lightSuccess = Color(0xFF278063);
  static const Color darkSuccess = Color(0xFF5BA68B);
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceTint,
    required this.controlSurface,
    required this.secondarySurface,
    required this.iconTile,
    required this.border,
    required this.controlBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardTextPrimary,
    required this.cardTextSecondary,
    required this.brandRed,
    required this.brandSurface,
    required this.accentGold,
    required this.onAccent,
    required this.textAccent,
    required this.selectedForeground,
    required this.onBrand,
    required this.success,
    required this.disabled,
    required this.profileCover,
  });

  static const AppPalette light = AppPalette(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceTint: AppColors.lightSurfaceTint,
    controlSurface: AppColors.lightSurface,
    secondarySurface: AppColors.lightSurface,
    iconTile: AppColors.lightIconTile,
    border: AppColors.lightBorder,
    controlBorder: Color(0xFFE4DFD7),
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    cardTextPrimary: AppColors.lightCardTextPrimary,
    cardTextSecondary: AppColors.lightCardTextSecondary,
    brandRed: AppColors.lightBrandRed,
    brandSurface: AppColors.lightBrandRed,
    accentGold: AppColors.lightAccentGold,
    onAccent: AppColors.lightTextPrimary,
    textAccent: AppColors.lightTextAccent,
    selectedForeground: AppColors.lightSelectedForeground,
    onBrand: AppColors.onBrand,
    success: AppColors.lightSuccess,
    disabled: Color(0xFFE4DFD7),
    profileCover: AppColors.lightProfileCover,
  );

  static const AppPalette dark = AppPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceTint: AppColors.darkSurfaceTint,
    controlSurface: Color(0xFF232526),
    secondarySurface: Color(0xFF1B1D1F),
    iconTile: AppColors.darkIconTile,
    border: AppColors.darkBorder,
    controlBorder: Color(0xFF3B3F3E),
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    cardTextPrimary: AppColors.darkTextPrimary,
    cardTextSecondary: AppColors.darkCardTextSecondary,
    brandRed: AppColors.darkBrandRed,
    brandSurface: AppColors.darkBrandSurface,
    accentGold: AppColors.darkAccentGold,
    onAccent: AppColors.darkBackground,
    textAccent: AppColors.darkAccentGold,
    selectedForeground: AppColors.darkSelectedForeground,
    onBrand: AppColors.onBrand,
    success: AppColors.darkSuccess,
    disabled: Color(0xFF3B3F3E),
    profileCover: AppColors.darkProfileCover,
  );

  final Color background;
  final Color surface;
  final Color surfaceTint;
  final Color controlSurface;
  final Color secondarySurface;
  final Color iconTile;
  final Color border;
  final Color controlBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardTextPrimary;
  final Color cardTextSecondary;
  final Color brandRed;
  final Color brandSurface;
  final Color accentGold;
  final Color onAccent;
  final Color textAccent;
  final Color selectedForeground;
  final Color onBrand;
  final Color success;
  final Color disabled;
  final Color profileCover;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceTint,
    Color? controlSurface,
    Color? secondarySurface,
    Color? iconTile,
    Color? border,
    Color? controlBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? cardTextPrimary,
    Color? cardTextSecondary,
    Color? brandRed,
    Color? brandSurface,
    Color? accentGold,
    Color? onAccent,
    Color? textAccent,
    Color? selectedForeground,
    Color? onBrand,
    Color? success,
    Color? disabled,
    Color? profileCover,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      controlSurface: controlSurface ?? this.controlSurface,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      iconTile: iconTile ?? this.iconTile,
      border: border ?? this.border,
      controlBorder: controlBorder ?? this.controlBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      cardTextPrimary: cardTextPrimary ?? this.cardTextPrimary,
      cardTextSecondary: cardTextSecondary ?? this.cardTextSecondary,
      brandRed: brandRed ?? this.brandRed,
      brandSurface: brandSurface ?? this.brandSurface,
      accentGold: accentGold ?? this.accentGold,
      onAccent: onAccent ?? this.onAccent,
      textAccent: textAccent ?? this.textAccent,
      selectedForeground: selectedForeground ?? this.selectedForeground,
      onBrand: onBrand ?? this.onBrand,
      success: success ?? this.success,
      disabled: disabled ?? this.disabled,
      profileCover: profileCover ?? this.profileCover,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) {
      return this;
    }
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t)!,
      controlSurface: Color.lerp(controlSurface, other.controlSurface, t)!,
      secondarySurface: Color.lerp(
        secondarySurface,
        other.secondarySurface,
        t,
      )!,
      iconTile: Color.lerp(iconTile, other.iconTile, t)!,
      border: Color.lerp(border, other.border, t)!,
      controlBorder: Color.lerp(controlBorder, other.controlBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      cardTextPrimary: Color.lerp(cardTextPrimary, other.cardTextPrimary, t)!,
      cardTextSecondary: Color.lerp(
        cardTextSecondary,
        other.cardTextSecondary,
        t,
      )!,
      brandRed: Color.lerp(brandRed, other.brandRed, t)!,
      brandSurface: Color.lerp(brandSurface, other.brandSurface, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      selectedForeground: Color.lerp(
        selectedForeground,
        other.selectedForeground,
        t,
      )!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      success: Color.lerp(success, other.success, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      profileCover: Color.lerp(profileCover, other.profileCover, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get appPalette {
    return Theme.of(this).extension<AppPalette>()!;
  }
}
