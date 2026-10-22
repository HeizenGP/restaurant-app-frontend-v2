import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_radii.dart';

class ChifaIconTile extends StatelessWidget {
  const ChifaIconTile({
    required this.icon,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final Color iconColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? palette.accentGold
            : palette.brandRed);

    final Widget tile = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: palette.iconTile,
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 21),
    );

    if (semanticLabel == null) {
      return ExcludeSemantics(child: tile);
    }
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: tile,
    );
  }
}
