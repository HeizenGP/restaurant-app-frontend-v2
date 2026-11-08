import 'package:flutter/material.dart';
import '../foundations/asia_colors.dart';
import '../foundations/asia_radii.dart';
import '../foundations/asia_spacing.dart';
import '../foundations/asia_typography.dart';

enum AdminButtonVariant {
  primary,
  secondary,
  ghost,
  danger,
  gold,
}

enum AdminButtonSize {
  sm,
  md,
  lg,
}

class AdminButton extends StatefulWidget {
  const AdminButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AdminButtonVariant.primary,
    this.size = AdminButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AdminButtonVariant variant;
  final AdminButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  @override
  State<AdminButton> createState() => _AdminButtonState();
}

class _AdminButtonState extends State<AdminButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool disabled = widget.onPressed == null || widget.isLoading;

    Color bg;
    Color fg;
    Border? border;

    switch (widget.variant) {
      case AdminButtonVariant.primary:
        bg = _isHovered ? tokens.brandCrimson.withValues(alpha: 0.9) : tokens.brandCrimson;
        fg = Colors.white;
        border = null;
        break;
      case AdminButtonVariant.secondary:
        bg = _isHovered ? tokens.cardElevated : tokens.card;
        fg = tokens.textPrimary;
        border = Border.all(color: _isHovered ? tokens.brandCrimson.withValues(alpha: 0.5) : tokens.border);
        break;
      case AdminButtonVariant.ghost:
        bg = _isHovered ? tokens.cardElevated : Colors.transparent;
        fg = tokens.textSecondary;
        border = null;
        break;
      case AdminButtonVariant.danger:
        bg = _isHovered ? tokens.error.withValues(alpha: 0.85) : tokens.error;
        fg = Colors.white;
        border = null;
        break;
      case AdminButtonVariant.gold:
        bg = _isHovered ? tokens.brandGold.withValues(alpha: 0.9) : tokens.brandGold;
        fg = Colors.black;
        border = null;
        break;
    }

    if (disabled) {
      bg = bg.withValues(alpha: 0.4);
      fg = fg.withValues(alpha: 0.5);
      border = border != null ? Border.all(color: tokens.border.withValues(alpha: 0.3)) : null;
    }

    EdgeInsets padding;
    double fontSize;
    double iconSize;

    switch (widget.size) {
      case AdminButtonSize.sm:
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
        fontSize = 12;
        iconSize = 14;
        break;
      case AdminButtonSize.md:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
        fontSize = 13.5;
        iconSize = 16;
        break;
      case AdminButtonSize.lg:
        padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14);
        fontSize = 15;
        iconSize = 18;
        break;
    }

    Widget content;
    if (widget.isLoading) {
      content = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (widget.icon != null) ...<Widget>[
            Icon(widget.icon, size: iconSize, color: fg),
            const SizedBox(width: AsiaSpacing.sm),
          ],
          Text(
            widget.label,
            style: AsiaTypography.headingMedium.copyWith(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final Widget buttonWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AsiaRadii.md,
        border: border,
        boxShadow: _isHovered && !disabled && widget.variant == AdminButtonVariant.primary
            ? <BoxShadow>[
                BoxShadow(
                  color: tokens.brandCrimson.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: padding,
      alignment: widget.isFullWidth ? Alignment.center : null,
      child: content,
    );

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: disabled ? null : widget.onPressed,
        child: widget.isFullWidth ? SizedBox(width: double.infinity, child: buttonWidget) : buttonWidget,
      ),
    );
  }
}
