import 'package:flutter/material.dart';

enum ChifaButtonVariant { primary, secondary }

class ChifaButton extends StatefulWidget {
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
  State<ChifaButton> createState() => _ChifaButtonState();
}

class _ChifaButtonState extends State<ChifaButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = widget.isLoading ? null : widget.onPressed;
    final Widget child = widget.trailingAtEdge && widget.trailing != null && !widget.isLoading
        ? Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(right: 0, child: Icon(widget.trailing, size: widget.iconSize)),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (widget.isLoading)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (widget.leading != null)
                Icon(widget.leading, size: widget.iconSize),
              if (widget.isLoading || widget.leading != null) const SizedBox(width: 10),
              Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis)),
              if (!widget.isLoading && widget.trailing != null) const SizedBox(width: 10),
              if (!widget.isLoading && widget.trailing != null)
                Icon(widget.trailing, size: widget.iconSize),
            ],
          );

    final ButtonStyle? localStyle = widget.borderRadius == null && widget.textStyle == null
        ? null
        : ButtonStyle(
            shape: widget.borderRadius == null
                ? null
                : WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(widget.borderRadius!),
                    ),
                  ),
            textStyle: widget.textStyle == null
                ? null
                : WidgetStatePropertyAll<TextStyle>(widget.textStyle!),
          );

    final Widget button = switch (widget.variant) {
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

    final Widget animatedButton = AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: Listener(
        onPointerDown: (_) {
          if (effectiveOnPressed != null) setState(() => _isPressed = true);
        },
        onPointerUp: (_) {
          if (_isPressed) setState(() => _isPressed = false);
        },
        onPointerCancel: (_) {
          if (_isPressed) setState(() => _isPressed = false);
        },
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          height: widget.height ?? (widget.variant == ChifaButtonVariant.primary ? 54 : 49),
          child: button,
        ),
      ),
    );

    if (!widget.isLoading) {
      return animatedButton;
    }

    return Semantics(
      button: true,
      enabled: false,
      liveRegion: true,
      label: '${widget.label}, cargando',
      excludeSemantics: true,
      child: animatedButton,
    );
  }
}
