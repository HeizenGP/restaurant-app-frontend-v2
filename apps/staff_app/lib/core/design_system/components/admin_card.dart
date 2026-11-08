import 'package:flutter/material.dart';
import '../foundations/asia_colors.dart';
import '../foundations/asia_radii.dart';
import '../foundations/asia_spacing.dart';
import '../foundations/asia_typography.dart';

class AdminCard extends StatelessWidget {
  const AdminCard({
    required this.child,
    this.title,
    this.subtitle,
    this.action,
    this.padding = const EdgeInsets.all(AsiaSpacing.lg),
    this.isElevated = false,
    super.key,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final bool isElevated;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: isElevated ? tokens.cardElevated : tokens.card,
        borderRadius: AsiaRadii.lg,
        border: Border.all(
          color: tokens.border,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null || action != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AsiaSpacing.lg,
                AsiaSpacing.md,
                AsiaSpacing.lg,
                AsiaSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (title != null)
                          Text(
                            title!,
                            style: AsiaTypography.headingMedium.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AsiaTypography.caption.copyWith(
                              color: tokens.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
            Divider(color: tokens.borderSubtle, height: 1),
          ],
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
