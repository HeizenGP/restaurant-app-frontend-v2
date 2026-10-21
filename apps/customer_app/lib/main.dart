import 'package:flutter/material.dart';

import 'app/customer_app.dart';
import 'core/api_environment.dart';

void main() {
  final ApiEnvironment environment = ApiEnvironment.fromCompileTime();
  runApp(CustomerApp(environment: environment));
}
