import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api_environment.dart';
import '../core/design_system/theme/app_theme.dart';
import 'navigation/customer_router.dart';
import 'theme/theme_mode_controller.dart';

class CustomerApp extends StatefulWidget {
  const CustomerApp({
    required this.environment,
    this.initialThemeMode = ThemeMode.light,
    super.key,
  });

  final ApiEnvironment environment;
  final ThemeMode initialThemeMode;

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  late final ThemeModeController _themeModeController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeModeController = ThemeModeController(
      initialMode: widget.initialThemeMode,
    );
    _router = createCustomerRouter(themeModeController: _themeModeController);
  }

  @override
  void dispose() {
    _router.dispose();
    _themeModeController.dispose();
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
