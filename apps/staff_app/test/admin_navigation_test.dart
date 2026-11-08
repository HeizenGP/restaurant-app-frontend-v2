import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/app/staff_app.dart';
import 'package:staff_app/core/api_environment.dart';
import 'package:staff_app/core/design_system/components/kairo_logo.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/core/storage/auth_storage.dart';
import 'package:staff_app/features/auth/application/auth_controller.dart';
import 'package:staff_app/features/auth/infrastructure/auth_repository.dart';

class MockAuthStorage extends AuthStorage {
  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<Map<String, dynamic>?> getUserData() async => null;
}

void main() {
  testWidgets('Renders Login Page when user is unauthenticated', (WidgetTester tester) async {
    final ApiEnvironment environment = ApiEnvironment(baseUrl: 'https://api.kairo.pe/api/v1');
    final MockAuthStorage storage = MockAuthStorage();
    final ApiClient client = ApiClient(environment: environment, storage: storage);
    final AuthRepository authRepo = AuthRepository(apiClient: client, storage: storage);
    final AuthController authController = AuthController(repository: authRepo, storage: storage);

    await tester.pumpWidget(
      StaffApp(
        environment: environment,
        authController: authController,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Kairo Branding is rendered
    expect(find.byType(KairoAdminLogo), findsWidgets);
    expect(find.text('KAIRO'), findsWidgets);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Ingresa tus credenciales del personal de KAIRO'), findsOneWidget);
    expect(find.text('Ingresar al Sistema'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Email and Password
  });
}
