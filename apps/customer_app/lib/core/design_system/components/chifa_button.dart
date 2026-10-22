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
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final ChifaButtonVariant variant;
  final bool isLoading;
  final IconData? leading;
  final IconData? trailing;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (leading != null)
          Icon(leading, size: 19),
        if (isLoading || leading != null) const SizedBox(width: 10),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        if (!isLoading && trailing != null) const SizedBox(width: 10),
        if (!isLoading && trailing != null) Icon(trailing, size: 19),
      ],
    );

    final Widget button = switch (variant) {
      ChifaButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      ChifaButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };

    final Widget sizedButton = SizedBox(
      width: fullWidth ? double.infinity : null,
      height: variant == ChifaButtonVariant.primary ? 54 : 49,
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
