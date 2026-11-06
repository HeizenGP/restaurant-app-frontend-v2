import 'package:flutter/material.dart';

import '../foundations/asia_radii.dart';
import '../foundations/asia_typography.dart';
import '../theme/asia_theme.dart';
import 'asia_pressable.dart';

class AsiaChip extends StatelessWidget {
  const AsiaChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.badgeText,
    this.semanticKey,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? badgeText;
  final Key? semanticKey;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    final Color bgColor = isSelected ? theme.brandCrimson : theme.surfaceSubtle;
    final Color fgColor = isSelected ? Colors.white : theme.textPrimary;
    final Border? border = isSelected
        ? null
        : Border.all(color: theme.border, width: 0.8);

    final Widget chipContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 16, color: fgColor),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: AsiaTypography.labelMedium.copyWith(
            color: fgColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        if (badgeText != null) ...<Widget>[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withValues(alpha: 0.25) : theme.border,
              borderRadius: AsiaRadii.brPill,
            ),
            child: Text(
              badgeText!,
              style: AsiaTypography.labelSmall.copyWith(
                color: fgColor,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );

    final Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      key: semanticKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AsiaRadii.brPill,
        border: border,
        boxShadow: isSelected && !theme.isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: theme.brandCrimson.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: chipContent,
    );

    if (onTap != null) {
      return AsiaPressable(
        onPressed: onTap,
        borderRadius: AsiaRadii.brPill,
        child: container,
      );
    }

    return container;
  }
}

