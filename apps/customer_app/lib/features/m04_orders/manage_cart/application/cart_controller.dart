import 'package:flutter/foundation.dart';

import '../domain/cart_models.dart';

/// In-memory cart for the current app process.
///
/// It deliberately performs no HTTP calls, stock reservation or checkout.
final class CartController extends ChangeNotifier {
  CartState _state = const CartState.empty();
  bool _disposed = false;

  CartState get state => _state;

  bool addProduct(CartProductSnapshot product, {int quantity = 1}) {
    if (quantity < 1) return false;

    final List<CartItem> items = List<CartItem>.of(_state.items);
    final int index = items.indexWhere((CartItem item) {
      return item.product.id == product.id;
    });
    if (index == -1) {
      items.add(CartItem(product: product, quantity: quantity));
    } else {
      final CartItem current = items[index];
      items[index] = CartItem(
        product: product,
        quantity: current.quantity + quantity,
      );
    }
    _emit(CartState(items));
    return true;
  }

  bool setQuantity(String productId, int quantity) {
    if (quantity < 1) return false;
    final List<CartItem> items = List<CartItem>.of(_state.items);
    final int index = items.indexWhere((CartItem item) {
      return item.product.id == productId;
    });
    if (index == -1) return false;

    items[index] = items[index].copyWith(quantity: quantity);
    _emit(CartState(items));
    return true;
  }

  bool increment(String productId) {
    final CartItem? item = _state.itemFor(productId);
    return item != null && setQuantity(productId, item.quantity + 1);
  }

  bool decrement(String productId) {
    final CartItem? item = _state.itemFor(productId);
    return item != null &&
        item.quantity > 1 &&
        setQuantity(productId, item.quantity - 1);
  }

  bool remove(String productId) {
    final List<CartItem> items = List<CartItem>.of(_state.items);
    final int previousLength = items.length;
    items.removeWhere((CartItem item) => item.product.id == productId);
    if (items.length == previousLength) return false;
    _emit(CartState(items));
    return true;
  }

  void clear() {
    if (_state.isEmpty) return;
    _emit(const CartState.empty());
  }

  void _emit(CartState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
