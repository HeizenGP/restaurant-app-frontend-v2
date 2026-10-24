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
import '../../features/m04_orders/choose_fulfillment/application/fulfillment_controller.dart';
import '../../features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import '../../features/m04_orders/choose_fulfillment/presentation/fulfillment_pages.dart';
import '../../features/m04_orders/manage_cart/application/cart_controller.dart';
import '../../features/m04_orders/manage_cart/domain/cart_models.dart';
import '../../features/m04_orders/manage_cart/presentation/cart_page.dart';
import '../../features/m04_orders/submit_order/application/order_contracts.dart';
import '../../features/m04_orders/submit_order/application/submit_order_controller.dart';
import '../../features/m04_orders/submit_order/domain/order_models.dart';
import '../../features/m04_orders/submit_order/presentation/order_submission_pages.dart';
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
  static const String fulfillmentMode = 'fulfillment-mode';
  static const String tableSelection = 'table-selection';
  static const String pickupDetails = 'pickup-details';
  static const String deliveryDetails = 'delivery-details';
  static const String orderReview = 'order-review';
  static const String orderSubmitted = 'order-submitted';
  static const String orderException = 'order-exception';
}

GoRouter createCustomerRouter({
  required ThemeModeController themeModeController,
  required AuthSessionController authController,
  required CatalogController catalogController,
  required CartController cartController,
  required FulfillmentController fulfillmentController,
  required SubmitOrderController submitOrderController,
}) {
  bool prepareOrderReview(FulfillmentDraft draft) {
    if (cartController.state.isEmpty) return false;
    try {
      return submitOrderController.startNewLogicalRequest(
        CreateOrderCommand(
          items: cartController.state.items.map(
            (CartItem item) => CreateOrderItem(
              productId: item.product.id,
              quantity: item.quantity,
            ),
          ),
          fulfillment: draft,
        ),
      );
    } on ArgumentError {
      return false;
    }
  }

  void finishPreparation(BuildContext context, FulfillmentDraft draft) {
    if (prepareOrderReview(draft)) {
      context.goNamed(CustomerRoutes.orderReview);
    } else {
      context.goNamed(CustomerRoutes.cart);
    }
  }

  void finishSuccessfulSubmission(BuildContext context, OrderSnapshot order) {
    cartController.clear();
    fulfillmentController.clear();
    context.goNamed(
      CustomerRoutes.orderSubmitted,
      pathParameters: <String, String>{'orderId': order.id},
    );
  }

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
                        onContinue: () {
                          context.pushNamed(CustomerRoutes.fulfillmentMode);
                        },
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
        path: '/pedido/modalidad',
        name: CustomerRoutes.fulfillmentMode,
        builder: (BuildContext context, GoRouterState state) {
          return FulfillmentModePage(
            themeModeController: themeModeController,
            controller: fulfillmentController,
            onModeSelected: (FulfillmentMode mode) {
              final String routeName = switch (mode) {
                FulfillmentMode.local => CustomerRoutes.tableSelection,
                FulfillmentMode.pickup => CustomerRoutes.pickupDetails,
                FulfillmentMode.delivery => CustomerRoutes.deliveryDetails,
              };
              context.pushNamed(routeName);
            },
          );
        },
      ),
      GoRoute(
        path: '/pedido/mesa',
        name: CustomerRoutes.tableSelection,
        builder: (BuildContext context, GoRouterState state) {
          return TableSelectionPage(
            themeModeController: themeModeController,
            controller: fulfillmentController,
            onFinished: (FulfillmentDraft draft) {
              finishPreparation(context, draft);
            },
          );
        },
      ),
      GoRoute(
        path: '/pedido/recojo',
        name: CustomerRoutes.pickupDetails,
        builder: (BuildContext context, GoRouterState state) {
          return PickupDetailsPage(
            themeModeController: themeModeController,
            controller: fulfillmentController,
            onFinished: (FulfillmentDraft draft) {
              finishPreparation(context, draft);
            },
          );
        },
      ),
      GoRoute(
        path: '/pedido/delivery',
        name: CustomerRoutes.deliveryDetails,
        builder: (BuildContext context, GoRouterState state) {
          return DeliveryDetailsPage(
            themeModeController: themeModeController,
            controller: fulfillmentController,
            onFinished: (FulfillmentDraft draft) {
              finishPreparation(context, draft);
            },
          );
        },
      ),
      GoRoute(
        path: '/pedido/revision',
        name: CustomerRoutes.orderReview,
        redirect: (BuildContext context, GoRouterState state) {
          return submitOrderController.state.command == null
              ? '/menu/carrito'
              : null;
        },
        builder: (BuildContext context, GoRouterState state) {
          final CartState cart = cartController.state;
          final FulfillmentDraft draft =
              submitOrderController.state.command!.fulfillment;
          return OrderReviewPage(
            themeModeController: themeModeController,
            controller: submitOrderController,
            productsSubtitle: _productSummary(cart),
            attentionSubtitle: _attentionSummary(draft, fulfillmentController),
            amountSubtitle:
                '${_formatSoles(cart.subtotalCents)} estimado por el carrito',
            onSubmitted: (OrderSnapshot order) {
              finishSuccessfulSubmission(context, order);
            },
            onFailure: (OrderFailure failure) {
              context.goNamed(CustomerRoutes.orderException, extra: failure);
            },
          );
        },
      ),
      GoRoute(
        path: '/pedido/solicitud/:orderId',
        name: CustomerRoutes.orderSubmitted,
        builder: (BuildContext context, GoRouterState state) {
          final String orderId = state.pathParameters['orderId'] ?? '';
          return OrderResultPage(
            themeModeController: themeModeController,
            controller: submitOrderController,
            orderId: orderId,
            onViewOrders: () => context.goNamed(CustomerRoutes.orders),
            onBackToHome: () => context.goNamed(CustomerRoutes.home),
          );
        },
      ),
      GoRoute(
        path: '/pedido/excepcion',
        name: CustomerRoutes.orderException,
        builder: (BuildContext context, GoRouterState state) {
          final OrderFailure failure = state.extra is OrderFailure
              ? state.extra! as OrderFailure
              : submitOrderController.state.failure ??
                    const OrderFailure(
                      OrderFailureKind.validation,
                      'Revisa la solicitud antes de continuar.',
                    );
          return OrderExceptionPage(
            themeModeController: themeModeController,
            failure: failure,
            onBackToHome: () => context.goNamed(CustomerRoutes.home),
            onRetry: submitOrderController.state.canRetrySubmission
                ? () async {
                    final bool succeeded = await submitOrderController
                        .retrySubmission();
                    if (!context.mounted) return;
                    final OrderSnapshot? order =
                        submitOrderController.state.order;
                    if (succeeded && order != null) {
                      finishSuccessfulSubmission(context, order);
                    }
                  }
                : null,
          );
        },
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

String _attentionSummary(
  FulfillmentDraft draft,
  FulfillmentController fulfillmentController,
) {
  return switch (draft.mode) {
    FulfillmentMode.local =>
      fulfillmentController.state.selectedTable == null
          ? 'Consumo en local · mesa seleccionada'
          : 'Consumo en local · ${fulfillmentController.state.selectedTable!.code}',
    FulfillmentMode.pickup => 'Recojo · ${draft.contactName}',
    FulfillmentMode.delivery => 'Delivery · ${draft.deliveryAddress}',
  };
}

String _productSummary(CartState cart) {
  final String products = cart.items.length == 1 ? 'producto' : 'productos';
  final String units = cart.totalQuantity == 1 ? 'unidad' : 'unidades';
  return '${cart.items.length} $products · ${cart.totalQuantity} $units';
}

String _formatSoles(int cents) {
  return 'S/ ${(cents / 100).toStringAsFixed(2)}';
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
