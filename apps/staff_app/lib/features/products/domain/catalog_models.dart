double _asDouble(Object? value, [double defaultValue = 0.0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int _asInt(Object? value, [int defaultValue = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class Category {
  const Category({required this.id, required this.name});

  final String id;
  final String name;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};
}

class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.stockQty,
    required this.isAvailable,
    this.imageUrl,
    this.description,
  });

  final String id;
  final String categoryId;
  final String name;
  final double price;
  final int stockQty;
  final bool isAvailable;
  final String? imageUrl;
  final String? description;

  bool get isLowStock => stockQty <= 10 && stockQty > 0;
  bool get isOutOfStock => stockQty <= 0;

  Product copyWith({
    String? id,
    String? categoryId,
    String? name,
    double? price,
    int? stockQty,
    bool? isAvailable,
    String? imageUrl,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      stockQty: stockQty ?? this.stockQty,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final int qty = _asInt(json['stock_qty'], 50);
    final bool available =
        json['is_available'] as bool? ??
        json['available_for_sale'] as bool? ??
        true;
    return Product(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: _asDouble(json['price']),
      stockQty: qty,
      isAvailable: available,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'category_id': categoryId,
    'name': name,
    'price': price,
    'stock_qty': stockQty,
    'is_available': isAvailable,
    'image_url': imageUrl,
    'description': description,
  };
}
