import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_models.dart';

class StaffRepository {
  const StaffRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<StaffUser>> getStaffList({RoleCode? role}) async {
    final Map<String, dynamic>? query =
        role != null ? <String, dynamic>{'role': role.value} : null;
    final dynamic response =
        await apiClient.get('/users', queryParameters: query);
    if (response is! List<dynamic>) return <StaffUser>[];
    return response
        .map((dynamic item) =>
            StaffUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<StaffUser> createStaffMember({
    required String displayName,
    required String email,
    required String password,
    required RoleCode role,
    String? phone,
  }) async {
    final dynamic response = await apiClient.post(
      '/users',
      body: <String, dynamic>{
        'display_name': displayName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': role.value,
        'phone': phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      },
      requiresAuth: true,
    );
    return StaffUser.fromJson(response as Map<String, dynamic>);
  }

  Future<StaffUser> setUserStatus(String userId, bool isActive) async {
    final dynamic response = await apiClient.patch(
      '/users/$userId/status',
      body: <String, dynamic>{'is_active': isActive},
      requiresAuth: true,
    );
    return StaffUser.fromJson(response as Map<String, dynamic>);
  }

  Future<StaffUser> assignRole(String userId, RoleCode role) async {
    final dynamic response = await apiClient.post(
      '/users/$userId/roles',
      body: <String, dynamic>{'role': role.value},
      requiresAuth: true,
    );
    return StaffUser.fromJson(response as Map<String, dynamic>);
  }
}
