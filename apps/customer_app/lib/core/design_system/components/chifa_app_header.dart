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
    final Color utilityIconColor = isDarkMode
        ? palette.accentGold
        : palette.brandRed;

    return SizedBox(
      height: 51,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double avatarLeft = constraints.maxWidth - 55;
          final double themeLeft = avatarLeft - 51;
          final double notificationLeft = themeLeft - 47;

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: 4,
                top: 6,
                width: notificationLeft - 37,
                height: 27,
                child: Text(
                  'CHIFA ASIA',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Positioned(
                left: 5,
                top: 34,
                width: notificationLeft - 38,
                height: 12,
                child: Text(
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
              ),
              Positioned(
                left: notificationLeft,
                top: 5,
                child: Semantics(
                  label: 'Notificaciones no disponibles',
                  excludeSemantics: true,
                  child: _HeaderTile(
                    icon: LucideIcons.bell,
                    color: utilityIconColor,
                  ),
                ),
              ),
              Positioned(
                left: themeLeft,
                top: 5,
                child: Semantics(
                  button: true,
                  label: isDarkMode
                      ? 'Activar tema claro'
                      : 'Activar tema oscuro',
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
              ),
              Positioned(
                left: avatarLeft,
                top: 5,
                child: Semantics(
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
              ),
            ],
          );
        },
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
