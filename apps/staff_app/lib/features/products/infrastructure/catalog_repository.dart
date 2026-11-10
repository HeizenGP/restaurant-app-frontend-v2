import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/network/image_upload_service.dart';
import '../domain/catalog_models.dart';

class CatalogRepository {
  const CatalogRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Category>> getCategories() async {
    final dynamic response = await apiClient.get(
      '/catalog/categories',
      requiresAuth: false,
    );
    if (response is! List<dynamic>) return <Category>[];
    return response
        .map((dynamic item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Category> createCategory(String name) async {
    final dynamic response = await apiClient.post(
      '/catalog/categories',
      body: <String, String>{'name': name.trim()},
      requiresAuth: true,
    );
    return Category.fromJson(response as Map<String, dynamic>);
  }

  Future<Category> renameCategory(String categoryId, String name) async {
    final dynamic response = await apiClient.patch(
      '/catalog/categories/$categoryId',
      body: <String, String>{'name': name.trim()},
      requiresAuth: true,
    );
    return Category.fromJson(response as Map<String, dynamic>);
  }

  Future<List<Product>> getProducts({String? categoryId}) async {
    final Map<String, dynamic>? query = categoryId != null
        ? <String, dynamic>{'category_id': categoryId}
        : null;
    final dynamic response = await apiClient.get(
      '/catalog/products',
      queryParameters: query,
      requiresAuth: false,
    );
    if (response is! List<dynamic>) return <Product>[];
    return response
        .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> createProduct({
    required String categoryId,
    required String name,
    required double price,
    String? imageUrl,
    String? description,
  }) async {
    final dynamic response = await apiClient.post(
      '/catalog/products',
      body: <String, dynamic>{
        'category_id': categoryId,
        'name': name.trim(),
        'price': price,
        'image_url': imageUrl?.trim().isEmpty ?? true ? null : imageUrl!.trim(),
        'description': description?.trim().isEmpty ?? true
            ? null
            : description!.trim(),
      },
      requiresAuth: true,
    );
    return Product.fromJson(response as Map<String, dynamic>);
  }

  Future<Product> updateProduct(
    String productId, {
    String? categoryId,
    String? name,
    double? price,
    String? imageUrl,
    String? description,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (categoryId != null) body['category_id'] = categoryId;
    if (name != null) body['name'] = name.trim();
    if (price != null) body['price'] = price;
    if (imageUrl != null) {
      body['image_url'] = imageUrl.trim().isEmpty ? null : imageUrl.trim();
    }
    if (description != null) {
      body['description'] = description.trim().isEmpty
          ? null
          : description.trim();
    }

    final dynamic response = await apiClient.patch(
      '/catalog/products/$productId',
      body: body,
      requiresAuth: true,
    );
    return Product.fromJson(response as Map<String, dynamic>);
  }

  Future<Product> setProductStock(String productId, int quantity) async {
    final dynamic response = await apiClient.put(
      '/catalog/products/$productId/stock',
      body: <String, dynamic>{'quantity': quantity},
      requiresAuth: true,
    );
    return Product.fromJson(response as Map<String, dynamic>);
  }

  Future<Product> setProductAvailability(
    String productId,
    bool isAvailable,
  ) async {
    final dynamic response = await apiClient.patch(
      '/catalog/products/$productId/availability',
      body: <String, dynamic>{'is_available': isAvailable},
      requiresAuth: true,
    );
    return Product.fromJson(response as Map<String, dynamic>);
  }

  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final ImageUploadService service = ImageUploadService(apiClient: apiClient);
    return service.uploadImage(bytes: bytes, filename: filename);
  }
}
