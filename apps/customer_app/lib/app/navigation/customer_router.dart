import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../features/m01_access/presentation/guest_access_page.dart';
import '../../features/m01_access/presentation/profile_pages.dart';
import '../../features/m01_access/presentation/registration_page.dart';
import '../../features/m01_access/presentation/sign_in_page.dart';
import '../../features/m01_access/profile/application/user_profile_controller.dart';
import '../../features/m01_access/shared/application/auth_session_controller.dart';
import '../../features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import '../../features/m02_catalog/presentation/catalog_pages.dart';
import '../../features/m02_catalog/shared/domain/catalog_models.dart';
import '../../features/m02_catalog/view_product/application/product_detail_controller.dart';
import '../../features/m04_orders/choose_fulfillment/application/fulfillment_controller.dart';
import '../../features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import '../../features/m04_orders/manage_cart/application/cart_controller.dart';
import '../../features/m04_orders/manage_cart/domain/cart_models.dart';
import '../../features/m04_orders/order_tracking/application/order_history_controller.dart';
import '../../features/m04_orders/order_tracking/application/order_tracking_controller.dart';
import '../../features/m04_orders/presentation/cart_page.dart';
import '../../features/m04_orders/presentation/fulfillment_pages.dart';
import '../../features/m04_orders/presentation/order_detail_tracking_page.dart';
import '../../features/m04_orders/presentation/order_submission_pages.dart';
import '../../features/m04_orders/presentation/orders_history_page.dart';
import '../../features/m04_orders/submit_order/application/submit_order_controller.dart';
import '../../features/m04_orders/submit_order/domain/order_models.dart';
import '../../features/m06_payments/presentation/payment_status_pages.dart';
import '../../features/m06_payments/view_payment_status/application/payment_status_controller.dart';
import '../theme/theme_mode_controller.dart';

abstract final class CustomerRoutes {
  static const String home = '/';
  static const String menu = '/menu';
  static const String orders = '/pedidos';
  static const String account = '/cuenta';

  static const String signIn = '/acceso';
  static const String registration = '/registro';
  static const String guest = '/invitado';

  static const String productDetail = '/menu/producto/:productId';
  static const String cart = '/carrito';

  static const String fulfillmentMode = '/pedido/modalidad';
  static const String tableSelection = '/pedido/mesa';
  static const String deliveryDetails = '/pedido/delivery';
  static const String pickupDetails = '/pedido/pickup';
  static const String orderReview = '/pedido/revisar';
  static const String orderSubmitted = '/pedido/confirmado';
  static const String orderException = '/pedido/error';

  static const String orderTracking = '/seguimiento/:orderId';
  static const String advanceStatus = '/anticipo/:orderId';
  static const String paymentStatus = '/pagos/:orderId';

  static const String personalInfo = '/cuenta/perfil';
  static const String addresses = '/cuenta/direcciones';
  static const String paymentMethods = '/cuenta/pagos';
}

GoRouter createCustomerRouter({
  required ThemeModeController themeModeController,
  required AuthSessionController authController,
  required CatalogController catalogController,
  required CartController cartController,
  required FulfillmentController fulfillmentController,
  required SubmitOrderController submitOrderController,
  PaymentStatusController? paymentStatusController,
  OrderHistoryController? orderHistoryController,
  OrderTrackingController? orderTrackingController,
  UserProfileController? profileController,
}) {
  CatalogProduct? lastSelectedProduct;
  CatalogCategory? lastSelectedCategory;
  FulfillmentDraft? activeFulfillmentDraft;
  OrderSnapshot? lastCreatedOrder;

  return GoRouter(
    initialLocation: CustomerRoutes.home,
    routes: <RouteBase>[
      // Shell con BottomNavigationBar persistente para las 4 pestañas
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: AsiaBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (int index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          );
        },
        branches: <StatefulShellBranch>[
          // Rama 0: Inicio
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: CustomerRoutes.home,
                name: 'home',
                builder: (BuildContext context, GoRouterState state) {
                  return HomePage(
                    catalogController: catalogController,
                    cartController: cartController,
                    onNavigateToMenu: () => context.go(CustomerRoutes.menu),
                    onNavigateToCart: () => context.push(CustomerRoutes.cart),
                    onProductSelected: (CatalogCategory cat, CatalogProduct prod) {
                      lastSelectedCategory = cat;
                      lastSelectedProduct = prod;
                      context.push('/menu/producto/${prod.id}');
                    },
                    onToggleTheme: themeModeController.toggle,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  );
                },
              ),
            ],
          ),

          // Rama 1: Menú
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: CustomerRoutes.menu,
                name: 'menu',
                builder: (BuildContext context, GoRouterState state) {
                  return CatalogPage(
                    catalogController: catalogController,
                    cartController: cartController,
                    onNavigateToCart: () => context.push(CustomerRoutes.cart),
                    onProductSelected: (CatalogCategory cat, CatalogProduct prod) {
                      lastSelectedCategory = cat;
                      lastSelectedProduct = prod;
                      context.push('/menu/producto/${prod.id}');
                    },
                    onToggleTheme: themeModeController.toggle,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  );
                },
              ),
            ],
          ),

          // Rama 2: Pedidos
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: CustomerRoutes.orders,
                name: 'orders',
                builder: (BuildContext context, GoRouterState state) {
                  if (orderHistoryController == null) {
                    return const AsiaScaffold(
                      title: 'Pedidos',
                      body: AsiaStateView(
                        kind: AsiaStateKind.empty,
                        title: 'Módulo de pedidos no disponible',
                      ),
                    );
                  }
                  return OrdersHistoryPage(
                    controller: orderHistoryController,
                    onBack: () => context.go(CustomerRoutes.home),
                    onOrderSelected: (String orderId) {
                      context.push('/seguimiento/$orderId');
                    },
                  );
                },
              ),
            ],
          ),

          // Rama 3: Cuenta
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: CustomerRoutes.account,
                name: 'account',
                builder: (BuildContext context, GoRouterState state) {
                  if (profileController == null) {
                    return const AsiaScaffold(
                      title: 'Mi cuenta',
                      body: AsiaStateView(
                        kind: AsiaStateKind.empty,
                        title: 'Perfil no disponible',
                      ),
                    );
                  }
                  return AccountHubPage(
                    authController: authController,
                    profileController: profileController,
                    onNavigateToPersonalInfo: () => context.push(CustomerRoutes.personalInfo),
                    onNavigateToAddresses: () => context.push(CustomerRoutes.addresses),
                    onNavigateToPaymentMethods: () => context.push(CustomerRoutes.paymentMethods),
                    onNavigateToOrders: () => context.go(CustomerRoutes.orders),
                    onToggleTheme: themeModeController.toggle,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Rutas de autenticación
      GoRoute(
        path: CustomerRoutes.signIn,
        name: 'signin',
        builder: (BuildContext context, GoRouterState state) {
          return SignInPage(
            controller: authController,
            onRegisterTap: () => context.push(CustomerRoutes.registration),
            onGuestTap: () => context.push(CustomerRoutes.guest),
            onSuccess: () => context.go(CustomerRoutes.home),
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.registration,
        name: 'registration',
        builder: (BuildContext context, GoRouterState state) {
          return RegistrationPage(
            controller: authController,
            onBackToSignIn: () => context.pop(),
            onSuccess: () => context.go(CustomerRoutes.home),
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.guest,
        name: 'guest',
        builder: (BuildContext context, GoRouterState state) {
          return GuestAccessPage(
            controller: authController,
            onBackToSignIn: () => context.pop(),
            onSuccess: () => context.go(CustomerRoutes.home),
          );
        },
      ),

      // Rutas de Catálogo y Producto
      GoRoute(
        path: CustomerRoutes.productDetail,
        name: 'productDetail',
        builder: (BuildContext context, GoRouterState state) {
          final String productId = state.pathParameters['productId'] ?? '';
          final ProductDetailController detailController = ProductDetailController.fromSelection(
            categoryId: lastSelectedCategory?.id ?? '',
            productId: productId,
            selectedProduct: lastSelectedProduct,
          );

          return ProductDetailPage(
            controller: detailController,
            cartController: cartController,
            onBack: () => context.pop(),
            onNavigateToCart: () => context.push(CustomerRoutes.cart),
          );
        },
      ),

      // Ruta del Carrito
      GoRoute(
        path: CustomerRoutes.cart,
        name: 'cart',
        builder: (BuildContext context, GoRouterState state) {
          return CartPage(
            cartController: cartController,
            onBack: () => context.pop(),
            onBrowseCatalog: () => context.go(CustomerRoutes.menu),
            onProceedToFulfillment: () => context.push(CustomerRoutes.fulfillmentMode),
          );
        },
      ),

      // Rutas del flujo de Checkout y Pedido
      GoRoute(
        path: CustomerRoutes.fulfillmentMode,
        name: 'fulfillmentMode',
        builder: (BuildContext context, GoRouterState state) {
          return FulfillmentModePage(
            controller: fulfillmentController,
            onBack: () => context.pop(),
            onTableSelected: () => context.push(CustomerRoutes.tableSelection),
            onDeliverySelected: () => context.push(CustomerRoutes.deliveryDetails),
            onPickupSelected: () => context.push(CustomerRoutes.pickupDetails),
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.tableSelection,
        name: 'tableSelection',
        builder: (BuildContext context, GoRouterState state) {
          return TableSelectionPage(
            controller: fulfillmentController,
            onBack: () => context.pop(),
            onTableConfirmed: (FulfillmentDraft draft) {
              activeFulfillmentDraft = draft;
              submitOrderController.startNewLogicalRequest(
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
              context.push(CustomerRoutes.orderReview);
            },
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.deliveryDetails,
        name: 'deliveryDetails',
        builder: (BuildContext context, GoRouterState state) {
          final String? initialAddr = profileController != null && profileController.addresses.isNotEmpty
              ? profileController.addresses.first.address
              : null;
          final String? initialName = profileController?.displayName;
          final String? initialPhone = profileController?.phone;

          return DeliveryDetailsPage(
            onBack: () => context.pop(),
            initialAddress: initialAddr,
            initialName: initialName,
            initialPhone: initialPhone,
            onDeliveryConfirmed: (FulfillmentDraft draft) {
              activeFulfillmentDraft = draft;
              submitOrderController.startNewLogicalRequest(
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
              context.push(CustomerRoutes.orderReview);
            },
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.pickupDetails,
        name: 'pickupDetails',
        builder: (BuildContext context, GoRouterState state) {
          final String? initialName = profileController?.displayName;
          final String? initialPhone = profileController?.phone;

          return PickupDetailsPage(
            onBack: () => context.pop(),
            initialName: initialName,
            initialPhone: initialPhone,
            onPickupConfirmed: (FulfillmentDraft draft) {
              activeFulfillmentDraft = draft;
              submitOrderController.startNewLogicalRequest(
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
              context.push(CustomerRoutes.orderReview);
            },
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.orderReview,
        name: 'orderReview',
        builder: (BuildContext context, GoRouterState state) {
          final FulfillmentDraft draft = activeFulfillmentDraft ??
              FulfillmentDraft.local(tableId: 'M1');

          return OrderReviewPage(
            controller: submitOrderController,
            items: cartController.state.items,
            fulfillment: draft,
            onBack: () => context.pop(),
            onShowException: () => context.push(CustomerRoutes.orderException),
            onOrderPlaced: (OrderSnapshot order) {
              lastCreatedOrder = order;
              cartController.clear();
              context.go(CustomerRoutes.orderSubmitted);
            },
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.orderSubmitted,
        name: 'orderSubmitted',
        builder: (BuildContext context, GoRouterState state) {
          final OrderSnapshot order = lastCreatedOrder ??
              OrderSnapshot(
                id: 'ORD-DEMO',
                status: 'REQUESTED',
                channel: 'CUSTOMER_APP',
                modality: FulfillmentMode.local,
                totalAmount: '0.00',
                lines: const <OrderLineSnapshot>[],
                createdAt: DateTime.now(),
              );

          return OrderSubmittedPage(
            order: order,
            onViewTracking: () => context.go('/seguimiento/${order.id}'),
            onGoHome: () => context.go(CustomerRoutes.home),
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.orderException,
        name: 'orderException',
        builder: (BuildContext context, GoRouterState state) {
          return OrderExceptionPage(
            controller: submitOrderController,
            onRetry: () async {
              final bool ok = await submitOrderController.retrySubmission();
              if (ok && submitOrderController.state.order != null && context.mounted) {
                lastCreatedOrder = submitOrderController.state.order;
                cartController.clear();
                context.go(CustomerRoutes.orderSubmitted);
              }
            },
            onBack: () => context.pop(),
          );
        },
      ),

      // Rutas de Seguimiento y Pagos
      GoRoute(
        path: CustomerRoutes.orderTracking,
        name: 'orderTracking',
        builder: (BuildContext context, GoRouterState state) {
          final String orderId = state.pathParameters['orderId'] ?? '';
          if (orderTrackingController == null) {
            return const AsiaScaffold(
              title: 'Seguimiento',
              body: AsiaStateView(
                kind: AsiaStateKind.empty,
                title: 'Controlador de seguimiento no disponible',
              ),
            );
          }

          return OrderDetailTrackingPage(
            orderId: orderId,
            controller: orderTrackingController,
            onBack: () => context.go(CustomerRoutes.orders),
            onViewAdvance: (String id) => context.push('/anticipo/$id'),
            onViewPayments: (String id) => context.push('/pagos/$id'),
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.advanceStatus,
        name: 'advanceStatus',
        builder: (BuildContext context, GoRouterState state) {
          final String orderId = state.pathParameters['orderId'] ?? '';
          if (paymentStatusController == null) {
            return const AsiaScaffold(
              title: 'Anticipo',
              body: AsiaStateView(
                kind: AsiaStateKind.empty,
                title: 'Módulo de pagos no disponible',
              ),
            );
          }

          return AdvanceStatusPage(
            orderId: orderId,
            controller: paymentStatusController,
            onBack: () => context.pop(),
            onViewOrder: () => context.go('/seguimiento/$orderId'),
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.paymentStatus,
        name: 'paymentStatus',
        builder: (BuildContext context, GoRouterState state) {
          final String orderId = state.pathParameters['orderId'] ?? '';
          if (paymentStatusController == null) {
            return const AsiaScaffold(
              title: 'Pagos',
              body: AsiaStateView(
                kind: AsiaStateKind.empty,
                title: 'Módulo de pagos no disponible',
              ),
            );
          }

          return OrderPaymentStatusPage(
            orderId: orderId,
            controller: paymentStatusController,
            onBack: () => context.pop(),
          );
        },
      ),

      // Rutas del Perfil
      GoRoute(
        path: CustomerRoutes.personalInfo,
        name: 'personalInfo',
        builder: (BuildContext context, GoRouterState state) {
          if (profileController == null) {
            return const AsiaScaffold(
              title: 'Información personal',
              body: AsiaStateView(
                kind: AsiaStateKind.empty,
                title: 'Perfil no disponible',
              ),
            );
          }
          return PersonalInfoPage(
            profileController: profileController,
            onBack: () => context.pop(),
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.addresses,
        name: 'addresses',
        builder: (BuildContext context, GoRouterState state) {
          if (profileController == null) {
            return const AsiaScaffold(
              title: 'Direcciones',
              body: AsiaStateView(
                kind: AsiaStateKind.empty,
                title: 'Perfil no disponible',
              ),
            );
          }
          return AddressesPage(
            profileController: profileController,
            onBack: () => context.pop(),
          );
        },
      ),
      GoRoute(
        path: CustomerRoutes.paymentMethods,
        name: 'paymentMethods',
        builder: (BuildContext context, GoRouterState state) {
          if (profileController == null) {
            return const AsiaScaffold(
              title: 'Métodos de pago',
              body: AsiaStateView(
                kind: AsiaStateKind.empty,
                title: 'Perfil no disponible',
              ),
            );
          }
          return PaymentMethodsPage(
            profileController: profileController,
            onBack: () => context.pop(),
          );
        },
      ),
    ],
  );
}
