import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_radii.dart';

class ChifaChip extends StatelessWidget {
  const ChifaChip({
    required this.label,
    required this.width,
    this.onPressed,
    super.key,
  });

  final String label;
  final double width;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final Widget content = SizedBox(
      width: width,
      height: 35,
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: palette.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return Semantics(
      button: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: palette.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        clipBehavior: Clip.antiAlias,
        child: onPressed == null
            ? content
            : InkWell(onTap: onPressed, child: content),
      ),
    );
  }
}
