import 'package:customer_app/features/m02_catalog/shared/application/catalog_contracts.dart';
import 'package:customer_app/features/m02_catalog/shared/infrastructure/catalog_json_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/catalog_fakes.dart';

void main() {
  test('decodes the exact public category contract', () {
    final categories = CatalogJsonMapper.decodeCategories(<Object?>[
      <String, Object?>{'id': categoryOneId, 'name': 'Arroces'},
      <String, Object?>{'id': categoryTwoId, 'name': 'Bebidas'},
    ]);

    expect(categories, hasLength(2));
    expect(categories.first.id, categoryOneId);
    expect(categories.first.name, 'Arroces');
    expect(() => categories.add(categoryOne), throwsA(isA<UnsupportedError>()));
  });

  test('converts decimal strings to cents without floating point', () {
    final products = CatalogJsonMapper.decodeProducts(<Object?>[
      _productJson(price: '22.50'),
      <String, Object?>{..._productJson(price: '7.5'), 'id': productTwoId},
    ], expectedCategoryId: categoryOneId);

    expect(products[0].priceCents, 2250);
    expect(products[1].priceCents, 750);
    expect(products[0].availableForSale, isTrue);
  });

  test(
    'rejects numeric prices because the backend contract is decimal text',
    () {
      expect(
        () => CatalogJsonMapper.decodeProducts(<Object?>[
          _productJson(price: 22.5),
        ], expectedCategoryId: categoryOneId),
        throwsA(_malformedFailure()),
      );
    },
  );

  test('rejects malformed identifiers and cross-category products', () {
    expect(
      () => CatalogJsonMapper.decodeCategories(<Object?>[
        <String, Object?>{'id': 'not-a-uuid', 'name': 'Arroces'},
      ]),
      throwsA(_malformedFailure()),
    );
    expect(
      () => CatalogJsonMapper.decodeProducts(<Object?>[
        <String, Object?>{
          ..._productJson(price: '22.50'),
          'category_id': categoryTwoId,
        },
      ], expectedCategoryId: categoryOneId),
      throwsA(_malformedFailure()),
    );
  });
}

Map<String, Object?> _productJson({required Object price}) {
  return <String, Object?>{
    'id': productOneId,
    'category_id': categoryOneId,
    'name': 'Chaufa especial',
    'price': price,
    'available_for_sale': true,
  };
}

Matcher _malformedFailure() {
  return isA<CatalogFailure>().having(
    (CatalogFailure value) => value.kind,
    'kind',
    CatalogFailureKind.malformedResponse,
  );
}
