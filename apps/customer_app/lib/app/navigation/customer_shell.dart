import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/foundations/app_colors.dart';
import 'customer_bottom_navigation.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: ColoredBox(
        color: context.appPalette.background,
        child: SafeArea(
          top: false,
          child: CustomerBottomNavigation(
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}
