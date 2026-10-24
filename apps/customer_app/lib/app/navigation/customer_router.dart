import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/m01_access/continue_as_guest/presentation/guest_access_page.dart';
import '../../features/m01_access/register_account/presentation/registration_page.dart';
import '../../features/m01_access/shared/application/auth_session_controller.dart';
import '../../features/m01_access/sign_in/presentation/sign_in_page.dart';
import '../../features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import '../../features/m02_catalog/browse_catalog/presentation/catalog_pages.dart';
import '../../features/m02_catalog/shared/domain/catalog_models.dart';
import '../../features/m02_catalog/view_product/application/product_detail_controller.dart';
import '../../features/m02_catalog/view_product/presentation/product_detail_page.dart';
import '../../features/m04_orders/manage_cart/application/cart_controller.dart';
import '../../features/m04_orders/manage_cart/domain/cart_models.dart';
import '../../features/m04_orders/manage_cart/presentation/cart_page.dart';
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
  static const String cart = 'cart';
}

GoRouter createCustomerRouter({
  required ThemeModeController themeModeController,
  required AuthSessionController authController,
  required CatalogController catalogController,
  required CartController cartController,
}) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authController.navigationRefresh,
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
      GoRoute(
        path: '/acceso',
        name: CustomerRoutes.access,
        builder: (BuildContext context, GoRouterState state) {
          return SignInPage(authController: authController);
        },
      ),
      GoRoute(
        path: '/registro',
        name: CustomerRoutes.registration,
        builder: (BuildContext context, GoRouterState state) {
          return RegistrationPage(authController: authController);
        },
      ),
      GoRoute(
        path: '/invitado',
        name: CustomerRoutes.guest,
        builder: (BuildContext context, GoRouterState state) {
          return GuestAccessPage(authController: authController);
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
                    themeModeController: themeModeController,
                    catalogController: catalogController,
                    onOpenMenu: () => context.go('/menu'),
                    onCategorySelected: (String categoryId) {
                      unawaited(catalogController.selectCategory(categoryId));
                      context.go('/menu');
                    },
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
                  return CatalogBrowsePage(
                    themeModeController: themeModeController,
                    catalogController: catalogController,
                    onOpenProduct: (CatalogProduct product) {
                      context.pushNamed(
                        CustomerRoutes.productDetail,
                        pathParameters: <String, String>{
                          'categoryId': product.categoryId,
                          'productId': product.id,
                        },
                        extra: product,
                      );
                    },
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'carrito',
                    name: CustomerRoutes.cart,
                    builder: (BuildContext context, GoRouterState state) {
                      return CartPage(
                        themeModeController: themeModeController,
                        cartController: cartController,
                      );
                    },
                  ),
                ],
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
                  final session = authController.state.session;
                  final user = session?.user;
                  return FoundationAccountPage(
                    themeModeController: themeModeController,
                    isGuest: session?.isGuest ?? true,
                    displayName: user?.displayName,
                    email: user?.email,
                    onOpenOrders: () => context.go('/pedidos'),
                    onLogout: authController.logout,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/menu/categoria/:categoryId/producto/:productId',
        name: CustomerRoutes.productDetail,
        builder: (BuildContext context, GoRouterState state) {
          final String categoryId = state.pathParameters['categoryId'] ?? '';
          final String productId = state.pathParameters['productId'] ?? '';
          final CatalogProduct? selectedProduct = state.extra is CatalogProduct
              ? state.extra! as CatalogProduct
              : null;
          return CatalogProductDetailPage(
            themeModeController: themeModeController,
            controller: ProductDetailController.fromSelection(
              categoryId: categoryId,
              productId: productId,
              selectedProduct: selectedProduct,
            ),
            onAddProduct: (CatalogProduct product, int quantity) {
              if (!product.availableForSale) return false;
              return cartController.addProduct(
                CartProductSnapshot(
                  id: product.id,
                  categoryId: product.categoryId,
                  name: product.name,
                  unitPriceCents: product.priceCents,
                ),
                quantity: quantity,
              );
            },
            onOpenCart: () => context.goNamed(CustomerRoutes.cart),
          );
        },
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
