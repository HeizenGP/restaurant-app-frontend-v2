import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';
import 'package:customer_app/features/m01_access/shared/infrastructure/flutter_secure_session_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/auth_fakes.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('round-trips a registered session through secure storage', () async {
    final FlutterSecureSessionStore store = FlutterSecureSessionStore();
    final AuthSession original = registeredSession();

    await store.write(original);
    final AuthSession? restored = await store.read();

    expect(restored?.accessToken, original.accessToken);
    expect(restored?.refreshToken, original.refreshToken);
    expect(restored?.kind, AuthSessionKind.user);
    expect(restored?.user?.displayName, customerIdentity.displayName);
    expect(restored?.user?.roles, <String>['CUSTOMER']);
  });

  test('clear removes persisted credentials', () async {
    final FlutterSecureSessionStore store = FlutterSecureSessionStore();
    await store.write(guestSession());

    await store.clear();

    expect(await store.read(), isNull);
  });

  test('corrupted data is discarded instead of restored', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'chifa_asia.auth_session.v1': '{broken json',
    });
    final FlutterSecureSessionStore store = FlutterSecureSessionStore();

    expect(await store.read(), isNull);
    expect(await store.read(), isNull);
  });
}
