import '../../../core/network/api_client.dart';
import '../domain/payment_models.dart';

class PaymentRepository {
  const PaymentRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<PaymentRecord>> getPayments({int limit = 100}) async {
    final dynamic response = await apiClient.get(
      '/payments',
      queryParameters: <String, dynamic>{'limit': limit},
    );
    if (response is! List<dynamic>) return <PaymentRecord>[];
    return response
        .map((dynamic item) =>
            PaymentRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<OrderPaymentSummary> getOrderPaymentSummary(String orderId) async {
    final dynamic response = await apiClient.get('/orders/$orderId/payments');
    return OrderPaymentSummary.fromJson(response as Map<String, dynamic>);
  }

  Future<OrderPaymentSummary> recordCollection({
    required String orderId,
    required double amount,
    required String methodCode,
    String? referenceCode,
  }) async {
    final dynamic response = await apiClient.post(
      '/orders/$orderId/payments',
      body: <String, dynamic>{
        'amount': amount,
        'method_code': methodCode,
        'reference_code': referenceCode?.trim().isEmpty ?? true ? null : referenceCode!.trim(),
      },
      requiresAuth: true,
      requiresIdempotency: true,
    );
    return OrderPaymentSummary.fromJson(response as Map<String, dynamic>);
  }
}
