class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.orderId,
    required this.kind,
    required this.amount,
    required this.recordedByUserId,
    required this.recordedAt,
    this.methodCode,
    this.referenceCode,
  });

  final String id;
  final String orderId;
  final String kind;
  final double amount;
  final String? methodCode;
  final String? referenceCode;
  final String recordedByUserId;
  final DateTime recordedAt;

  String get methodLabel => methodCode ?? (kind == 'ADVANCE' ? 'ANTICIPO' : 'OTRO');

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      kind: json['kind'] as String? ?? 'COLLECTION',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      methodCode: json['method_code'] as String?,
      referenceCode: json['reference_code'] as String?,
      recordedByUserId: json['recorded_by_user_id'] as String? ?? '',
      recordedAt: json['recorded_at'] != null
          ? DateTime.tryParse(json['recorded_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class OrderPaymentSummary {
  const OrderPaymentSummary({
    required this.orderId,
    required this.orderTotal,
    required this.totalPaid,
    required this.balance,
    required this.isSettled,
    required this.payments,
  });

  final String orderId;
  final double orderTotal;
  final double totalPaid;
  final double balance;
  final bool isSettled;
  final List<PaymentRecord> payments;

  factory OrderPaymentSummary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawPayments =
        json['payments'] as List<dynamic>? ?? <dynamic>[];
    final List<PaymentRecord> payments = rawPayments
        .map((dynamic item) => PaymentRecord.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderPaymentSummary(
      orderId: json['order_id'] as String? ?? '',
      orderTotal: (json['order_total'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      isSettled: json['is_settled'] as bool? ?? false,
      payments: payments,
    );
  }
}
