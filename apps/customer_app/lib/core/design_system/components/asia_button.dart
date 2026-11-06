import 'package:flutter/material.dart';

import '../foundations/asia_radii.dart';
import '../foundations/asia_typography.dart';
import '../theme/asia_theme.dart';
import 'asia_pressable.dart';

enum AsiaButtonVariant { primary, secondary, outline, ghost, danger }

class AsiaButton extends StatelessWidget {
  const AsiaButton({
    required this.label,
    required this.onPressed,
    this.variant = AsiaButtonVariant.primary,
    this.isLoading = false,
    this.enabled = true,
    this.leading,
    this.trailing,
    this.height = 52.0,
    this.width,
    this.borderRadius,
    this.iconSize = 19.0,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AsiaButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final IconData? leading;
  final IconData? trailing;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final BorderRadius radius = borderRadius ?? AsiaRadii.brMd;
    final bool canPress = enabled && !isLoading && onPressed != null;

    final Color bgColor;
    final Color fgColor;
    final Border? border;
    final List<BoxShadow>? shadows;

    switch (variant) {
      case AsiaButtonVariant.primary:
        bgColor = theme.brandCrimson;
        fgColor = Colors.white;
        border = null;
        shadows = canPress && !theme.isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: theme.brandCrimson.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null;
      case AsiaButtonVariant.secondary:
        bgColor = theme.surfaceSubtle;
        fgColor = theme.textPrimary;
        border = Border.all(color: theme.border, width: 0.8);
        shadows = null;
      case AsiaButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = theme.brandCrimson;
        border = Border.all(color: theme.brandCrimson, width: 1.2);
        shadows = null;
      case AsiaButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = theme.textPrimary;
        border = null;
        shadows = null;
      case AsiaButtonVariant.danger:
        bgColor = theme.error;
        fgColor = Colors.white;
        border = null;
        shadows = canPress && !theme.isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: theme.error.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null;
    }

    final Widget buttonContent = Row(
      mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        else ...<Widget>[
          if (leading != null) ...<Widget>[
            Icon(leading, size: iconSize, color: fgColor),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AsiaTypography.labelLarge.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 8),
            Icon(trailing, size: iconSize, color: fgColor),
          ],
        ],
      ],
    );

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: AsiaPressable(
        onPressed: canPress ? onPressed : null,
        enabled: canPress,
        borderRadius: radius,
        semanticLabel: label,
        child: Container(
          height: height,
          width: width ?? double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
            border: border,
            boxShadow: shadows,
          ),
          alignment: Alignment.center,
          child: buttonContent,
        ),
      ),
    );
  }
}

