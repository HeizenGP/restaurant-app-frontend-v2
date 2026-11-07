import 'package:flutter/material.dart';

/// House Pressable para KAIRO.
/// Reemplaza el ink ripple por una micro-interacción táctil con escala y hundimiento.
class AsiaPressable extends StatefulWidget {
  const AsiaPressable({
    required this.child,
    this.onPressed,
    this.enabled = true,
    this.semanticLabel,
    this.pressScale = 0.97,
    this.pressSink = 0.5,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final String? semanticLabel;
  final double pressScale;
  final double pressSink;
  final BorderRadius? borderRadius;

  @override
  State<AsiaPressable> createState() => _AsiaPressableState();
}

class _AsiaPressableState extends State<AsiaPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool interactive = widget.enabled && widget.onPressed != null;
    final bool reduce = MediaQuery.disableAnimationsOf(context);
    final Duration duration =
        reduce ? Duration.zero : const Duration(milliseconds: 90);
    final bool isPressed = _pressed && interactive;

    Widget content = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOutCubic,
      transformAlignment: Alignment.center,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, isPressed ? widget.pressSink : 0.0, 0.0, 1.0)
        ..scaleByDouble(
          isPressed ? widget.pressScale : 1.0,
          isPressed ? widget.pressScale : 1.0,
          1.0,
          1.0,
        ),
      child: widget.child,
    );

    if (widget.semanticLabel != null) {
      content = Semantics(
        button: true,
        enabled: interactive,
        label: widget.semanticLabel,
        child: content,
      );
    }

    return FocusableActionDetector(
      enabled: interactive,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: interactive ? (_) => setState(() => _pressed = true) : null,
        onTapUp: interactive ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: interactive ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: content,
      ),
    );
  }
}
