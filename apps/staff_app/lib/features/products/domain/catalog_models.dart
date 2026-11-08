class Category {
  const Category({
    required this.id,
    required this.name,
  });

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
    return Product(
      id: json['id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQty: (json['stock_qty'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
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
