import '../../../core/network/api_client.dart';
import '../domain/order_models.dart';

class OrderRepository {
  const OrderRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<StaffOrder>> getOrders() async {
    final dynamic response = await apiClient.get('/orders');
    if (response is! List<dynamic>) return <StaffOrder>[];
    return response
        .map(
          (dynamic item) => StaffOrder.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<StaffOrder> getOrder(String orderId) async {
    final dynamic response = await apiClient.get('/orders/$orderId');
    return StaffOrder.fromJson(response as Map<String, dynamic>);
  }

  Future<StaffOrder> decideOrder(
    String orderId, {
    required bool approved,
    bool tableVerified = true,
  }) async {
    final dynamic response = await apiClient.post(
      '/orders/$orderId/decision',
      body: <String, dynamic>{
        'approved': approved,
        'table_verified': tableVerified,
      },
      requiresAuth: true,
    );
    return StaffOrder.fromJson(response as Map<String, dynamic>);
  }

  Future<StaffOrder> confirmOrder(String orderId) async {
    final dynamic response = await apiClient.post(
      '/orders/$orderId/confirm',
      requiresAuth: true,
      requiresIdempotency: true,
    );
    return StaffOrder.fromJson(response as Map<String, dynamic>);
  }

  Future<void> serveOrder(String orderId) async {
    await apiClient.post(
      '/orders/$orderId/serve',
      requiresAuth: true,
      requiresIdempotency: true,
    );
  }

  Future<void> pickupOrder(String orderId) async {
    await apiClient.post(
      '/orders/$orderId/pickup',
      requiresAuth: true,
      requiresIdempotency: true,
    );
  }

  Future<void> deliverOrder(String orderId) async {
    await apiClient.post(
      '/orders/$orderId/deliver',
      requiresAuth: true,
      requiresIdempotency: true,
    );
  }

  Future<void> closeOrder(String orderId) async {
    await apiClient.post(
      '/orders/$orderId/close',
      requiresAuth: true,
      requiresIdempotency: true,
    );
  }

  Future<void> recordPayment({
    required String orderId,
    required double amount,
    required String methodCode,
    String? referenceCode,
  }) async {
    await apiClient.post(
      '/orders/$orderId/payments',
      body: <String, dynamic>{
        'amount': amount,
        'method_code': methodCode,
        if (referenceCode != null && referenceCode.isNotEmpty)
          'reference_code': referenceCode,
      },
      requiresAuth: true,
      requiresIdempotency: true,
    );
  }
}
