import 'package:google_sign_in/google_sign_in.dart';

import '../application/auth_contracts.dart';

class GoogleSignInIdentityProvider implements GoogleIdentityProvider {
  GoogleSignInIdentityProvider({required String serverClientId})
    : _serverClientId = serverClientId.trim();

  final String _serverClientId;
  Future<void>? _initialization;

  @override
  bool get isConfigured => _serverClientId.isNotEmpty;

  Future<void> _initialize() {
    if (!isConfigured) {
      throw const AuthFailure(
        AuthFailureKind.providerUnavailable,
        'Google no está configurado todavía en KAIRO.',
      );
    }
    return _initialization ??= GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId,
    );
  }

  @override
  Future<String> authenticate() async {
    try {
      await _initialize();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw const AuthFailure(
          AuthFailureKind.providerUnavailable,
          'Google no está disponible en este dispositivo.',
        );
      }
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate();
      final String? token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw const AuthFailure(
          AuthFailureKind.malformedResponse,
          'Google no devolvió una identidad verificable.',
        );
      }
      return token;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure(
          AuthFailureKind.cancelled,
          'Inicio con Google cancelado.',
        );
      }
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError ||
          error.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw const AuthFailure(
          AuthFailureKind.providerUnavailable,
          'Google OAuth necesita completar su configuración.',
        );
      }
      throw const AuthFailure(
        AuthFailureKind.server,
        'No pudimos iniciar sesión con Google. Inténtalo nuevamente.',
      );
    }
  }

  @override
  Future<void> signOut() => GoogleSignIn.instance.signOut();
}
