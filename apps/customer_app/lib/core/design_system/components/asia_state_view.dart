import 'package:flutter/material.dart';

import '../foundations/asia_radii.dart';
import '../foundations/asia_typography.dart';
import '../theme/asia_theme.dart';
import 'asia_button.dart';

enum AsiaStateKind { loading, empty, error }

class AsiaStateView extends StatelessWidget {
  const AsiaStateView({
    required this.kind,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
    super.key,
  });

  final AsiaStateKind kind;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    final Widget leadingWidget;
    switch (kind) {
      case AsiaStateKind.loading:
        leadingWidget = SizedBox.square(
          dimension: 36,
          child: CircularProgressIndicator(
            strokeWidth: 2.8,
            valueColor: AlwaysStoppedAnimation<Color>(theme.brandCrimson),
          ),
        );
      case AsiaStateKind.empty:
        leadingWidget = Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.surfaceSubtle,
            shape: BoxShape.circle,
            border: Border.all(color: theme.border, width: 0.8),
          ),
          child: Icon(
            icon ?? Icons.inbox_outlined,
            size: 30,
            color: theme.textSecondary,
          ),
        );
      case AsiaStateKind.error:
        leadingWidget = Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.error.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Icon(
            icon ?? Icons.error_outline_rounded,
            size: 30,
            color: theme.error,
          ),
        );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            leadingWidget,
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AsiaTypography.titleMedium.copyWith(
                color: theme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AsiaTypography.bodyMedium.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              AsiaButton(
                label: actionLabel!,
                onPressed: onAction!,
                variant: kind == AsiaStateKind.error
                    ? AsiaButtonVariant.secondary
                    : AsiaButtonVariant.primary,
                height: 44,
                width: 180,
                borderRadius: AsiaRadii.brPill,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

