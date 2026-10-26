import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../core/api_environment.dart';
import '../core/design_system/theme/app_theme.dart';
import '../features/m01_access/profile/application/user_profile_controller.dart';
import '../features/m01_access/shared/application/auth_contracts.dart';
import '../features/m01_access/shared/application/auth_session_controller.dart';
import '../features/m01_access/shared/domain/auth_models.dart';
import '../features/m01_access/shared/infrastructure/auth_rest_repository.dart';
import '../features/m01_access/shared/infrastructure/flutter_secure_session_store.dart';
import '../features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import '../features/m02_catalog/shared/application/catalog_contracts.dart';
import '../features/m02_catalog/shared/infrastructure/catalog_rest_repository.dart';
import '../features/m04_orders/choose_fulfillment/application/fulfillment_contracts.dart';
import '../features/m04_orders/choose_fulfillment/application/fulfillment_controller.dart';
import '../features/m04_orders/choose_fulfillment/infrastructure/tables_rest_repository.dart';
import '../features/m04_orders/manage_cart/application/cart_controller.dart';
import '../features/m04_orders/order_tracking/application/order_history_controller.dart';
import '../features/m04_orders/order_tracking/application/order_tracking_contracts.dart';
import '../features/m04_orders/order_tracking/application/order_tracking_controller.dart';
import '../features/m04_orders/order_tracking/infrastructure/order_tracking_rest_repository.dart';
import '../features/m04_orders/submit_order/application/order_contracts.dart';
import '../features/m04_orders/submit_order/application/submit_order_controller.dart';
import '../features/m04_orders/submit_order/infrastructure/orders_rest_repository.dart';
import '../features/m06_payments/view_payment_status/application/payment_status_contracts.dart';
import '../features/m06_payments/view_payment_status/application/payment_status_controller.dart';
import '../features/m06_payments/view_payment_status/infrastructure/payment_status_rest_repository.dart';
import 'navigation/customer_router.dart';
import 'theme/theme_mode_controller.dart';

class CustomerApp extends StatefulWidget {
  const CustomerApp({
    required this.environment,
    this.initialThemeMode = ThemeMode.light,
    this.authRepository,
    this.sessionStore,
    this.catalogRepository,
    this.tablesRepository,
    this.ordersRepository,
    this.paymentStatusRepository,
    this.orderTrackingRepository,
    this.userProfileController,
    super.key,
  });

  final ApiEnvironment environment;
  final ThemeMode initialThemeMode;
  final AuthRepository? authRepository;
  final AuthSessionStore? sessionStore;
  final CatalogRepository? catalogRepository;
  final TablesRepository? tablesRepository;
  final OrdersRepository? ordersRepository;
  final PaymentStatusRepository? paymentStatusRepository;
  final OrderTrackingRepository? orderTrackingRepository;
  final UserProfileController? userProfileController;

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  late final ThemeModeController _themeModeController;
  late final AuthSessionController _authController;
  late final CatalogController _catalogController;
  late final CartController _cartController;
  late final FulfillmentController _fulfillmentController;
  late final SubmitOrderController _submitOrderController;
  late final PaymentStatusController _paymentStatusController;
  late final OrderHistoryController _orderHistoryController;
  late final OrderTrackingController _orderTrackingController;
  late final UserProfileController _userProfileController;
  UserProfileController? _ownedUserProfileController;
  late final CatalogRepository _catalogRepository;
  late final GoRouter _router;
  http.Client? _ownedHttpClient;
  String? _lastSessionUserId;
  bool _lastSessionIsGuest = false;

  void _onAuthStateChanged() {
    final AuthState authState = _authController.state;
    final AuthSession? session = authState.session;
    final String? currentUserId = session?.user?.id;
    final bool currentIsGuest = session?.isGuest ?? false;

    if (authState.status == AuthStatus.signedOut ||
        currentUserId != _lastSessionUserId ||
        currentIsGuest != _lastSessionIsGuest) {
      _lastSessionUserId = currentUserId;
      _lastSessionIsGuest = currentIsGuest;
      _cartController.clear();
      _fulfillmentController.clear();
      _orderHistoryController.clear();
      _orderTrackingController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _themeModeController = ThemeModeController(
      initialMode: widget.initialThemeMode,
    );
    final http.Client? sharedClient;
    if (widget.authRepository == null ||
        widget.catalogRepository == null ||
        widget.tablesRepository == null ||
        widget.ordersRepository == null ||
        widget.paymentStatusRepository == null ||
        widget.orderTrackingRepository == null) {
      sharedClient = http.Client();
      _ownedHttpClient = sharedClient;
    } else {
      sharedClient = null;
    }

    final AuthRepository authRepository;
    if (widget.authRepository case final AuthRepository injected) {
      authRepository = injected;
    } else {
      authRepository = AuthRestRepository(
        baseUri: widget.environment.baseUri,
        client: sharedClient!,
      );
    }
    _authController = AuthSessionController(
      repository: authRepository,
      sessionStore: widget.sessionStore ?? FlutterSecureSessionStore(),
    );

    _catalogRepository =
        widget.catalogRepository ??
        CatalogRestRepository(
          baseUri: widget.environment.baseUri,
          client: sharedClient!,
        );
    _catalogController = CatalogController(repository: _catalogRepository);
    _cartController = CartController();
    _fulfillmentController = FulfillmentController(
      tablesRepository:
          widget.tablesRepository ??
          TablesRestRepository(
            baseUri: widget.environment.baseUri,
            client: sharedClient!,
          ),
    );
    _submitOrderController = SubmitOrderController(
      repository:
          widget.ordersRepository ??
          OrdersRestRepository(
            baseUri: widget.environment.baseUri,
            client: sharedClient!,
          ),
      accessTokenProvider: () => _authController.state.session?.accessToken,
      refreshAccessToken: _authController.refreshSession,
    );
    _paymentStatusController = PaymentStatusController(
      repository:
          widget.paymentStatusRepository ??
          PaymentStatusRestRepository(
            baseUri: widget.environment.baseUri,
            client: sharedClient!,
          ),
      accessTokenProvider: () => _authController.state.session?.accessToken,
      refreshAccessToken: _authController.refreshSession,
    );
    final OrderTrackingRepository orderTrackingRepository =
        widget.orderTrackingRepository ??
        OrderTrackingRestRepository(
          baseUri: widget.environment.baseUri,
          client: sharedClient!,
        );
    _orderHistoryController = OrderHistoryController(
      repository: orderTrackingRepository,
      accessTokenProvider: () => _authController.state.session?.accessToken,
      refreshAccessToken: _authController.refreshSession,
    );
    _orderTrackingController = OrderTrackingController(
      repository: orderTrackingRepository,
      accessTokenProvider: () => _authController.state.session?.accessToken,
      refreshAccessToken: _authController.refreshSession,
    );
    if (widget.userProfileController case final UserProfileController injected) {
      _userProfileController = injected;
      _ownedUserProfileController = null;
    } else {
      _userProfileController = UserProfileController();
      _ownedUserProfileController = _userProfileController;
    }
    _router = createCustomerRouter(
      themeModeController: _themeModeController,
      authController: _authController,
      catalogController: _catalogController,
      cartController: _cartController,
      fulfillmentController: _fulfillmentController,
      submitOrderController: _submitOrderController,
      paymentStatusController: _paymentStatusController,
      orderHistoryController: _orderHistoryController,
      orderTrackingController: _orderTrackingController,
      profileController: _userProfileController,
    );
    _authController.addListener(_onAuthStateChanged);
    _authController.restore();
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthStateChanged);
    _router.dispose();
    _catalogController.dispose();
    _cartController.dispose();
    _fulfillmentController.dispose();
    _submitOrderController.dispose();
    _paymentStatusController.dispose();
    _orderHistoryController.dispose();
    _orderTrackingController.dispose();
    _ownedUserProfileController?.dispose();
    _authController.dispose();
    _themeModeController.dispose();
    _ownedHttpClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeController,
      builder: (BuildContext context, ThemeMode themeMode, Widget? child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Chifa ASIA',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
