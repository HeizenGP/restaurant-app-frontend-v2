import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/layout/admin_shell.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/dashboard/application/dashboard_controller.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/inventory/application/inventory_controller.dart';
import '../../features/inventory/presentation/inventory_page.dart';
import '../../features/orders/application/order_controller.dart';
import '../../features/orders/presentation/orders_page.dart';
import '../../features/payments/application/payment_controller.dart';
import '../../features/payments/presentation/payments_page.dart';
import '../../features/products/application/catalog_controller.dart';
import '../../features/products/presentation/products_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/staff/application/staff_controller.dart';
import '../../features/staff/presentation/staff_page.dart';
import '../../features/tables/application/table_controller.dart';
import '../../features/tables/presentation/tables_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

GoRouter createAppRouter({
  required AuthController authController,
  required DashboardController dashboardController,
  required CatalogController catalogController,
  required OrderController orderController,
  required InventoryController inventoryController,
  required TableController tableController,
  required StaffController staffController,
  required PaymentController paymentController,
  required bool Function() isDarkMode,
  required VoidCallback onToggleTheme,
}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: authController,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuth = authController.isAuthenticated;
      final bool isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth && !isLoggingIn) {
        return '/login';
      }

      if (isAuth && isLoggingIn) {
        return '/dashboard';
      }

      // Check role permissions for admin-only routes
      if (isAuth && (state.matchedLocation == '/staff' || state.matchedLocation == '/reports')) {
        if (!authController.isAdmin) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return LoginPage(
            authController: authController,
            onToggleTheme: onToggleTheme,
          );
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AdminShell(
            authController: authController,
            isDarkMode: isDarkMode(),
            onToggleTheme: onToggleTheme,
            child: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/dashboard',
            builder: (BuildContext context, GoRouterState state) {
              return DashboardPage(
                dashboardController: dashboardController,
                authController: authController,
              );
            },
          ),
          GoRoute(
            path: '/orders',
            builder: (BuildContext context, GoRouterState state) {
              return OrdersPage(
                orderController: orderController,
              );
            },
          ),
          GoRoute(
            path: '/products',
            builder: (BuildContext context, GoRouterState state) {
              return ProductsPage(
                catalogController: catalogController,
              );
            },
          ),
          GoRoute(
            path: '/inventory',
            builder: (BuildContext context, GoRouterState state) {
              return InventoryPage(
                inventoryController: inventoryController,
              );
            },
          ),
          GoRoute(
            path: '/tables',
            builder: (BuildContext context, GoRouterState state) {
              return TablesPage(
                tableController: tableController,
              );
            },
          ),
          GoRoute(
            path: '/payments',
            builder: (BuildContext context, GoRouterState state) {
              return PaymentsPage(
                paymentController: paymentController,
              );
            },
          ),
          GoRoute(
            path: '/staff',
            builder: (BuildContext context, GoRouterState state) {
              return StaffPage(
                staffController: staffController,
              );
            },
          ),
          GoRoute(
            path: '/reports',
            builder: (BuildContext context, GoRouterState state) {
              return ReportsPage(
                dashboardController: dashboardController,
              );
            },
          ),
        ],
      ),
    ],
  );
}
