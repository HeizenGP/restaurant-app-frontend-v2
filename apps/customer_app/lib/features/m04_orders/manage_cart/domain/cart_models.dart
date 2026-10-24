import 'package:flutter/foundation.dart';

@immutable
final class CartProductSnapshot {
  const CartProductSnapshot({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.unitPriceCents,
  });

  final String id;
  final String categoryId;
  final String name;
  final int unitPriceCents;
}

@immutable
final class CartItem {
  const CartItem({required this.product, required this.quantity})
    : assert(quantity > 0);

  final CartProductSnapshot product;
  final int quantity;

  int get subtotalCents => product.unitPriceCents * quantity;

  CartItem copyWith({CartProductSnapshot? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

@immutable
final class CartState {
  factory CartState(Iterable<CartItem> items) {
    return CartState._(List<CartItem>.unmodifiable(items));
  }

  const CartState._(this.items);

  const CartState.empty() : items = const <CartItem>[];

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get totalQuantity {
    return items.fold<int>(0, (int total, CartItem item) {
      return total + item.quantity;
    });
  }

  int get subtotalCents {
    return items.fold<int>(0, (int total, CartItem item) {
      return total + item.subtotalCents;
    });
  }

  CartItem? itemFor(String productId) {
    for (final CartItem item in items) {
      if (item.product.id == productId) return item;
    }
    return null;
  }
}
