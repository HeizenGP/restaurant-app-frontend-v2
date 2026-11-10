import 'package:flutter/material.dart';

import '../foundations/asia_colors.dart';
import '../foundations/asia_radii.dart';
import '../foundations/asia_spacing.dart';
import '../foundations/asia_typography.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.isPositiveTrend = true,
    this.icon,
    this.accentColor,
    this.onTap,
    super.key,
  });

  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final bool isPositiveTrend;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final Color accent = accentColor ?? tokens.brandCrimson;

    final Widget card = Container(
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: AsiaRadii.lg,
        border: Border.all(color: tokens.border, width: 1.0),
      ),
      padding: const EdgeInsets.all(AsiaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textTertiary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AsiaRadii.md,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18, color: accent),
                ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.md),
          Text(
            value,
            style: AsiaTypography.metricLarge.copyWith(
              color: tokens.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AsiaSpacing.sm),
          Row(
            children: <Widget>[
              if (trend != null) ...<Widget>[
                Icon(
                  isPositiveTrend
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 15,
                  color: isPositiveTrend ? tokens.success : tokens.error,
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: AsiaTypography.caption.copyWith(
                    color: isPositiveTrend ? tokens.success : tokens.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle!,
                    style: AsiaTypography.caption.copyWith(
                      color: tokens.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: card),
      );
    }

    return card;
  }
}
