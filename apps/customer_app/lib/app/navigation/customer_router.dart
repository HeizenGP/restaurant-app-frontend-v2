import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../features/m01_access/continue_as_guest/presentation/guest_access_page.dart';
import '../../features/m01_access/manage_session/presentation/account_page.dart';
import '../../features/m01_access/register_account/presentation/registration_page.dart';
import '../../features/m01_access/shared/application/auth_session_controller.dart';
import '../../features/m01_access/sign_in/presentation/sign_in_page.dart';
import '../../features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import '../../features/m02_catalog/browse_catalog/presentation/catalog_home_page.dart';
import '../../features/m02_catalog/browse_catalog/presentation/catalog_page.dart';
import '../../features/m02_catalog/shared/application/catalog_contracts.dart';
import '../../features/m02_catalog/view_product/presentation/product_detail_page.dart';
import '../../features/ui_foundation/presentation/foundation_pages.dart';
import '../theme/theme_mode_controller.dart';
import 'customer_shell.dart';

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
      GoRoute(
        path: '/splash',
        name: CustomerRoutes.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const _SessionSplashPage();
        },
      ),
      GoRoute(
        path: '/acceso',
        name: CustomerRoutes.access,
        builder: (BuildContext context, GoRouterState state) {
          return SignInPage(
            authController: authController,
            themeModeController: themeModeController,
          );
        },
      ),
      GoRoute(
        path: '/registro',
        name: CustomerRoutes.registration,
        builder: (BuildContext context, GoRouterState state) {
          return RegistrationPage(
            authController: authController,
            themeModeController: themeModeController,
          );
        },
      ),
      GoRoute(
        path: '/invitado',
        name: CustomerRoutes.guest,
        builder: (BuildContext context, GoRouterState state) {
          return GuestAccessPage(
            authController: authController,
            themeModeController: themeModeController,
          );
        },
      ),
      GoRoute(
        path: '/menu/categoria/:categoryId/producto/:productId',
        name: CustomerRoutes.productDetail,
        builder: (BuildContext context, GoRouterState state) {
          return Scaffold(
            body: ProductDetailPage(
              repository: catalogRepository,
              categoryId: state.pathParameters['categoryId']!,
              productId: state.pathParameters['productId']!,
              themeModeController: themeModeController,
            ),
          );
        },
      ),
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
                  return CatalogHomePage(
                    catalogController: catalogController,
                    themeModeController: themeModeController,
                    onOpenCatalog: () => context.go('/menu'),
                    onCategorySelected: (_) => context.go('/menu'),
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
                  return CatalogPage(
                    catalogController: catalogController,
                    themeModeController: themeModeController,
                    onProductSelected: (category, product) {
                      context.pushNamed(
                        CustomerRoutes.productDetail,
                        pathParameters: <String, String>{
                          'categoryId': category.id,
                          'productId': product.id,
                        },
                      );
                    },
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
                  return AccountPage(
                    authController: authController,
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

class _SessionSplashPage extends StatelessWidget {
  const _SessionSplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('page-splash'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenGutter),
            child: ChifaStateView(
              kind: ChifaStateKind.loading,
              title: 'Preparando Chifa ASIA',
              message: 'Estamos recuperando tu sesión segura.',
            ),
          ),
        ),
      ),
    );
  }
}
