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
    this.onBackPressed,
    this.showBackButton,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.tableLabel,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final String initials;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final String? tableLabel;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final Color utilityIconColor = isDarkMode
        ? palette.accentGold
        : palette.brandRed;

    final VoidCallback? effectiveBack = onBackPressed ??
        ((ModalRoute.of(context)?.canPop ?? false)
            ? () => Navigator.of(context).pop()
            : null);

    final bool displayBack =
        (showBackButton ?? (ModalRoute.of(context)?.canPop ?? false)) &&
        effectiveBack != null;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 51),
      child: Padding(
        padding: const EdgeInsets.only(right: 13),
        child: Row(
          children: <Widget>[
            if (displayBack) ...<Widget>[
              Semantics(
                button: true,
                label: 'Volver',
                onTap: effectiveBack,
                excludeSemantics: true,
                child: Tooltip(
                  message: 'Volver',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('header-back-button'),
                      onTap: effectiveBack,
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      child: _HeaderTile(
                        icon: LucideIcons.arrowLeft,
                        color: utilityIconColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            'CHIFA ASIA',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        if (tableLabel != null && tableLabel!.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? palette.accentGold.withValues(alpha: 0.15)
                                  : palette.brandRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDarkMode
                                    ? palette.accentGold
                                    : palette.brandRed,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 10,
                                  color: isDarkMode
                                      ? palette.accentGold
                                      : palette.brandRed,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  tableLabel!.trim(),
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode
                                        ? palette.accentGold
                                        : palette.brandRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
            if (onCartPressed != null) ...<Widget>[
              Semantics(
                button: true,
                label: cartItemCount > 0
                    ? 'Ver carrito, $cartItemCount productos'
                    : 'Ver carrito',
                onTap: onCartPressed,
                excludeSemantics: true,
                child: Tooltip(
                  message: 'Ver carrito',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('header-cart-button'),
                      onTap: onCartPressed,
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          _HeaderTile(
                            icon: LucideIcons.shoppingBag,
                            color: utilityIconColor,
                          ),
                          if (cartItemCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: palette.brandRed,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    '$cartItemCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ] else ...<Widget>[
              Semantics(
                label: 'Notificaciones no disponibles',
                excludeSemantics: true,
                child: _HeaderTile(
                  icon: LucideIcons.bell,
                  color: utilityIconColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
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
