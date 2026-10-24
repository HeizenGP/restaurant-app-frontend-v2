enum FulfillmentMode {
  local('LOCAL'),
  pickup('PICKUP'),
  delivery('DELIVERY');

  const FulfillmentMode(this.apiValue);

  final String apiValue;
}

final class RestaurantTable {
  const RestaurantTable({
    required this.id,
    required this.code,
    required this.areaLabel,
    required this.isOccupied,
  });

  final String id;
  final String code;
  final String? areaLabel;
  final bool isOccupied;

  bool get isAvailable => !isOccupied;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RestaurantTable &&
            other.id == id &&
            other.code == code &&
            other.areaLabel == areaLabel &&
            other.isOccupied == isOccupied;
  }

  @override
  int get hashCode => Object.hash(id, code, areaLabel, isOccupied);
}

final class FulfillmentDraft {
  const FulfillmentDraft._({
    required this.mode,
    this.tableId,
    this.contactName,
    this.contactPhone,
    this.deliveryAddress,
  });

  factory FulfillmentDraft.local({required String tableId}) {
    return FulfillmentDraft._(
      mode: FulfillmentMode.local,
      tableId: tableId.trim(),
    );
  }

  factory FulfillmentDraft.pickup({
    required String contactName,
    required String contactPhone,
  }) {
    return FulfillmentDraft._(
      mode: FulfillmentMode.pickup,
      contactName: contactName.trim(),
      contactPhone: contactPhone.trim(),
    );
  }

  factory FulfillmentDraft.delivery({
    required String deliveryAddress,
    required String contactName,
    required String contactPhone,
  }) {
    return FulfillmentDraft._(
      mode: FulfillmentMode.delivery,
      deliveryAddress: deliveryAddress.trim(),
      contactName: contactName.trim(),
      contactPhone: contactPhone.trim(),
    );
  }

  final FulfillmentMode mode;
  final String? tableId;
  final String? contactName;
  final String? contactPhone;
  final String? deliveryAddress;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FulfillmentDraft &&
            other.mode == mode &&
            other.tableId == tableId &&
            other.contactName == contactName &&
            other.contactPhone == contactPhone &&
            other.deliveryAddress == deliveryAddress;
  }

  @override
  int get hashCode {
    return Object.hash(
      mode,
      tableId,
      contactName,
      contactPhone,
      deliveryAddress,
    );
  }
}
