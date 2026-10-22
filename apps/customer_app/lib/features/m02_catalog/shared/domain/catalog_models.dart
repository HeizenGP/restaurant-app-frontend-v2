final class CatalogCategory {
  const CatalogCategory({required this.id, required this.name});

  final String id;
  final String name;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogCategory && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}

final class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.priceCents,
    required this.availableForSale,
  });

  final String id;
  final String categoryId;
  final String name;
  final int priceCents;
  final bool availableForSale;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CatalogProduct &&
            other.id == id &&
            other.categoryId == categoryId &&
            other.name == name &&
            other.priceCents == priceCents &&
            other.availableForSale == availableForSale;
  }

  @override
  int get hashCode {
    return Object.hash(id, categoryId, name, priceCents, availableForSale);
  }
}
