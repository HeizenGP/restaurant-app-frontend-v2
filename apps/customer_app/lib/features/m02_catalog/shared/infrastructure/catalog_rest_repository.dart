import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../application/catalog_contracts.dart';
import '../domain/catalog_models.dart';
import 'catalog_json_mapper.dart';

final class CatalogRestRepository implements CatalogRepository {
  factory CatalogRestRepository({
    required Uri baseUri,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 15),
  }) {
    return CatalogRestRepository._(baseUri, client, requestTimeout);
  }

  const CatalogRestRepository._(
    this._baseUri,
    this._client,
    this.requestTimeout,
  );

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<List<CatalogCategory>> listCategories() async {
    final http.Response response = await _get(<String>[
      'catalog',
      'categories',
    ]);
    if (response.statusCode != 200) throw _failureFor(response.statusCode);
    return CatalogJsonMapper.decodeCategories(_decodeJson(response));
  }

  @override
  Future<List<CatalogProduct>> listProducts(String categoryId) async {
    final http.Response response = await _get(<String>[
      'catalog',
      'categories',
      categoryId,
      'products',
    ]);
    if (response.statusCode != 200) throw _failureFor(response.statusCode);
    return CatalogJsonMapper.decodeProducts(
      _decodeJson(response),
      expectedCategoryId: categoryId,
    );
  }

  Future<http.Response> _get(List<String> pathSegments) async {
    try {
      return await _client
          .get(
            _endpoint(pathSegments),
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(requestTimeout);
    } on TimeoutException {
      throw const CatalogFailure(
        CatalogFailureKind.timeout,
        'La conexión tardó demasiado. Inténtalo nuevamente.',
      );
    } on CatalogFailure {
      rethrow;
    } on Object {
      throw const CatalogFailure(
        CatalogFailureKind.network,
        'No pudimos conectar con Chifa ASIA. Revisa tu conexión.',
      );
    }
  }

  Uri _endpoint(List<String> pathSegments) {
    final List<String> baseSegments = _baseUri.pathSegments
        .where((String segment) => segment.isNotEmpty)
        .toList(growable: false);
    return _baseUri.replace(
      pathSegments: <String>[...baseSegments, ...pathSegments],
      query: null,
      fragment: null,
    );
  }

  Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on Object {
      throw const CatalogFailure(
        CatalogFailureKind.malformedResponse,
        'El servidor devolvió un catálogo no válido.',
      );
    }
  }

  CatalogFailure _failureFor(int statusCode) {
    return switch (statusCode) {
      404 => const CatalogFailure(
        CatalogFailureKind.notFound,
        'La categoría ya no está disponible.',
      ),
      422 => const CatalogFailure(
        CatalogFailureKind.validation,
        'No pudimos consultar esta categoría.',
      ),
      _ => const CatalogFailure(
        CatalogFailureKind.server,
        'Chifa ASIA no está disponible por el momento. Inténtalo nuevamente.',
      ),
    };
  }
}
