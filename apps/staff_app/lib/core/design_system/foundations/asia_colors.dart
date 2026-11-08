import 'package:flutter/material.dart';

abstract final class AsiaPalette {
  // Brand accents
  static const Color crimson = Color(0xFFE11D48);
  static const Color crimsonHover = Color(0xFFBE123C);
  static const Color crimsonMuted = Color(0x26E11D48);

  static const Color gold = Color(0xFFF59E0B);
  static const Color goldHover = Color(0xFFD97706);
  static const Color goldMuted = Color(0x26F59E0B);

  static const Color jade = Color(0xFF10B981);
  static const Color jadeHover = Color(0xFF059669);
  static const Color jadeMuted = Color(0x2610B981);

  static const Color blue = Color(0xFF3B82F6);
  static const Color blueMuted = Color(0x263B82F6);

  // Dark Theme Surfaces
  static const Color darkCanvas = Color(0xFF09090B);
  static const Color darkCard = Color(0xFF121215);
  static const Color darkElevated = Color(0xFF18181B);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkBorderSubtle = Color(0xFF1F1F23);
  static const Color darkSidebar = Color(0xFF0F0E13);

  // Light Theme Surfaces
  static const Color lightCanvas = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFEDF2F7);
  static const Color lightSidebar = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDarkPrimary = Color(0xFFF4F4F5);
  static const Color textDarkSecondary = Color(0xFFA1A1AA);
  static const Color textDarkTertiary = Color(0xFF71717A);

  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF475569);
  static const Color textLightTertiary = Color(0xFF64748B);
}

class AsiaThemeTokens extends ThemeExtension<AsiaThemeTokens> {
  const AsiaThemeTokens({
    required this.canvas,
    required this.card,
    required this.cardElevated,
    required this.border,
    required this.borderSubtle,
    required this.sidebar,
    required this.sidebarSelected,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brandCrimson,
    required this.brandGold,
    required this.brandJade,
    required this.info,
    required this.error,
    required this.warning,
    required this.success,
  });

  final Color canvas;
  final Color card;
  final Color cardElevated;
  final Color border;
  final Color borderSubtle;
  final Color sidebar;
  final Color sidebarSelected;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color brandCrimson;
  final Color brandGold;
  final Color brandJade;
  final Color info;
  final Color error;
  final Color warning;
  final Color success;

  static const AsiaThemeTokens dark = AsiaThemeTokens(
    canvas: AsiaPalette.darkCanvas,
    card: AsiaPalette.darkCard,
    cardElevated: AsiaPalette.darkElevated,
    border: AsiaPalette.darkBorder,
    borderSubtle: AsiaPalette.darkBorderSubtle,
    sidebar: AsiaPalette.darkSidebar,
    sidebarSelected: Color(0xFF1E1C24),
    textPrimary: AsiaPalette.textDarkPrimary,
    textSecondary: AsiaPalette.textDarkSecondary,
    textTertiary: AsiaPalette.textDarkTertiary,
    brandCrimson: AsiaPalette.crimson,
    brandGold: AsiaPalette.gold,
    brandJade: AsiaPalette.jade,
    info: AsiaPalette.blue,
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    success: Color(0xFF10B981),
  );

  static const AsiaThemeTokens light = AsiaThemeTokens(
    canvas: AsiaPalette.lightCanvas,
    card: AsiaPalette.lightCard,
    cardElevated: AsiaPalette.lightElevated,
    border: AsiaPalette.lightBorder,
    borderSubtle: AsiaPalette.lightBorderSubtle,
    sidebar: AsiaPalette.lightSidebar,
    sidebarSelected: Color(0xFFFFF1F2),
    textPrimary: AsiaPalette.textLightPrimary,
    textSecondary: AsiaPalette.textLightSecondary,
    textTertiary: AsiaPalette.textLightTertiary,
    brandCrimson: AsiaPalette.crimsonHover,
    brandGold: AsiaPalette.goldHover,
    brandJade: AsiaPalette.jadeHover,
    info: AsiaPalette.blue,
    error: Color(0xFFDC2626),
    warning: Color(0xFFD97706),
    success: Color(0xFF059669),
  );

  @override
  ThemeExtension<AsiaThemeTokens> copyWith({
    Color? canvas,
    Color? card,
    Color? cardElevated,
    Color? border,
    Color? borderSubtle,
    Color? sidebar,
    Color? sidebarSelected,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? brandCrimson,
    Color? brandGold,
    Color? brandJade,
    Color? info,
    Color? error,
    Color? warning,
    Color? success,
  }) {
    return AsiaThemeTokens(
      canvas: canvas ?? this.canvas,
      card: card ?? this.card,
      cardElevated: cardElevated ?? this.cardElevated,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      sidebar: sidebar ?? this.sidebar,
      sidebarSelected: sidebarSelected ?? this.sidebarSelected,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      brandCrimson: brandCrimson ?? this.brandCrimson,
      brandGold: brandGold ?? this.brandGold,
      brandJade: brandJade ?? this.brandJade,
      info: info ?? this.info,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
    );
  }

  @override
  ThemeExtension<AsiaThemeTokens> lerp(
    covariant ThemeExtension<AsiaThemeTokens>? other,
    double t,
  ) {
    if (other is! AsiaThemeTokens) return this;
    return AsiaThemeTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardElevated: Color.lerp(cardElevated, other.cardElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      sidebarSelected: Color.lerp(sidebarSelected, other.sidebarSelected, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      brandCrimson: Color.lerp(brandCrimson, other.brandCrimson, t)!,
      brandGold: Color.lerp(brandGold, other.brandGold, t)!,
      brandJade: Color.lerp(brandJade, other.brandJade, t)!,
      info: Color.lerp(info, other.info, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension AsiaThemeContext on BuildContext {
  AsiaThemeTokens get tokens =>
      Theme.of(this).extension<AsiaThemeTokens>() ?? AsiaThemeTokens.dark;
}
