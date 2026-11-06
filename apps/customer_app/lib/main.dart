import 'package:flutter/material.dart';

import 'app/customer_app.dart';
import 'core/api_environment.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiEnvironment environment;
  try {
    environment = ApiEnvironment.fromCompileTime();
  } catch (_) {
    // Si se compila o ejecuta sin parámetros --dart-define o directamente
    // desde el launcher de Android, se usa Render por defecto para evitar
    // que la aplicación falle antes del primer frame y quede congelada en el splash nativo.
    environment = ApiEnvironment(baseUrl: ApiEnvironment.renderUrl);
  }
  runApp(CustomerApp(environment: environment));
}
