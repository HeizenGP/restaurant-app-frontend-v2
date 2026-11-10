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
    this.tableAccountId,
  });

  final String id;
  final String orderId;
  final String kind;
  final double amount;
  final String? methodCode;
  final String? referenceCode;
  final String? tableAccountId;
  final String recordedByUserId;
  final DateTime recordedAt;

  String get methodLabel =>
      methodCode ?? (kind == 'ADVANCE' ? 'ANTICIPO' : 'OTRO');

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      kind: json['kind'] as String? ?? 'COLLECTION',
      amount: _paymentDouble(json['amount']),
      methodCode: json['method_code'] as String?,
      referenceCode: json['reference_code'] as String?,
      tableAccountId: json['table_account_id'] as String?,
      recordedByUserId: json['recorded_by_user_id'] as String? ?? '',
      recordedAt: json['recorded_at'] != null
          ? DateTime.tryParse(json['recorded_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class TableAccountLine {
  const TableAccountLine({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  factory TableAccountLine.fromJson(Map<String, dynamic> json) =>
      TableAccountLine(
        productName: json['product_name'] as String? ?? 'Producto',
        quantity: _paymentInt(json['quantity']),
        unitPrice: _paymentDouble(json['unit_price']),
        subtotal: _paymentDouble(json['subtotal']),
      );
}

class TableAccountOrder {
  const TableAccountOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.paidAmount,
    required this.balance,
    required this.lines,
  });

  final String id;
  final String status;
  final double totalAmount;
  final double paidAmount;
  final double balance;
  final List<TableAccountLine> lines;

  factory TableAccountOrder.fromJson(Map<String, dynamic> json) =>
      TableAccountOrder(
        id: json['id'] as String? ?? '',
        status: json['status'] as String? ?? '',
        totalAmount: _paymentDouble(json['total_amount']),
        paidAmount: _paymentDouble(json['paid_amount']),
        balance: _paymentDouble(json['balance']),
        lines: ((json['lines'] as List<dynamic>?) ?? <dynamic>[])
            .map(
              (dynamic line) =>
                  TableAccountLine.fromJson(line as Map<String, dynamic>),
            )
            .toList(growable: false),
      );
}

class TableAccountSummary {
  const TableAccountSummary({
    required this.id,
    required this.tableId,
    required this.tableCode,
    required this.status,
    required this.totalAmount,
    required this.advanceAmount,
    required this.paidAmount,
    required this.balance,
    required this.orders,
  });

  final String id;
  final String tableId;
  final String tableCode;
  final String status;
  final double totalAmount;
  final double advanceAmount;
  final double paidAmount;
  final double balance;
  final List<TableAccountOrder> orders;

  factory TableAccountSummary.fromJson(Map<String, dynamic> json) =>
      TableAccountSummary(
        id: json['id'] as String? ?? '',
        tableId: json['table_id'] as String? ?? '',
        tableCode: json['table_code'] as String? ?? '',
        status: json['status'] as String? ?? '',
        totalAmount: _paymentDouble(json['total_amount']),
        advanceAmount: _paymentDouble(json['advance_amount']),
        paidAmount: _paymentDouble(json['paid_amount']),
        balance: _paymentDouble(json['balance']),
        orders: ((json['orders'] as List<dynamic>?) ?? <dynamic>[])
            .map(
              (dynamic order) =>
                  TableAccountOrder.fromJson(order as Map<String, dynamic>),
            )
            .toList(growable: false),
      );
}

double _paymentDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _paymentInt(Object? value, [int defaultValue = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
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
        .map(
          (dynamic item) =>
              PaymentRecord.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return OrderPaymentSummary(
      orderId: json['order_id'] as String? ?? '',
      orderTotal: _paymentDouble(json['order_total'] ?? json['total_amount']),
      totalPaid: _paymentDouble(json['total_paid'] ?? json['paid_amount']),
      balance: _paymentDouble(json['balance']),
      isSettled: json['is_settled'] as bool? ?? false,
      payments: payments,
    );
  }
}

class CashRegisterSession {
  const CashRegisterSession({
    required this.id,
    required this.openedAt,
    required this.openedByUserName,
    required this.initialAmount,
    this.closedAt,
    this.closedByUserName,
    this.finalAmount,
    this.realAmount,
    this.difference,
    this.openingNotes,
    this.closingNotes,
    this.isOpen = true,
  });

  final String id;
  final DateTime openedAt;
  final String openedByUserName;
  final double initialAmount;
  final DateTime? closedAt;
  final String? closedByUserName;
  final double? finalAmount;
  final double? realAmount;
  final double? difference;
  final String? openingNotes;
  final String? closingNotes;
  final bool isOpen;

  CashRegisterSession copyWith({
    String? id,
    DateTime? openedAt,
    String? openedByUserName,
    double? initialAmount,
    DateTime? closedAt,
    String? closedByUserName,
    double? finalAmount,
    double? realAmount,
    double? difference,
    String? openingNotes,
    String? closingNotes,
    bool? isOpen,
  }) {
    return CashRegisterSession(
      id: id ?? this.id,
      openedAt: openedAt ?? this.openedAt,
      openedByUserName: openedByUserName ?? this.openedByUserName,
      initialAmount: initialAmount ?? this.initialAmount,
      closedAt: closedAt ?? this.closedAt,
      closedByUserName: closedByUserName ?? this.closedByUserName,
      finalAmount: finalAmount ?? this.finalAmount,
      realAmount: realAmount ?? this.realAmount,
      difference: difference ?? this.difference,
      openingNotes: openingNotes ?? this.openingNotes,
      closingNotes: closingNotes ?? this.closingNotes,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  factory CashRegisterSession.fromJson(Map<String, dynamic> json) {
    return CashRegisterSession(
      id: json['id'] as String? ?? '',
      openedAt:
          DateTime.tryParse(json['opened_at'] as String? ?? '') ??
          DateTime.now(),
      openedByUserName: json['opened_by_user_name'] as String? ?? 'Cajero',
      initialAmount: _paymentDouble(json['initial_amount']),
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'] as String)
          : null,
      closedByUserName: json['closed_by_user_name'] as String?,
      finalAmount: json['final_amount'] != null
          ? _paymentDouble(json['final_amount'])
          : null,
      realAmount: json['real_amount'] != null
          ? _paymentDouble(json['real_amount'])
          : null,
      difference: json['difference'] != null
          ? _paymentDouble(json['difference'])
          : null,
      openingNotes: json['opening_notes'] as String?,
      closingNotes: json['closing_notes'] as String?,
      isOpen: json['is_open'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'opened_at': openedAt.toIso8601String(),
    'opened_by_user_name': openedByUserName,
    'initial_amount': initialAmount,
    'closed_at': closedAt?.toIso8601String(),
    'closed_by_user_name': closedByUserName,
    'final_amount': finalAmount,
    'real_amount': realAmount,
    'difference': difference,
    'opening_notes': openingNotes,
    'closing_notes': closingNotes,
    'is_open': isOpen,
  };
}
