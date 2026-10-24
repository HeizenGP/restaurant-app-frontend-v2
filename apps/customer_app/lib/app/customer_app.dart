import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../core/api_environment.dart';
import '../core/design_system/theme/app_theme.dart';
import '../features/m01_access/shared/application/auth_contracts.dart';
import '../features/m01_access/shared/application/auth_session_controller.dart';
import '../features/m01_access/shared/infrastructure/auth_rest_repository.dart';
import '../features/m01_access/shared/infrastructure/flutter_secure_session_store.dart';
import '../features/m02_catalog/browse_catalog/application/catalog_controller.dart';
import '../features/m02_catalog/shared/application/catalog_contracts.dart';
import '../features/m02_catalog/shared/infrastructure/catalog_rest_repository.dart';
import '../features/m04_orders/manage_cart/application/cart_controller.dart';
import 'navigation/customer_router.dart';
import 'theme/theme_mode_controller.dart';

class CustomerApp extends StatefulWidget {
  const CustomerApp({
    required this.environment,
    this.initialThemeMode = ThemeMode.light,
    this.authRepository,
    this.sessionStore,
    this.catalogRepository,
    super.key,
  });

  final ApiEnvironment environment;
  final ThemeMode initialThemeMode;
  final AuthRepository? authRepository;
  final AuthSessionStore? sessionStore;
  final CatalogRepository? catalogRepository;

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  late final ThemeModeController _themeModeController;
  late final AuthSessionController _authController;
  late final CatalogController _catalogController;
  late final CartController _cartController;
  late final CatalogRepository _catalogRepository;
  late final GoRouter _router;
  http.Client? _ownedHttpClient;

  @override
  void initState() {
    super.initState();
    _themeModeController = ThemeModeController(
      initialMode: widget.initialThemeMode,
    );
    final http.Client? sharedClient;
    if (widget.authRepository == null || widget.catalogRepository == null) {
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
    _router = createCustomerRouter(
      themeModeController: _themeModeController,
      authController: _authController,
      catalogController: _catalogController,
      cartController: _cartController,
    );
    _authController.restore();
  }

  @override
  void dispose() {
    _router.dispose();
    _catalogController.dispose();
    _cartController.dispose();
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
