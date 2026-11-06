import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design_system/foundations/app_colors.dart';
import 'customer_destination.dart';

class CustomerBottomNavigation extends StatelessWidget {
  const CustomerBottomNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
    this.avatarPath,
    this.initials,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final String? avatarPath;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color selectedColor = isDark ? palette.accentGold : palette.brandRed;
    final Color unselectedColor =
        isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF8E8E93);

    final double heightGrowth = math.max(
      0,
      MediaQuery.textScalerOf(context).scale(12) - 12,
    );
    final double totalHeight = 68 + heightGrowth;

    return SizedBox(
      height: totalHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? palette.border : const Color(0xFFE5E7EB),
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List<Widget>.generate(
            customerDestinations.length,
            (int index) {
              final CustomerDestination destination = customerDestinations[index];
              final bool selected = index == currentIndex;
              final Color foreground = selected ? selectedColor : unselectedColor;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: destination.label,
                  onTap: () => onDestinationSelected(index),
                  excludeSemantics: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: destination.semanticKey,
                      onTap: () => onDestinationSelected(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AnimatedScale(
                            scale: selected ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            child: (index == 3 &&
                                    avatarPath != null &&
                                    avatarPath!.trim().isNotEmpty)
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selected
                                            ? selectedColor
                                            : unselectedColor.withValues(alpha: 0.6),
                                        width: selected ? 2.0 : 1.2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: avatarPath!.startsWith('http')
                                          ? Image.network(
                                              avatarPath!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => Icon(
                                                destination.icon,
                                                color: foreground,
                                                size: 20,
                                              ),
                                            )
                                          : (avatarPath!.startsWith('/') ||
                                                  avatarPath!.startsWith('file:'))
                                              ? Image.file(
                                                  File(avatarPath!.replaceFirst('file://', '')),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) => Icon(
                                                    destination.icon,
                                                    color: foreground,
                                                    size: 20,
                                                  ),
                                                )
                                              : Image.asset(
                                                  avatarPath!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) => Icon(
                                                    destination.icon,
                                                    color: foreground,
                                                    size: 20,
                                                  ),
                                                ),
                                    ),
                                  )
                                : Icon(
                                    destination.icon,
                                    color: foreground,
                                    size: 22,
                                  ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: foreground,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                            child: Text(
                              destination.label,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
