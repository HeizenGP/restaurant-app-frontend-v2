import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  const AuthRepository({
    required this.apiClient,
    required this.storage,
  });

  final ApiClient apiClient;
  final AuthStorage storage;

  Future<StaffSession> login({
    required String email,
    required String password,
  }) async {
    final dynamic response = await apiClient.post(
      '/auth/login',
      body: <String, String>{
        'email': email.trim().toLowerCase(),
        'password': password,
      },
      requiresAuth: false,
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Respuesta inválida del servidor al autenticar.',
      );
    }

    final String accessToken = response['access_token'] as String;
    final String? refreshToken = response['refresh_token'] as String?;

    await storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    StaffUser? user;
    if (response['user'] is Map<String, dynamic>) {
      user = StaffUser.fromJson(response['user'] as Map<String, dynamic>);
      await storage.saveUserData(user.toJson());
    }

    return StaffSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  Future<StaffUser> getCurrentUser() async {
    final dynamic response = await apiClient.get('/users/me');
    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'No se pudo obtener el perfil de usuario.',
      );
    }
    final StaffUser user = StaffUser.fromJson(response);
    await storage.saveUserData(user.toJson());
    return user;
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout', requiresAuth: true);
    } catch (_) {
      // Ignored: cleanup storage regardless
    } finally {
      await storage.clear();
    }
  }
}
