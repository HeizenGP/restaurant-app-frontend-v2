import 'dart:io';

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
    this.avatarPath,
    this.onAvatarPressed,
    this.onBackPressed,
    this.showBackButton,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.onNotificationPressed,
    this.tableLabel,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final VoidCallback? onNotificationPressed;
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
        padding: const EdgeInsets.only(right: 6),
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
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const KairoBrandSeal(size: 34),
                    if (tableLabel != null && tableLabel!.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
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
                              Flexible(
                                child: Text(
                                  tableLabel!.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode
                                        ? palette.accentGold
                                        : palette.brandRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Cart button (LucideIcons.shoppingCart)
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
                    onTap: onCartPressed ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                cartItemCount > 0
                                    ? 'Tienes $cartItemCount productos en tu carrito.'
                                    : 'Tu carrito está vacío.',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: palette.brandSurface,
                            ),
                          );
                        },
                    borderRadius: BorderRadius.circular(AppRadii.control),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        _HeaderTile(
                          icon: LucideIcons.shoppingCart,
                          color: utilityIconColor,
                        ),
                        if (cartItemCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
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
            const SizedBox(width: 5),
            // Notifications button (LucideIcons.bell) - distinct from cart
            Semantics(
              button: true,
              label: 'Notificaciones',
              onTap: onNotificationPressed,
              excludeSemantics: true,
              child: Tooltip(
                message: 'Notificaciones',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('header-notifications-button'),
                    onTap: onNotificationPressed ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Notificaciones de pedidos activas. No tienes avisos pendientes.',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: palette.brandSurface,
                            ),
                          );
                        },
                    borderRadius: BorderRadius.circular(AppRadii.control),
                    child: _HeaderTile(
                      icon: LucideIcons.bell,
                      color: utilityIconColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            // Theme toggle
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
            const SizedBox(width: 6),
            // Avatar profile button (Top Right in all screens)
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
                child: _HeaderAvatar(
                  initials: initials,
                  avatarPath: avatarPath,
                  palette: palette,
                  isDarkMode: isDarkMode,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({
    required this.initials,
    required this.palette,
    required this.isDarkMode,
    this.avatarPath,
  });

  final String initials;
  final String? avatarPath;
  final AppPalette palette;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final String? path = avatarPath?.trim();
    if (path != null && path.isNotEmpty) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDarkMode ? palette.accentGold : palette.brandRed,
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: path.startsWith('http')
              ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _buildFallback(),
                )
              : (path.startsWith('/') || path.startsWith('file:'))
                  ? Image.file(
                      File(path.replaceFirst('file://', '')),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildFallback(),
                    )
                  : Image.asset(
                      path,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildFallback(),
                    ),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return CircleAvatar(
      radius: 19,
      backgroundColor: palette.brandSurface,
      foregroundColor: palette.onBrand,
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w700,
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
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: context.appPalette.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 19),
    );
  }
}

/// The KAIRO seal (凱). Elegant corporate red squircle with subtle gold border.
class KairoBrandSeal extends StatelessWidget {
  const KairoBrandSeal({this.size = 38, super.key});

  final double size;

  static const Color _kGoldLight = Color(0xFFFBE4C2);

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return SizedBox.square(
      dimension: size,
      child: FittedBox(
        child: SizedBox.square(
          dimension: 60,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.brandRed,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.accentGold, width: 1.5),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.brandRed.withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: palette.accentGold.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                ),
                const Text(
                  '凱',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: _kGoldLight,
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

