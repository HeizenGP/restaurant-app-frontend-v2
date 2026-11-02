import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_radii.dart';

class ChifaChip extends StatelessWidget {
  const ChifaChip({
    required this.label,
    required this.width,
    this.isSelected = false,
    this.onPressed,
    super.key,
  });

  final String label;
  final double width;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: 35,
      decoration: BoxDecoration(
        color: isSelected
            ? palette.brandRed.withValues(alpha: 0.15)
            : palette.surfaceTint,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(
          color: isSelected ? palette.brandRed : palette.border,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? palette.brandRed : palette.textPrimary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );

    return Semantics(
      button: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        clipBehavior: Clip.antiAlias,
        child: onPressed == null
            ? content
            : InkWell(onTap: onPressed, child: content),
      ),
    );
  }
}
