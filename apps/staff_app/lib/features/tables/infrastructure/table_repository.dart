import '../../../core/network/api_client.dart';
import '../domain/table_models.dart';

class TableRepository {
  const TableRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<RestaurantTable>> getTables() async {
    final dynamic response = await apiClient.get('/tables');
    if (response is! List<dynamic>) return <RestaurantTable>[];
    return response
        .map(
          (dynamic item) =>
              RestaurantTable.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<RestaurantTable> createTable({
    required String code,
    String? areaLabel,
  }) async {
    final dynamic response = await apiClient.post(
      '/tables',
      body: <String, dynamic>{
        'code': code.trim(),
        'area_label': areaLabel?.trim().isEmpty ?? true
            ? null
            : areaLabel!.trim(),
      },
      requiresAuth: true,
    );
    return RestaurantTable.fromJson(response as Map<String, dynamic>);
  }

  Future<RestaurantTable> updateTable(
    String tableId, {
    String? code,
    String? areaLabel,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (code != null) body['code'] = code.trim();
    if (areaLabel != null) {
      body['area_label'] = areaLabel.trim().isEmpty ? null : areaLabel.trim();
    }

    final dynamic response = await apiClient.patch(
      '/tables/$tableId',
      body: body,
      requiresAuth: true,
    );
    return RestaurantTable.fromJson(response as Map<String, dynamic>);
  }

  Future<RestaurantTable> setOccupancy(String tableId, bool isOccupied) async {
    final dynamic response = await apiClient.patch(
      '/tables/$tableId/occupancy',
      body: <String, dynamic>{'is_occupied': isOccupied},
      requiresAuth: true,
    );
    return RestaurantTable.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteTable(String tableId) async {
    await apiClient.delete('/tables/$tableId', requiresAuth: true);
  }
}
