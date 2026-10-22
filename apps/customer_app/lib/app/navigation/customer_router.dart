import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../features/ui_foundation/presentation/foundation_pages.dart';
import '../theme/theme_mode_controller.dart';
import 'customer_shell.dart';

abstract final class CustomerRoutes {
  static const String home = 'home';
  static const String menu = 'menu';
  static const String orders = 'orders';
  static const String account = 'account';
}

GoRouter createCustomerRouter({
  required ThemeModeController themeModeController,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return CustomerShell(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                name: CustomerRoutes.home,
                builder: (BuildContext context, GoRouterState state) {
                  return FoundationHomePage(
                    themeModeController: themeModeController,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/menu',
                name: CustomerRoutes.menu,
                builder: (BuildContext context, GoRouterState state) {
                  return FoundationMenuPage(
                    themeModeController: themeModeController,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/pedidos',
                name: CustomerRoutes.orders,
                builder: (BuildContext context, GoRouterState state) {
                  return FoundationOrdersPage(
                    themeModeController: themeModeController,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/cuenta',
                name: CustomerRoutes.account,
                builder: (BuildContext context, GoRouterState state) {
                  return FoundationAccountPage(
                    themeModeController: themeModeController,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            child: ChifaStateView(
              kind: ChifaStateKind.error,
              title: 'Ruta no disponible',
              message: 'No encontramos la pantalla solicitada.',
              actionLabel: 'Volver al inicio',
              onAction: () => context.go('/'),
            ),
          ),
        ),
      );
    },
  );
}
