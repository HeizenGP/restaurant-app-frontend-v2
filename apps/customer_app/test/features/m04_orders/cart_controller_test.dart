import 'package:customer_app/features/m04_orders/manage_cart/application/cart_controller.dart';
import 'package:customer_app/features/m04_orders/manage_cart/domain/cart_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds, merges and calculates local subtotals in cents', () {
    final CartController controller = CartController();
    addTearDown(controller.dispose);

    expect(controller.addProduct(productOne, quantity: 2), isTrue);
    expect(controller.addProduct(productOne), isTrue);
    expect(controller.addProduct(productTwo), isTrue);

    expect(controller.state.items, hasLength(2));
    expect(controller.state.itemFor(productOne.id)?.quantity, 3);
    expect(controller.state.totalQuantity, 4);
    expect(controller.state.subtotalCents, 4150);
  });

  test('rejects invalid quantities and never decrements below one', () {
    final CartController controller = CartController();
    addTearDown(controller.dispose);

    expect(controller.addProduct(productOne, quantity: 0), isFalse);
    expect(controller.state.isEmpty, isTrue);

    controller.addProduct(productOne);
    expect(controller.decrement(productOne.id), isFalse);
    expect(controller.setQuantity(productOne.id, 0), isFalse);
    expect(controller.state.itemFor(productOne.id)?.quantity, 1);
  });

  test('updates quantities and removes only an existing product', () {
    final CartController controller = CartController();
    addTearDown(controller.dispose);
    controller.addProduct(productOne);

    expect(controller.increment(productOne.id), isTrue);
    expect(controller.state.itemFor(productOne.id)?.quantity, 2);
    expect(controller.decrement(productOne.id), isTrue);
    expect(controller.state.itemFor(productOne.id)?.quantity, 1);
    expect(controller.remove('missing'), isFalse);
    expect(controller.remove(productOne.id), isTrue);
    expect(controller.state.isEmpty, isTrue);
  });
}

const CartProductSnapshot productOne = CartProductSnapshot(
  id: 'product-one',
  categoryId: 'category-one',
  name: 'Chaufa especial',
  unitPriceCents: 1200,
);

const CartProductSnapshot productTwo = CartProductSnapshot(
  id: 'product-two',
  categoryId: 'category-two',
  name: 'Té jazmín',
  unitPriceCents: 550,
);
