import '../application/payment_status_contracts.dart';
import '../domain/payment_models.dart';

abstract final class PaymentStatusJsonMapper {
  static AdvanceSummary decodeAdvance(Object? payload) {
    try {
      final Map<String, Object?> map = _object(payload, 'advance');
      return AdvanceSummary(
        orderId: _requiredString(map, 'order_id'),
        orderStatus: _requiredString(map, 'order_status'),
        totalAmount: _decimalString(map, 'total_amount'),
        requiredAmount: _decimalString(map, 'required_amount'),
        verifiedAmount: _decimalString(map, 'verified_amount'),
        remainingAmount: _decimalString(map, 'remaining_amount'),
        verifiedAt: _nullableDateTime(map, 'verified_at'),
      );
    } on PaymentStatusFailure {
      rethrow;
    } on Object {
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.malformedResponse,
        'El servidor devolvió un anticipo no válido.',
      );
    }
  }

  static PaymentSummary decodePayments(Object? payload) {
    try {
      final Map<String, Object?> map = _object(payload, 'payments');
      final String paymentStatus = _requiredString(map, 'payment_status');
      if (paymentStatus != 'UNPAID' &&
          paymentStatus != 'PARTIAL' &&
          paymentStatus != 'PAID') {
        throw const FormatException('invalid payment status');
      }
      final Object? rawPayments = map['payments'];
      if (rawPayments is! List<Object?>) {
        throw const FormatException('payments must be a list');
      }
      final List<PaymentRecord> payments = rawPayments
          .map<PaymentRecord>(_decodePayment)
          .toList(growable: false);
      return PaymentSummary(
        orderId: _requiredString(map, 'order_id'),
        orderStatus: _requiredString(map, 'order_status'),
        totalAmount: _decimalString(map, 'total_amount'),
        paidAmount: _decimalString(map, 'paid_amount'),
        balance: _decimalString(map, 'balance'),
        paymentStatus: paymentStatus,
        payments: List<PaymentRecord>.unmodifiable(payments),
      );
    } on PaymentStatusFailure {
      rethrow;
    } on Object {
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.malformedResponse,
        'El servidor devolvió pagos no válidos.',
      );
    }
  }

  static PaymentRecord _decodePayment(Object? payload) {
    final Map<String, Object?> map = _object(payload, 'payment');
    final String kind = _requiredString(map, 'kind');
    if (kind != 'ADVANCE' && kind != 'COLLECTION') {
      throw const FormatException('invalid payment kind');
    }
    return PaymentRecord(
      id: _requiredString(map, 'id'),
      kind: kind,
      amount: _decimalString(map, 'amount'),
      methodCode: _nullableString(map, 'method_code'),
      referenceCode: _nullableString(map, 'reference_code'),
      recordedByUserId: _requiredString(map, 'recorded_by_user_id'),
      recordedAt: _dateTime(map, 'recorded_at'),
    );
  }

  static Map<String, Object?> _object(Object? value, String name) {
    if (value is! Map<String, Object?>) {
      throw FormatException('$name must be an object');
    }
    return value;
  }

  static String _requiredString(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string');
    }
    return value;
  }

  static String? _nullableString(Map<String, Object?> map, String key) {
    if (!map.containsKey(key)) throw FormatException('$key is missing');
    final Object? value = map[key];
    if (value == null) return null;
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be null or a non-empty string');
    }
    return value;
  }

  static String _decimalString(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is! String ||
        !RegExp(r'^(?:0|[1-9]\d*)(?:\.\d+)?$').hasMatch(value)) {
      throw FormatException('$key must be a decimal string');
    }
    return value;
  }

  static DateTime _dateTime(Map<String, Object?> map, String key) {
    final String value = _requiredString(map, key);
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('$key must be ISO-8601');
    return parsed;
  }

  static DateTime? _nullableDateTime(Map<String, Object?> map, String key) {
    if (!map.containsKey(key)) throw FormatException('$key is missing');
    final Object? value = map[key];
    if (value == null) return null;
    if (value is! String) throw FormatException('$key must be ISO-8601');
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) throw FormatException('$key must be ISO-8601');
    return parsed;
  }
}
