import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/api_environment.dart';
import '../core/design_system/theme/asia_theme.dart';
import '../core/network/api_client.dart';
import '../core/storage/auth_storage.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/infrastructure/auth_repository.dart';
import '../features/dashboard/application/dashboard_controller.dart';
import '../features/dashboard/infrastructure/dashboard_repository.dart';
import '../features/inventory/application/inventory_controller.dart';
import '../features/inventory/infrastructure/inventory_repository.dart';
import '../features/orders/application/order_controller.dart';
import '../features/orders/infrastructure/order_repository.dart';
import '../features/payments/application/payment_controller.dart';
import '../features/payments/infrastructure/payment_repository.dart';
import '../features/products/application/catalog_controller.dart';
import '../features/products/infrastructure/catalog_repository.dart';
import '../features/staff/application/staff_controller.dart';
import '../features/staff/infrastructure/staff_repository.dart';
import '../features/tables/application/table_controller.dart';
import '../features/tables/infrastructure/table_repository.dart';
import 'navigation/app_router.dart';

class StaffApp extends StatefulWidget {
  const StaffApp({
    required this.environment,
    this.authController,
    this.dashboardController,
    this.catalogController,
    this.orderController,
    this.inventoryController,
    this.tableController,
    this.staffController,
    this.paymentController,
    super.key,
  });

  final ApiEnvironment environment;
  final AuthController? authController;
  final DashboardController? dashboardController;
  final CatalogController? catalogController;
  final OrderController? orderController;
  final InventoryController? inventoryController;
  final TableController? tableController;
  final StaffController? staffController;
  final PaymentController? paymentController;

  @override
  State<StaffApp> createState() => _StaffAppState();
}

class _StaffAppState extends State<StaffApp> {
  late final AuthStorage _storage;
  late final ApiClient _apiClient;

  late final AuthController _authController;
  late final DashboardController _dashboardController;
  late final CatalogController _catalogController;
  late final OrderController _orderController;
  late final InventoryController _inventoryController;
  late final TableController _tableController;
  late final StaffController _staffController;
  late final PaymentController _paymentController;

  late final GoRouter _router;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _storage = AuthStorage();
    _apiClient = ApiClient(environment: widget.environment, storage: _storage);

    _authController = widget.authController ??
        AuthController(
          repository: AuthRepository(apiClient: _apiClient, storage: _storage),
          storage: _storage,
        );

    _dashboardController = widget.dashboardController ??
        DashboardController(
          repository: DashboardRepository(apiClient: _apiClient),
        );

    _catalogController = widget.catalogController ??
        CatalogController(
          repository: CatalogRepository(apiClient: _apiClient),
        );

    _orderController = widget.orderController ??
        OrderController(
          repository: OrderRepository(apiClient: _apiClient),
        );

    _inventoryController = widget.inventoryController ??
        InventoryController(
          repository: InventoryRepository(apiClient: _apiClient),
        );

    _tableController = widget.tableController ??
        TableController(
          repository: TableRepository(apiClient: _apiClient),
        );

    _staffController = widget.staffController ??
        StaffController(
          repository: StaffRepository(apiClient: _apiClient),
        );

    _paymentController = widget.paymentController ??
        PaymentController(
          repository: PaymentRepository(apiClient: _apiClient),
        );

    _router = createAppRouter(
      authController: _authController,
      dashboardController: _dashboardController,
      catalogController: _catalogController,
      orderController: _orderController,
      inventoryController: _inventoryController,
      tableController: _tableController,
      staffController: _staffController,
      paymentController: _paymentController,
      isDarkMode: () => _isDarkMode,
      onToggleTheme: _toggleTheme,
    );

    // Attempt restoring session on app startup
    _authController.initialize();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KAIRO Admin · Portal Gastronómico',
      theme: AsiaTheme.light(),
      darkTheme: AsiaTheme.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}
