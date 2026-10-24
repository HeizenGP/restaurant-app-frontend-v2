import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../application/fulfillment_contracts.dart';
import '../domain/fulfillment_models.dart';
import 'tables_json_mapper.dart';

final class TablesRestRepository implements TablesRepository {
  factory TablesRestRepository({
    required Uri baseUri,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 15),
  }) {
    return TablesRestRepository._(baseUri, client, requestTimeout);
  }

  const TablesRestRepository._(
    this._baseUri,
    this._client,
    this.requestTimeout,
  );

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<List<RestaurantTable>> listTables() async {
    final http.Response response;
    try {
      response = await _client
          .get(
            _endpoint(),
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(requestTimeout);
    } on TimeoutException {
      throw const TablesFailure(
        TablesFailureKind.timeout,
        'La conexión tardó demasiado. Inténtalo nuevamente.',
      );
    } on TablesFailure {
      rethrow;
    } on Object {
      throw const TablesFailure(
        TablesFailureKind.network,
        'No pudimos conectar con Chifa ASIA. Revisa tu conexión.',
      );
    }

    if (response.statusCode != 200) {
      throw _failureFor(response.statusCode);
    }

    final Object? payload;
    try {
      payload = jsonDecode(utf8.decode(response.bodyBytes));
    } on Object {
      throw const TablesFailure(
        TablesFailureKind.malformedResponse,
        'El servidor devolvió mesas no válidas.',
      );
    }
    return TablesJsonMapper.decodeTables(payload);
  }

  Uri _endpoint() {
    final List<String> baseSegments = _baseUri.pathSegments
        .where((String segment) => segment.isNotEmpty)
        .toList(growable: false);
    return _baseUri.replace(
      pathSegments: <String>[...baseSegments, 'tables'],
      query: null,
      fragment: null,
    );
  }

  TablesFailure _failureFor(int statusCode) {
    return switch (statusCode) {
      422 => const TablesFailure(
        TablesFailureKind.validation,
        'No pudimos consultar las mesas.',
      ),
      _ => const TablesFailure(
        TablesFailureKind.server,
        'Chifa ASIA no está disponible por el momento. Inténtalo nuevamente.',
      ),
    };
  }
}
