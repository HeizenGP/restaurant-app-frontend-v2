import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/m01_access/shared/application/auth_session_controller.dart';
import '../../features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import '../../features/m02_catalog/shared/application/catalog_contracts.dart';
import '../theme/theme_mode_controller.dart';

abstract final class CustomerRoutes {
  static const String home = 'home';
  static const String menu = 'menu';
  static const String orders = 'orders';
  static const String account = 'account';
  static const String access = 'access';
  static const String registration = 'registration';
  static const String guest = 'guest';
  static const String splash = 'splash';
  static const String productDetail = 'product-detail';
}

GoRouter createCustomerRouter({
  required ThemeModeController themeModeController,
  required AuthSessionController authController,
  required CatalogController catalogController,
  required CatalogRepository catalogRepository,
}) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authController,
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus status = authController.state.status;
      final String location = state.matchedLocation;
      final bool isSplash = location == '/splash';
      final bool isAccessRoute =
          location == '/acceso' ||
          location == '/registro' ||
          location == '/invitado';

      if (status == AuthStatus.restoring) {
        return isSplash ? null : '/splash';
      }
      if (status == AuthStatus.signedOut) {
        return isAccessRoute ? null : '/acceso';
      }
      if (isSplash || isAccessRoute) {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      _resetRoute(path: '/splash', name: CustomerRoutes.splash),
      _resetRoute(path: '/acceso', name: CustomerRoutes.access),
      _resetRoute(path: '/registro', name: CustomerRoutes.registration),
      _resetRoute(path: '/invitado', name: CustomerRoutes.guest),
      _resetRoute(path: '/', name: CustomerRoutes.home),
      _resetRoute(path: '/menu', name: CustomerRoutes.menu),
      _resetRoute(path: '/pedidos', name: CustomerRoutes.orders),
      _resetRoute(path: '/cuenta', name: CustomerRoutes.account),
      _resetRoute(
        path: '/menu/categoria/:categoryId/producto/:productId',
        name: CustomerRoutes.productDetail,
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return const _UiResetPlaceholder();
    },
  );
}

GoRoute _resetRoute({required String path, required String name}) {
  return GoRoute(
    path: path,
    name: name,
    builder: (BuildContext context, GoRouterState state) {
      return const _UiResetPlaceholder();
    },
  );
}

class _UiResetPlaceholder extends StatelessWidget {
  const _UiResetPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
