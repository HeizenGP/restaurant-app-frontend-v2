import 'package:flutter/material.dart';

import 'app/staff_app.dart';
import 'core/api_environment.dart';

void main() {
  final ApiEnvironment environment = ApiEnvironment.fromCompileTime();
  runApp(StaffApp(environment: environment));
}
