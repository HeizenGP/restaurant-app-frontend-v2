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
    this.onAvatarPressed,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final String initials;
  final VoidCallback? onAvatarPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final Color utilityIconColor = isDarkMode
        ? palette.accentGold
        : palette.brandRed;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 51),
      child: Padding(
        padding: const EdgeInsets.only(right: 13),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'CHIFA ASIA',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'EL SABOR NOS UNE',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: palette.textAccent,
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Semantics(
              label: 'Notificaciones no disponibles',
              excludeSemantics: true,
              child: _HeaderTile(
                icon: LucideIcons.bell,
                color: utilityIconColor,
              ),
            ),
            const SizedBox(width: 6),
            Semantics(
              button: true,
              label: isDarkMode ? 'Activar tema claro' : 'Activar tema oscuro',
              onTap: onToggleTheme,
              excludeSemantics: true,
              child: Tooltip(
                message: isDarkMode ? 'Tema claro' : 'Tema oscuro',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('theme-toggle'),
                    onTap: onToggleTheme,
                    borderRadius: BorderRadius.circular(AppRadii.control),
                    child: _HeaderTile(
                      icon: isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                      color: utilityIconColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              image: onAvatarPressed == null,
              button: onAvatarPressed != null,
              label: onAvatarPressed == null
                  ? 'Avatar de cliente $initials'
                  : 'Opciones de la cuenta de $initials',
              onTap: onAvatarPressed,
              excludeSemantics: true,
              child: GestureDetector(
                key: const Key('account-actions'),
                onTap: onAvatarPressed,
                behavior: HitTestBehavior.opaque,
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
            ),
          ],
        ),
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
