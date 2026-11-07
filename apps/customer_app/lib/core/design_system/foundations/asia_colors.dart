import 'package:flutter/material.dart';

/// Paleta de colores atómica y curada para KAIRO.
/// Estética imperial asiática contemporánea: carmesí bermellón profundo, oro radiante, obsidiana OLED y porcelana.
abstract final class AsiaColors {
  // Light Canvas (Porcelana pura)
  static const Color lightBg = Color(0xFFFBFBFD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF4F4F8);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBorderSubtle = Color(0xFFF0F1F4);

  // Dark Canvas (Obsidiana OLED y Grafito profundo)
  static const Color darkBg = Color(0xFF0C0D10);
  static const Color darkSurface = Color(0xFF14161B);
  static const Color darkSurfaceSubtle = Color(0xFF1C1E25);
  static const Color darkBorder = Color(0xFF262832);
  static const Color darkBorderSubtle = Color(0xFF1F212A);

  // Tipografía / Textos
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF64748B);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // Marca Principal: Carmesí Bermellón Imperial
  static const Color brandCrimson = Color(0xFFB91C1C);
  static const Color brandCrimsonLight = Color(0xFFDC2626);
  static const Color brandCrimsonDark = Color(0xFF991B1B);

  // Marca Secundaria: Oro Cálido & Ámbar
  static const Color brandGold = Color(0xFFD97706);
  static const Color brandGoldText = Color(0xFFA16207);
  static const Color brandGoldLight = Color(0xFFF59E0B);
  static const Color brandGoldMuted = Color(0xFFFEF3C7);
  static const Color brandGoldDarkMuted = Color(0xFF451A03);

  // Semánticos
  static const Color success = Color(0xFF16A34A);
  static const Color successSubtle = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFEA580C);
  static const Color error = Color(0xFFE11D48);
  static const Color errorSubtle = Color(0xFFFFE4E6);
  static const Color info = Color(0xFF2563EB);

  // Cartografía KAIRO — Mapbox Standard.
  // Tonos deliberadamente neutros y cálidos para mantener detalle urbano sin
  // competir con los acentos carmesí/dorado de la interfaz.
  static const Color mapLightLand = Color(0xFFECE8E1);
  static const Color mapLightRoad = Color(0xFFFAF8F3);
  static const Color mapLightRoadMajor = Color(0xFFE1CDB6);
  static const Color mapLightBuilding = Color(0xFFD8D2C9);
  static const Color mapLightGreen = Color(0xFFC7D6C0);
  static const Color mapLightWater = Color(0xFFB9D0D5);
  static const Color mapLightLabel = Color(0xFF403D38);
  static const Color mapLightPoi = Color(0xFF665E54);
  static const Color mapLightCommercial = Color(0xFFE4D4CC);
  static const Color mapLightInstitutional = Color(0xFFD8D7C6);

  static const Color mapDarkLand = Color(0xFF25282C);
  static const Color mapDarkRoad = Color(0xFF454A50);
  static const Color mapDarkRoadMajor = Color(0xFF675A50);
  static const Color mapDarkBuilding = Color(0xFF363B40);
  static const Color mapDarkGreen = Color(0xFF32473C);
  static const Color mapDarkWater = Color(0xFF293F48);
  static const Color mapDarkLabel = Color(0xFFF1EAE0);
  static const Color mapDarkPoi = Color(0xFFD8CABC);
  static const Color mapDarkCommercial = Color(0xFF44393A);
  static const Color mapDarkInstitutional = Color(0xFF3E4038);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
