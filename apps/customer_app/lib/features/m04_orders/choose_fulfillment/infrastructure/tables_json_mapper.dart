import '../application/fulfillment_contracts.dart';
import '../domain/fulfillment_models.dart';

abstract final class TablesJsonMapper {
  static List<RestaurantTable> decodeTables(Object? payload) {
    if (payload is! List<Object?>) throw _malformed();
    try {
      return List<RestaurantTable>.unmodifiable(
        payload.map<RestaurantTable>(_decodeTable),
      );
    } on TablesFailure {
      rethrow;
    } on Object {
      throw _malformed();
    }
  }

  static RestaurantTable _decodeTable(Object? payload) {
    if (payload is! Map<String, Object?>) throw _malformed();
    final Object? rawId = payload['id'];
    final Object? rawCode = payload['code'];
    final Object? rawAreaLabel = payload['area_label'];
    final Object? rawOccupied = payload['is_occupied'];
    if (rawId is! String ||
        rawId.trim().isEmpty ||
        rawCode is! String ||
        rawCode.trim().isEmpty ||
        (rawAreaLabel != null && rawAreaLabel is! String) ||
        rawOccupied is! bool) {
      throw _malformed();
    }
    final String? areaLabel = switch (rawAreaLabel) {
      final String value when value.trim().isNotEmpty => value.trim(),
      _ => null,
    };
    return RestaurantTable(
      id: rawId.trim(),
      code: rawCode.trim(),
      areaLabel: areaLabel,
      isOccupied: rawOccupied,
    );
  }

  static TablesFailure _malformed() {
    return const TablesFailure(
      TablesFailureKind.malformedResponse,
      'El servidor devolvió mesas no válidas.',
    );
  }
}
