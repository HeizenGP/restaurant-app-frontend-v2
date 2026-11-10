import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/staff_app.dart';
import 'core/api_environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('es', null);
  } catch (_) {
    // Fallback if locale data is already initialized or unavailable
  }
  final ApiEnvironment environment = ApiEnvironment.fromCompileTime();
  runApp(StaffApp(environment: environment));
}
