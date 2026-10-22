import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_radii.dart';
import '../foundations/app_typography.dart';

class ChifaAppHeader extends StatelessWidget {
  const ChifaAppHeader({
    required this.isDarkMode,
    required this.onToggleTheme,
    this.initials = 'C',
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 51),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'CHIFA ASIA',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineLarge
                      ?.copyWith(fontSize: 24),
                ),
                Text(
                  'EL SABOR NOS UNE',
                  maxLines: 1,
                  style: TextStyle(
                    color: palette.textAccent,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Notificaciones no disponibles',
            excludeSemantics: true,
            child: _HeaderTile(icon: LucideIcons.bell, color: palette.brandRed),
          ),
          const SizedBox(width: 6),
          Semantics(
            button: true,
            label: isDarkMode ? 'Activar tema claro' : 'Activar tema oscuro',
            onTap: onToggleTheme,
            excludeSemantics: true,
            child: Tooltip(
              message: isDarkMode ? 'Tema claro' : 'Tema oscuro',
              child: InkWell(
                key: const Key('theme-toggle'),
                onTap: onToggleTheme,
                borderRadius: BorderRadius.circular(AppRadii.control),
                child: SizedBox.square(
                  dimension: 48,
                  child: Center(
                    child: _HeaderTile(
                      icon: isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                      color: isDarkMode ? palette.accentGold : palette.brandRed,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            image: true,
            label: 'Avatar de cliente $initials',
            excludeSemantics: true,
            child: CircleAvatar(
              radius: 21,
              backgroundColor: palette.brandSurface,
              foregroundColor: palette.onBrand,
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderTile extends StatelessWidget {
  const _HeaderTile({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 41,
      height: 41,
      decoration: BoxDecoration(
        color: context.appPalette.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 21),
    );
  }
}
