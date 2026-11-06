import '../../choose_fulfillment/domain/fulfillment_models.dart';

final class CreateOrderItem {
  const CreateOrderItem({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CreateOrderItem &&
            other.productId == productId &&
            other.quantity == quantity;
  }

  @override
  int get hashCode => Object.hash(productId, quantity);
}

final class CreateOrderCommand {
  factory CreateOrderCommand({
    required Iterable<CreateOrderItem> items,
    required FulfillmentDraft fulfillment,
  }) {
    final Map<String, int> quantitiesByProduct = <String, int>{};
    for (final CreateOrderItem item in items) {
      final String productId = item.productId.trim();
      if (productId.isEmpty ||
          item.quantity < 1 ||
          item.quantity > 2147483647) {
        throw ArgumentError.value(
          item,
          'items',
          'Cada producto requiere id y una cantidad válida.',
        );
      }
      final int quantity =
          (quantitiesByProduct[productId] ?? 0) + item.quantity;
      if (quantity > 2147483647) {
        throw ArgumentError.value(
          quantity,
          'items',
          'La cantidad consolidada excede el límite permitido.',
        );
      }
      quantitiesByProduct[productId] = quantity;
    }
    final List<CreateOrderItem> normalized =
        quantitiesByProduct.entries
            .map(
              (MapEntry<String, int> entry) =>
                  CreateOrderItem(productId: entry.key, quantity: entry.value),
            )
            .toList(growable: false)
          ..sort((CreateOrderItem left, CreateOrderItem right) {
            return left.productId.compareTo(right.productId);
          });
    if (normalized.isEmpty || normalized.length > 100) {
      throw ArgumentError.value(
        normalized.length,
        'items',
        'Debe contener entre 1 y 100 productos.',
      );
    }
    _validateFulfillment(fulfillment);
    return CreateOrderCommand._(
      List<CreateOrderItem>.unmodifiable(normalized),
      fulfillment,
    );
  }

  const CreateOrderCommand._(this.items, this.fulfillment);

  final List<CreateOrderItem> items;
  final FulfillmentDraft fulfillment;

  static void _validateFulfillment(FulfillmentDraft fulfillment) {
    final String tableId = fulfillment.tableId?.trim() ?? '';
    final String contactName = fulfillment.contactName?.trim() ?? '';
    final String contactPhone = fulfillment.contactPhone?.trim() ?? '';
    final String deliveryAddress = fulfillment.deliveryAddress?.trim() ?? '';
    switch (fulfillment.mode) {
      case FulfillmentMode.local:
        if (tableId.isEmpty ||
            contactName.isNotEmpty ||
            contactPhone.isNotEmpty ||
            deliveryAddress.isNotEmpty) {
          throw ArgumentError.value(
            fulfillment,
            'fulfillment',
            'El consumo local requiere únicamente una mesa.',
          );
        }
        return;
      case FulfillmentMode.pickup:
        if (tableId.isNotEmpty ||
            deliveryAddress.isNotEmpty ||
            contactName.isEmpty ||
            contactName.length > 120 ||
            contactPhone.isEmpty ||
            contactPhone.length > 30) {
          throw ArgumentError.value(
            fulfillment,
            'fulfillment',
            'El recojo requiere nombre y teléfono válidos.',
          );
        }
        return;
      case FulfillmentMode.delivery:
        if (tableId.isNotEmpty ||
            deliveryAddress.isEmpty ||
            deliveryAddress.length > 1000 ||
            contactName.isEmpty ||
            contactName.length > 120 ||
            contactPhone.isEmpty ||
            contactPhone.length > 30) {
          throw ArgumentError.value(
            fulfillment,
            'fulfillment',
            'El delivery requiere dirección, nombre y teléfono válidos.',
          );
        }
        return;
    }
  }

  int get totalQuantity {
    return items.fold<int>(
      0,
      (int total, CreateOrderItem item) => total + item.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateOrderCommand || fulfillment != other.fulfillment) {
      return false;
    }
    if (items.length != other.items.length) return false;
    for (int index = 0; index < items.length; index += 1) {
      if (items[index] != other.items[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(fulfillment, Object.hashAll(items));
}

final class OrderLineSnapshot {
  const OrderLineSnapshot({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final String unitPrice;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OrderLineSnapshot &&
            other.productId == productId &&
            other.productName == productName &&
            other.quantity == quantity &&
            other.unitPrice == unitPrice;
  }

  @override
  int get hashCode {
    return Object.hash(productId, productName, quantity, unitPrice);
  }
}

final class OrderSnapshot {
  const OrderSnapshot({
    required this.id,
    required this.modality,
    required this.channel,
    required this.status,
    required this.totalAmount,
    required this.lines,
    required this.createdAt,
    this.tableId,
    this.deliveryAddress,
    this.contactName,
    this.contactPhone,
    this.decidedAt,
    this.tableVerifiedAt,
  });

  final String id;
  final FulfillmentMode modality;
  final String channel;
  final String status;
  final String? tableId;
  final String? deliveryAddress;
  final String? contactName;
  final String? contactPhone;
  final String totalAmount;
  final List<OrderLineSnapshot> lines;
  final DateTime createdAt;
  final DateTime? decidedAt;
  final DateTime? tableVerifiedAt;

  bool get isRequested => status == 'REQUESTED';

  OrderSnapshot copyWith({
    String? id,
    FulfillmentMode? modality,
    String? channel,
    String? status,
    String? totalAmount,
    List<OrderLineSnapshot>? lines,
    DateTime? createdAt,
    String? tableId,
    String? deliveryAddress,
    String? contactName,
    String? contactPhone,
    DateTime? decidedAt,
    DateTime? tableVerifiedAt,
  }) {
    return OrderSnapshot(
      id: id ?? this.id,
      modality: modality ?? this.modality,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      lines: lines ?? this.lines,
      createdAt: createdAt ?? this.createdAt,
      tableId: tableId ?? this.tableId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      decidedAt: decidedAt ?? this.decidedAt,
      tableVerifiedAt: tableVerifiedAt ?? this.tableVerifiedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrderSnapshot ||
        id != other.id ||
        modality != other.modality ||
        channel != other.channel ||
        status != other.status ||
        tableId != other.tableId ||
        deliveryAddress != other.deliveryAddress ||
        contactName != other.contactName ||
        contactPhone != other.contactPhone ||
        totalAmount != other.totalAmount ||
        createdAt != other.createdAt ||
        decidedAt != other.decidedAt ||
        tableVerifiedAt != other.tableVerifiedAt ||
        lines.length != other.lines.length) {
      return false;
    }
    for (int index = 0; index < lines.length; index += 1) {
      if (lines[index] != other.lines[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      modality,
      channel,
      status,
      tableId,
      deliveryAddress,
      contactName,
      contactPhone,
      totalAmount,
      Object.hashAll(lines),
      createdAt,
      decidedAt,
      tableVerifiedAt,
    );
  }
}
