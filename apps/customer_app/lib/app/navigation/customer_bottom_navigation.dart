import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/design_system/foundations/app_colors.dart';
import '../../core/design_system/foundations/app_radii.dart';
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
    final double heightGrowth = math.max(
      0,
      MediaQuery.textScalerOf(context).scale(12) - 12,
    );
    final double itemHeight = 57 + heightGrowth;

    return SizedBox(
      height: 84 + heightGrowth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          border: Border(top: BorderSide(color: palette.border)),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double rowWidth = math.min(
              358,
              math.max(0, constraints.maxWidth - 30),
            );
            final double itemWidth = (rowWidth - 6) / 4;

            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: rowWidth,
                  height: itemHeight,
                  child: Row(
                    children: List<Widget>.generate(
                      customerDestinations.length * 2 - 1,
                      (int slot) {
                        if (slot.isOdd) {
                          return const SizedBox(width: 2);
                        }
                        final int index = slot ~/ 2;
                        final CustomerDestination destination =
                            customerDestinations[index];
                        final bool selected = index == currentIndex;
                        final Color foreground = selected
                            ? palette.selectedForeground
                            : palette.cardTextSecondary;

                        return SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: Semantics(
                            button: true,
                            selected: selected,
                            label: destination.label,
                            onTap: () => onDestinationSelected(index),
                            excludeSemantics: true,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: selected
                                    ? palette.iconTile
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.navigationItem,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.navigationItem,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  key: destination.semanticKey,
                                  onTap: () => onDestinationSelected(index),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      bottom: 4,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        AnimatedScale(
                                          scale: selected ? 1.08 : 1.0,
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOutBack,
                                          child: Icon(
                                            destination.icon,
                                            color: foreground,
                                            size: 21,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).copyWith(
                                            color: foreground,
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                          child: Text(
                                            destination.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
