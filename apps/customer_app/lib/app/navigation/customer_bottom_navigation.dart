import 'package:flutter/material.dart';

import '../../core/design_system/foundations/app_colors.dart';
import '../../core/design_system/foundations/app_radii.dart';
import '../../core/design_system/foundations/app_spacing.dart';
import 'customer_destination.dart';

class CustomerBottomNavigation extends StatelessWidget {
  const CustomerBottomNavigation({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
        child: Row(
          children: List<Widget>.generate(customerDestinations.length, (
            int index,
          ) {
            final CustomerDestination destination = customerDestinations[index];
            final bool selected = index == currentIndex;
            final Color foreground = selected
                ? palette.selectedForeground
                : palette.textSecondary;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: destination.label,
                  onTap: () => onDestinationSelected(index),
                  excludeSemantics: true,
                  child: Material(
                    color: selected ? palette.iconTile : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppRadii.navigationItem,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: destination.semanticKey,
                      onTap: () => onDestinationSelected(index),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 57),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                destination.icon,
                                color: foreground,
                                size: 21,
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                destination.label,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: foreground,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
