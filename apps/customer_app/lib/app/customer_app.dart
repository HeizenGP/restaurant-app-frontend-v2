import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../core/api_environment.dart';
import '../core/design_system/theme/app_theme.dart';
import '../features/m01_access/shared/application/auth_contracts.dart';
import '../features/m01_access/shared/application/auth_session_controller.dart';
import '../features/m01_access/shared/infrastructure/auth_rest_repository.dart';
import '../features/m01_access/shared/infrastructure/flutter_secure_session_store.dart';
import 'navigation/customer_router.dart';
import 'theme/theme_mode_controller.dart';

class CustomerApp extends StatefulWidget {
  const CustomerApp({
    required this.environment,
    this.initialThemeMode = ThemeMode.light,
    this.authRepository,
    this.sessionStore,
    super.key,
  });

  final ApiEnvironment environment;
  final ThemeMode initialThemeMode;
  final AuthRepository? authRepository;
  final AuthSessionStore? sessionStore;

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  late final ThemeModeController _themeModeController;
  late final AuthSessionController _authController;
  late final GoRouter _router;
  http.Client? _ownedHttpClient;

  @override
  void initState() {
    super.initState();
    _themeModeController = ThemeModeController(
      initialMode: widget.initialThemeMode,
    );
    final AuthRepository repository;
    if (widget.authRepository case final AuthRepository injected) {
      repository = injected;
    } else {
      final http.Client client = http.Client();
      _ownedHttpClient = client;
      repository = AuthRestRepository(
        baseUri: widget.environment.baseUri,
        client: client,
      );
    }
    _authController = AuthSessionController(
      repository: repository,
      sessionStore: widget.sessionStore ?? FlutterSecureSessionStore(),
    );
    _router = createCustomerRouter(
      themeModeController: _themeModeController,
      authController: _authController,
    );
    _authController.restore();
  }

  @override
  void dispose() {
    _router.dispose();
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
