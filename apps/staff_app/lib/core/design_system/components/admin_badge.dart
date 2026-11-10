import 'package:flutter/material.dart';

import '../foundations/asia_colors.dart';
import '../foundations/asia_radii.dart';
import '../foundations/asia_typography.dart';

enum AdminBadgeVariant { success, warning, error, info, neutral, brand }

class AdminBadge extends StatelessWidget {
  const AdminBadge({
    required this.label,
    this.variant = AdminBadgeVariant.neutral,
    this.icon,
    this.isPill = true,
    super.key,
  });

  final String label;
  final AdminBadgeVariant variant;
  final IconData? icon;
  final bool isPill;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case AdminBadgeVariant.success:
        bg = tokens.success.withValues(alpha: 0.12);
        fg = tokens.success;
        border = tokens.success.withValues(alpha: 0.3);
        break;
      case AdminBadgeVariant.warning:
        bg = tokens.warning.withValues(alpha: 0.12);
        fg = tokens.warning;
        border = tokens.warning.withValues(alpha: 0.3);
        break;
      case AdminBadgeVariant.error:
        bg = tokens.error.withValues(alpha: 0.12);
        fg = tokens.error;
        border = tokens.error.withValues(alpha: 0.3);
        break;
      case AdminBadgeVariant.info:
        bg = tokens.info.withValues(alpha: 0.12);
        fg = tokens.info;
        border = tokens.info.withValues(alpha: 0.3);
        break;
      case AdminBadgeVariant.neutral:
        bg = tokens.cardElevated;
        fg = tokens.textSecondary;
        border = tokens.border;
        break;
      case AdminBadgeVariant.brand:
        bg = tokens.brandCrimson.withValues(alpha: 0.12);
        fg = tokens.brandCrimson;
        border = tokens.brandCrimson.withValues(alpha: 0.3);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: isPill ? AsiaRadii.pill : AsiaRadii.sm,
        border: Border.all(color: border, width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 11, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AsiaTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
