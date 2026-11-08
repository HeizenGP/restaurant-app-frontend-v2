import '../../../core/network/api_client.dart';
import '../../products/domain/catalog_models.dart';
import '../domain/inventory_models.dart';

class InventoryRepository {
  const InventoryRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Product>> getProducts() async {
    final dynamic response = await apiClient.get('/catalog/products');
    if (response is! List<dynamic>) return <Product>[];
    return response
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> adjustStock(String productId, int newQuantity) async {
    final dynamic response = await apiClient.put(
      '/catalog/products/$productId/stock',
      body: <String, dynamic>{'quantity': newQuantity},
      requiresAuth: true,
    );
    return Product.fromJson(response as Map<String, dynamic>);
  }

  Future<List<StockMovement>> getMovements({int limit = 100}) async {
    final dynamic response = await apiClient.get(
      '/catalog/stock/movements',
      queryParameters: <String, dynamic>{'limit': limit},
    );
    if (response is! List<dynamic>) return <StockMovement>[];
    return response
        .map((dynamic item) =>
            StockMovement.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
