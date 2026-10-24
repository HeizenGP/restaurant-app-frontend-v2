import 'package:customer_app/features/m06_payments/view_payment_status/application/payment_status_contracts.dart';
import 'package:customer_app/features/m06_payments/view_payment_status/domain/payment_models.dart';

final class FakePaymentStatusRepository implements PaymentStatusRepository {
  FakePaymentStatusRepository({
    AdvanceSummary? advanceResponse,
    PaymentSummary? paymentResponse,
  })  : advanceResponse = advanceResponse ?? fakeAdvanceSummary(),
        paymentResponse = paymentResponse ?? fakePaymentSummary();

  AdvanceSummary advanceResponse;
  PaymentSummary paymentResponse;

  final List<String> advanceOrderIds = <String>[];
  final List<String> advanceTokens = <String>[];
  final List<String> paymentOrderIds = <String>[];
  final List<String> paymentTokens = <String>[];

  Object? advanceError;
  Object? paymentError;

  @override
  Future<AdvanceSummary> getAdvance(
    String orderId, {
    required String accessToken,
  }) async {
    advanceOrderIds.add(orderId);
    advanceTokens.add(accessToken);
    if (advanceError != null) throw advanceError!;
    return advanceResponse;
  }

  @override
  Future<PaymentSummary> getPayments(
    String orderId, {
    required String accessToken,
  }) async {
    paymentOrderIds.add(orderId);
    paymentTokens.add(accessToken);
    if (paymentError != null) throw paymentError!;
    return paymentResponse;
  }
}

AdvanceSummary fakeAdvanceSummary({
  String orderId = '00000000-0000-4000-8000-000000000201',
  String orderStatus = 'REQUESTED',
  String totalAmount = '45.00',
  String requiredAmount = '22.50',
  String verifiedAmount = '0.00',
  String remainingAmount = '22.50',
  DateTime? verifiedAt,
}) {
  return AdvanceSummary(
    orderId: orderId,
    orderStatus: orderStatus,
    totalAmount: totalAmount,
    requiredAmount: requiredAmount,
    verifiedAmount: verifiedAmount,
    remainingAmount: remainingAmount,
    verifiedAt: verifiedAt,
  );
}

PaymentSummary fakePaymentSummary({
  String orderId = '00000000-0000-4000-8000-000000000201',
  String orderStatus = 'REQUESTED',
  String totalAmount = '45.00',
  String paidAmount = '0.00',
  String balance = '45.00',
  String paymentStatus = 'UNPAID',
  List<PaymentRecord>? payments,
}) {
  return PaymentSummary(
    orderId: orderId,
    orderStatus: orderStatus,
    totalAmount: totalAmount,
    paidAmount: paidAmount,
    balance: balance,
    paymentStatus: paymentStatus,
    payments: payments ?? const <PaymentRecord>[],
  );
}
