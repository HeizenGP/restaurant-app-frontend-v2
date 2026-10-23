import 'package:customer_app/features/m01_access/shared/domain/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('registration validators mirror M01 limits', () {
    test('accepts trimmed backend-compatible values', () {
      expect(AccessValidators.displayName(' Ana Torres '), isNull);
      expect(AccessValidators.email('ana@example.com'), isNull);
      expect(AccessValidators.registrationPassword('12345678'), isNull);
    });

    test('rejects empty and malformed values', () {
      expect(AccessValidators.displayName('  '), isNotNull);
      expect(AccessValidators.email('ana@@example.com'), isNotNull);
      expect(AccessValidators.email('ana example.com'), isNotNull);
      expect(AccessValidators.email('ana\texample.com'), isNotNull);
      expect(AccessValidators.email('ana\n@example.com'), isNotNull);
      expect(AccessValidators.registrationPassword('1234567'), isNotNull);
    });

    test('login allows backend password range but requires a value', () {
      expect(AccessValidators.loginPassword('x'), isNull);
      expect(AccessValidators.loginPassword(''), isNotNull);
      expect(AccessValidators.loginPassword('x' * 129), isNotNull);
    });
  });
}
