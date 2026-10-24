import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_radii.dart';
import '../foundations/app_spacing.dart';
import 'chifa_icon_tile.dart';

class ChifaCard extends StatelessWidget {
  const ChifaCard({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.semanticLabel,
    this.minimumHeight = 73,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final String? semanticLabel;
  final double minimumHeight;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isButton = onTap != null;
    final bool canTap = isButton && enabled;
    final Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minimumHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              ChifaIconTile(icon: icon!, color: iconColor),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: palette.cardTextPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: palette.cardTextSecondary),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ] else if (isButton) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                LucideIcons.chevronRight,
                color: palette.textSecondary,
                size: 17,
              ),
            ],
          ],
        ),
      ),
    );

    final Widget card = Opacity(
      opacity: enabled ? 1 : 0.62,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: canTap ? InkWell(onTap: onTap, child: content) : content,
      ),
    );

    if (semanticLabel == null && !isButton) {
      return MergeSemantics(child: card);
    }

    return Semantics(
      container: true,
      button: isButton,
      enabled: enabled,
      label: semanticLabel ?? '$title. $subtitle',
      onTap: canTap ? onTap : null,
      excludeSemantics: true,
      child: card,
    );
  }
}
