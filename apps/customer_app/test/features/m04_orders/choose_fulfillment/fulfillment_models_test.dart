import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_contracts.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('drafts preserve only fields allowed by their real mode', () {
    expect(
      FulfillmentDraft.local(tableId: ' table-1 '),
      FulfillmentDraft.local(tableId: 'table-1'),
    );
    expect(
      FulfillmentDraft.pickup(contactName: ' Ada ', contactPhone: ' 999 111 '),
      FulfillmentDraft.pickup(contactName: 'Ada', contactPhone: '999 111'),
    );
    expect(
      FulfillmentDraft.delivery(
        deliveryAddress: ' Calle 1 ',
        contactName: ' Ana ',
        contactPhone: ' 999 ',
      ).mode.apiValue,
      'DELIVERY',
    );
  });

  test('validators enforce trimmed backend field limits', () {
    expect(FulfillmentValidators.contactName('   '), isNotNull);
    expect(FulfillmentValidators.contactName(_repeat('a', 120)), isNull);
    expect(FulfillmentValidators.contactName(_repeat('a', 121)), isNotNull);
    expect(FulfillmentValidators.contactPhone('1'), isNull);
    expect(FulfillmentValidators.contactPhone(_repeat('1', 31)), isNotNull);
    expect(FulfillmentValidators.deliveryAddress('x'), isNull);
    expect(
      FulfillmentValidators.deliveryAddress(_repeat('x', 1001)),
      isNotNull,
    );
  });
}

String _repeat(String value, int times) =>
    List<String>.filled(times, value).join();
