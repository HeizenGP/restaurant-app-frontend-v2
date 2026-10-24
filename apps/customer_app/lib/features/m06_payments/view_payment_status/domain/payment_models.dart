final class AdvanceSummary {
  const AdvanceSummary({
    required this.orderId,
    required this.orderStatus,
    required this.totalAmount,
    required this.requiredAmount,
    required this.verifiedAmount,
    required this.remainingAmount,
    this.verifiedAt,
  });

  final String orderId;
  final String orderStatus;
  final String totalAmount;
  final String requiredAmount;
  final String verifiedAmount;
  final String remainingAmount;
  final DateTime? verifiedAt;

  bool get isVerified => verifiedAt != null;
}

final class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.kind,
    required this.amount,
    required this.recordedByUserId,
    required this.recordedAt,
    this.methodCode,
    this.referenceCode,
  });

  final String id;
  final String kind;
  final String amount;
  final String? methodCode;
  final String? referenceCode;
  final String recordedByUserId;
  final DateTime recordedAt;
}

final class PaymentSummary {
  const PaymentSummary({
    required this.orderId,
    required this.orderStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.paymentStatus,
    required this.payments,
  });

  final String orderId;
  final String orderStatus;
  final String totalAmount;
  final String paidAmount;
  final String balance;
  final String paymentStatus;
  final List<PaymentRecord> payments;
}
