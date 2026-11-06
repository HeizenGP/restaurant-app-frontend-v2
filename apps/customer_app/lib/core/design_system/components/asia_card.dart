import 'package:flutter/material.dart';

import '../foundations/asia_radii.dart';
import '../theme/asia_theme.dart';
import 'asia_pressable.dart';

class AsiaCard extends StatelessWidget {
  const AsiaCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.hasShadow = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final BorderRadius radius = borderRadius ?? AsiaRadii.brCard;
    final Color bg = backgroundColor ?? theme.surface;
    final Color borderC = borderColor ?? theme.border;

    final Widget cardContainer = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: borderC, width: 0.8),
        boxShadow: hasShadow && !theme.isDark
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return AsiaPressable(
        onPressed: onTap,
        borderRadius: radius,
        child: cardContainer,
      );
    }

    return cardContainer;
  }
}

