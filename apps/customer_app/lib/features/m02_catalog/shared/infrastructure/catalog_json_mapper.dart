import '../application/catalog_contracts.dart';
import '../domain/catalog_models.dart';

abstract final class CatalogJsonMapper {
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  static final RegExp _pricePattern = RegExp(
    r'^(0|[1-9][0-9]{0,9})(?:\.([0-9]{1,2}))?$',
  );

  static List<CatalogCategory> decodeCategories(Object? value) {
    if (value is! List<Object?>) throw _malformed();

    try {
      final Set<String> ids = <String>{};
      final List<CatalogCategory> categories = value
          .map((Object? item) {
            final Map<String, Object?> json = _object(item);
            final String id = _uuid(json['id']);
            if (!ids.add(id)) throw const FormatException('duplicate category');
            return CatalogCategory(id: id, name: _name(json['name']));
          })
          .toList(growable: false);
      return List<CatalogCategory>.unmodifiable(categories);
    } on CatalogFailure {
      rethrow;
    } on Object {
      throw _malformed();
    }
  }

  static List<CatalogProduct> decodeProducts(
    Object? value, {
    required String expectedCategoryId,
  }) {
    if (value is! List<Object?>) throw _malformed();

    try {
      final Set<String> ids = <String>{};
      final List<CatalogProduct> products = value
          .map((Object? item) {
            final Map<String, Object?> json = _object(item);
            final String id = _uuid(json['id']);
            final String categoryId = _uuid(json['category_id']);
            if (!ids.add(id) || categoryId != expectedCategoryId) {
              throw const FormatException('inconsistent product');
            }
            return CatalogProduct(
              id: id,
              categoryId: categoryId,
              name: _name(json['name']),
              priceCents: _priceCents(json['price']),
              availableForSale: json['available_for_sale']! as bool,
            );
          })
          .toList(growable: false);
      return List<CatalogProduct>.unmodifiable(products);
    } on CatalogFailure {
      rethrow;
    } on Object {
      throw _malformed();
    }
  }

  static Map<String, Object?> _object(Object? value) {
    if (value is! Map<String, Object?>) throw const FormatException('object');
    return value;
  }

  static String _uuid(Object? value) {
    if (value is! String || !_uuidPattern.hasMatch(value)) {
      throw const FormatException('uuid');
    }
    return value;
  }

  static String _name(Object? value) {
    if (value is! String || value.isEmpty || value.trim() != value) {
      throw const FormatException('name');
    }
    return value;
  }

  static int _priceCents(Object? value) {
    if (value is! String) throw const FormatException('price type');
    final RegExpMatch? match = _pricePattern.firstMatch(value);
    if (match == null) throw const FormatException('price format');

    final int units = int.parse(match.group(1)!);
    final String decimals = (match.group(2) ?? '').padRight(2, '0');
    final int cents = decimals.isEmpty ? 0 : int.parse(decimals);
    return units * 100 + cents;
  }

  static CatalogFailure _malformed() {
    return const CatalogFailure(
      CatalogFailureKind.malformedResponse,
      'El servidor devolvió un catálogo no válido.',
    );
  }
}
