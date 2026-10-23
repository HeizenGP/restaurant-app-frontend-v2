import 'package:flutter/material.dart';

enum ChifaButtonVariant { primary, secondary }

class ChifaButton extends StatelessWidget {
  const ChifaButton({
    required this.label,
    required this.onPressed,
    this.variant = ChifaButtonVariant.primary,
    this.isLoading = false,
    this.leading,
    this.trailing,
    this.fullWidth = true,
    this.height,
    this.borderRadius,
    this.textStyle,
    this.iconSize = 19,
    this.trailingAtEdge = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final ChifaButtonVariant variant;
  final bool isLoading;
  final IconData? leading;
  final IconData? trailing;
  final bool fullWidth;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;
  final double iconSize;
  final bool trailingAtEdge;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;
    final Widget child = trailingAtEdge && trailing != null && !isLoading
        ? Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(right: 0, child: Icon(trailing, size: iconSize)),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isLoading)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (leading != null)
                Icon(leading, size: iconSize),
              if (isLoading || leading != null) const SizedBox(width: 10),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              if (!isLoading && trailing != null) const SizedBox(width: 10),
              if (!isLoading && trailing != null)
                Icon(trailing, size: iconSize),
            ],
          );

    final ButtonStyle? localStyle = borderRadius == null && textStyle == null
        ? null
        : ButtonStyle(
            shape: borderRadius == null
                ? null
                : WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius!),
                    ),
                  ),
            textStyle: textStyle == null
                ? null
                : WidgetStatePropertyAll<TextStyle>(textStyle!),
          );

    final Widget button = switch (variant) {
      ChifaButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        style: localStyle,
        child: child,
      ),
      ChifaButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: localStyle,
        child: child,
      ),
    };

    final Widget sizedButton = SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? (variant == ChifaButtonVariant.primary ? 54 : 49),
      child: button,
    );

    if (!isLoading) {
      return sizedButton;
    }

    return Semantics(
      button: true,
      enabled: false,
      liveRegion: true,
      label: '$label, cargando',
      excludeSemantics: true,
      child: sizedButton,
    );
  }
}
