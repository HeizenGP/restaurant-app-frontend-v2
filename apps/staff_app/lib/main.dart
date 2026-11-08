import 'package:flutter/material.dart';

import 'app/staff_app.dart';
import 'core/api_environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ApiEnvironment environment = ApiEnvironment.fromCompileTime();
  runApp(StaffApp(environment: environment));
}
