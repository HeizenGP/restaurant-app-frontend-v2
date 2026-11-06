import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../foundations/asia_radii.dart';
import '../foundations/asia_typography.dart';
import '../theme/asia_theme.dart';
import 'asia_pressable.dart';

class AsiaHeader extends StatelessWidget {
  const AsiaHeader({
    this.title,
    this.subtitle,
    this.onBack,
    this.showBack = false,
    this.onToggleTheme,
    this.isDark = false,
    this.onCartTap,
    this.cartCount = 0,
    this.tableNumber,
    this.userInitials,
    this.onUserTap,
    this.trailingAction,
    super.key,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showBack;
  final VoidCallback? onToggleTheme;
  final bool isDark;
  final VoidCallback? onCartTap;
  final int cartCount;
  final String? tableNumber;
  final String? userInitials;
  final VoidCallback? onUserTap;
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AsiaPressable(
                onPressed: onBack,
                borderRadius: AsiaRadii.brPill,
                semanticLabel: 'Volver',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.border, width: 0.8),
                  ),
                  child: Icon(
                    LucideIcons.arrowLeft,
                    size: 19,
                    color: theme.textPrimary,
                  ),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null)
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AsiaTypography.titleMedium.copyWith(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AsiaTypography.bodySmall.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (tableNumber != null && tableNumber!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.brandGold.withValues(alpha: 0.15),
                borderRadius: AsiaRadii.brPill,
                border: Border.all(
                  color: theme.brandGold.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(LucideIcons.utensils, size: 12, color: theme.brandGold),
                  const SizedBox(width: 4),
                  Text(
                    'Mesa $tableNumber',
                    style: AsiaTypography.labelSmall.copyWith(
                      color: theme.brandGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          if (onToggleTheme != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: AsiaPressable(
                onPressed: onToggleTheme,
                borderRadius: AsiaRadii.brPill,
                semanticLabel: 'Cambiar modo oscuro',
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.border, width: 0.8),
                  ),
                  child: Icon(
                    isDark ? LucideIcons.sun : LucideIcons.moon,
                    size: 17,
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ),
          if (onCartTap != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: AsiaPressable(
                onPressed: onCartTap,
                borderRadius: AsiaRadii.brPill,
                semanticLabel: 'Ver carrito ($cartCount artículos)',
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: theme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.border, width: 0.8),
                      ),
                      child: Icon(
                        LucideIcons.shoppingBag,
                        size: 17,
                        color: theme.textPrimary,
                      ),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          decoration: BoxDecoration(
                            color: theme.brandCrimson,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.surface, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (onUserTap != null && userInitials != null)
            AsiaPressable(
              onPressed: onUserTap,
              borderRadius: AsiaRadii.brPill,
              semanticLabel: 'Perfil',
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.brandCrimson,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  userInitials!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ?trailingAction,
        ],
      ),
    );
  }
}
