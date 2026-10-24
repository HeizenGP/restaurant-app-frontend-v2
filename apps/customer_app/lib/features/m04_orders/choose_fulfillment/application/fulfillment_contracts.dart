import '../domain/fulfillment_models.dart';

abstract interface class TablesRepository {
  Future<List<RestaurantTable>> listTables();
}

enum TablesFailureKind {
  timeout,
  network,
  validation,
  server,
  malformedResponse,
}

final class TablesFailure implements Exception {
  const TablesFailure(this.kind, this.message);

  final TablesFailureKind kind;
  final String message;

  @override
  String toString() => 'TablesFailure($kind, $message)';
}

abstract final class FulfillmentValidators {
  static String? contactName(String? value) {
    return _requiredWithin(
      value,
      maximumLength: 120,
      emptyMessage: 'Ingresa el nombre de contacto.',
      longMessage: 'Usa hasta 120 caracteres.',
    );
  }

  static String? contactPhone(String? value) {
    return _requiredWithin(
      value,
      maximumLength: 30,
      emptyMessage: 'Ingresa el celular de contacto.',
      longMessage: 'Usa hasta 30 caracteres.',
    );
  }

  static String? deliveryAddress(String? value) {
    return _requiredWithin(
      value,
      maximumLength: 1000,
      emptyMessage: 'Ingresa la dirección de entrega.',
      longMessage: 'Usa hasta 1000 caracteres.',
    );
  }

  static String? _requiredWithin(
    String? value, {
    required int maximumLength,
    required String emptyMessage,
    required String longMessage,
  }) {
    final String normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return emptyMessage;
    if (normalized.length > maximumLength) return longMessage;
    return null;
  }
}
