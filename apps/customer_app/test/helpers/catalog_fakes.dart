import 'package:customer_app/features/m02_catalog/shared/application/catalog_contracts.dart';
import 'package:customer_app/features/m02_catalog/shared/domain/catalog_models.dart';

const String categoryOneId = '11111111-1111-4111-8111-111111111111';
const String categoryTwoId = '22222222-2222-4222-8222-222222222222';
const String productOneId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const String productTwoId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

const CatalogCategory categoryOne = CatalogCategory(
  id: categoryOneId,
  name: 'Arroces',
);
const CatalogCategory categoryTwo = CatalogCategory(
  id: categoryTwoId,
  name: 'Bebidas',
);
const CatalogProduct productOne = CatalogProduct(
  id: productOneId,
  categoryId: categoryOneId,
  name: 'Chaufa especial',
  priceCents: 2425,
  availableForSale: true,
);
const CatalogProduct productTwo = CatalogProduct(
  id: productTwoId,
  categoryId: categoryTwoId,
  name: 'Té',
  priceCents: 200,
  availableForSale: false,
);

final class FakeCatalogRepository implements CatalogRepository {
  List<CatalogCategory> categories = <CatalogCategory>[
    categoryOne,
    categoryTwo,
  ];
  Map<String, List<CatalogProduct>> products = <String, List<CatalogProduct>>{
    categoryOneId: <CatalogProduct>[productOne],
    categoryTwoId: <CatalogProduct>[productTwo],
  };
  Future<List<CatalogCategory>> Function()? categoriesHandler;
  Future<List<CatalogProduct>> Function(String categoryId)? productsHandler;
  int categoryCalls = 0;
  final List<String> productCalls = <String>[];

  @override
  Future<List<CatalogCategory>> listCategories() async {
    categoryCalls += 1;
    final Future<List<CatalogCategory>> Function()? handler = categoriesHandler;
    if (handler != null) return handler();
    return categories;
  }

  @override
  Future<List<CatalogProduct>> listProducts(String categoryId) async {
    productCalls.add(categoryId);
    final Future<List<CatalogProduct>> Function(String categoryId)? handler =
        productsHandler;
    if (handler != null) return handler(categoryId);
    return products[categoryId] ?? const <CatalogProduct>[];
  }
}
