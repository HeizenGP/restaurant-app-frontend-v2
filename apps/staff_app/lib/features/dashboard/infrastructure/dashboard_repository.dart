import '../../../core/network/api_client.dart';
import '../domain/dashboard_models.dart';

class DashboardRepository {
  const DashboardRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<DashboardStats> getStats() async {
    final dynamic response = await apiClient.get('/reports/dashboard');
    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Respuesta inválida del servidor para métricas de dashboard.',
      );
    }
    return DashboardStats.fromJson(response);
  }
}
