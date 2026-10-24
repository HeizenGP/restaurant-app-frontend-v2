import '../domain/order_models.dart';

abstract interface class OrdersRepository {
  Future<OrderSnapshot> createOrder(
    CreateOrderCommand command, {
    required String accessToken,
    required String idempotencyKey,
  });

  Future<OrderSnapshot> getOrder(String orderId, {required String accessToken});
}

typedef AccessTokenProvider = String? Function();
typedef RefreshAccessToken = Future<bool> Function();
typedef IdempotencyKeyGenerator = String Function();

enum OrderFailureKind {
  unauthorized,
  forbidden,
  notFound,
  productUnavailable,
  idempotencyConflict,
  conflict,
  validation,
  timeout,
  network,
  server,
  malformedResponse,
}

final class OrderFailure implements Exception {
  const OrderFailure(this.kind, this.message);

  final OrderFailureKind kind;
  final String message;

  bool get canRetrySafely {
    return kind == OrderFailureKind.timeout ||
        kind == OrderFailureKind.network ||
        kind == OrderFailureKind.server ||
        kind == OrderFailureKind.malformedResponse;
  }

  @override
  String toString() => 'OrderFailure($kind, $message)';
}
