import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../foundations/asia_radii.dart';
import '../foundations/asia_typography.dart';
import '../theme/asia_theme.dart';
import 'asia_pressable.dart';

class AsiaBottomNavItem {
  const AsiaBottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount = 0,
    this.semanticKey,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int badgeCount;
  final Key? semanticKey;
}

class AsiaBottomNav extends StatelessWidget {
  const AsiaBottomNav({
    required this.currentIndex,
    required this.onTap,
    this.items,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AsiaBottomNavItem>? items;

  static const List<AsiaBottomNavItem> defaultItems = <AsiaBottomNavItem>[
    AsiaBottomNavItem(
      label: 'Inicio',
      icon: LucideIcons.house,
      activeIcon: LucideIcons.house,
      semanticKey: Key('nav-inicio'),
    ),
    AsiaBottomNavItem(
      label: 'Menú',
      icon: LucideIcons.utensilsCrossed,
      activeIcon: LucideIcons.utensilsCrossed,
      semanticKey: Key('nav-menu'),
    ),
    AsiaBottomNavItem(
      label: 'Pedidos',
      icon: LucideIcons.receiptText,
      activeIcon: LucideIcons.receiptText,
      semanticKey: Key('nav-pedidos'),
    ),
    AsiaBottomNavItem(
      label: 'Cuenta',
      icon: LucideIcons.userRound,
      activeIcon: LucideIcons.userRound,
      semanticKey: Key('nav-cuenta'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final List<AsiaBottomNavItem> navItems = items ?? defaultItems;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.border, width: 0.8)),
        boxShadow: !theme.isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List<Widget>.generate(navItems.length, (int index) {
            final AsiaBottomNavItem item = navItems[index];
            final bool isSelected = currentIndex == index;

            final Color activeColor = theme.brandCrimson;
            final Color inactiveColor = theme.textTertiary;

            return Expanded(
              child: AsiaPressable(
                onPressed: () => onTap(index),
                borderRadius: AsiaRadii.brMd,
                semanticLabel: item.label,
                child: Container(
                  key: item.semanticKey,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.brandCrimson.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: AsiaRadii.brPill,
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 21,
                              color: isSelected ? activeColor : inactiveColor,
                            ),
                          ),
                          if (item.badgeCount > 0)
                            Positioned(
                              right: 4,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.brandCrimson,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.badgeCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        maxLines: 1,
                        style: AsiaTypography.labelSmall.copyWith(
                          color: isSelected ? activeColor : inactiveColor,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

