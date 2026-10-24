import '../domain/payment_models.dart';

abstract interface class PaymentStatusRepository {
  Future<AdvanceSummary> getAdvance(
    String orderId, {
    required String accessToken,
  });

  Future<PaymentSummary> getPayments(
    String orderId, {
    required String accessToken,
  });
}

typedef PaymentAccessTokenProvider = String? Function();
typedef RefreshPaymentAccessToken = Future<bool> Function();

enum PaymentStatusFailureKind {
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  timeout,
  network,
  server,
  malformedResponse,
}

final class PaymentStatusFailure implements Exception {
  const PaymentStatusFailure(this.kind, this.message);

  final PaymentStatusFailureKind kind;
  final String message;

  bool get canRetrySafely {
    return kind == PaymentStatusFailureKind.timeout ||
        kind == PaymentStatusFailureKind.network ||
        kind == PaymentStatusFailureKind.server ||
        kind == PaymentStatusFailureKind.malformedResponse;
  }

  @override
  String toString() => 'PaymentStatusFailure($kind, $message)';
}
