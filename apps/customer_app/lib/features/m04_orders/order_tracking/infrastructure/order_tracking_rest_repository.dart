import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../submit_order/application/order_contracts.dart';
import '../../submit_order/domain/order_models.dart';
import '../../submit_order/infrastructure/order_json_mapper.dart';
import '../application/order_tracking_contracts.dart';
import '../domain/order_tracking_models.dart';
import 'order_tracking_json_mapper.dart';

final class OrderTrackingRestRepository implements OrderTrackingRepository {
  factory OrderTrackingRestRepository({
    required Uri baseUri,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 15),
  }) {
    return OrderTrackingRestRepository._(baseUri, client, requestTimeout);
  }

  const OrderTrackingRestRepository._(
    this._baseUri,
    this._client,
    this.requestTimeout,
  );

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<List<OrderSnapshot>> listOrders({
    required String accessToken,
  }) async {
    final http.Response response = await _get(
      <String>['orders'],
      accessToken: accessToken,
    );
    return OrderTrackingJsonMapper.decodeOrdersList(_decodeJson(response));
  }

  @override
  Future<OrderSnapshot> getOrder(
    String orderId, {
    required String accessToken,
  }) async {
    final String normalizedId = orderId.trim();
    if (normalizedId.isEmpty) {
      throw const OrderFailure(
        OrderFailureKind.validation,
        'El pedido indicado no es válido.',
      );
    }
    final http.Response response = await _get(
      <String>['orders', normalizedId],
      accessToken: accessToken,
    );
    return OrderJsonMapper.decodeOrder(_decodeJson(response));
  }

  @override
  Future<OrderTrackingSnapshot> getTracking(
    String orderId, {
    required String accessToken,
  }) async {
    final String normalizedId = orderId.trim();
    if (normalizedId.isEmpty) {
      throw const OrderFailure(
        OrderFailureKind.validation,
        'El pedido indicado no es válido.',
      );
    }
    final http.Response response = await _get(
      <String>['orders', normalizedId, 'tracking'],
      accessToken: accessToken,
    );
    return OrderTrackingJsonMapper.decodeTracking(_decodeJson(response));
  }

  Future<http.Response> _get(
    List<String> pathSegments, {
    required String accessToken,
  }) async {
    _requireAccessToken(accessToken);
    final http.Response response = await _send(
      () => _client.get(
        _endpoint(pathSegments),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    if (response.statusCode != 200) throw _failureFor(response.statusCode);
    return response;
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(requestTimeout);
    } on TimeoutException {
      throw const OrderFailure(
        OrderFailureKind.timeout,
        'La conexión tardó demasiado. Inténtalo nuevamente.',
      );
    } on OrderFailure {
      rethrow;
    } on Object {
      throw const OrderFailure(
        OrderFailureKind.network,
        'No pudimos conectar con Chifa ASIA. Revisa tu conexión.',
      );
    }
  }

  Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on Object {
      throw const OrderFailure(
        OrderFailureKind.malformedResponse,
        'El servidor devolvió una respuesta no válida.',
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

  void _requireAccessToken(String accessToken) {
    if (accessToken.trim().isEmpty) {
      throw const OrderFailure(
        OrderFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
  }

  OrderFailure _failureFor(int statusCode) {
    return switch (statusCode) {
      401 => const OrderFailure(
        OrderFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      ),
      403 => const OrderFailure(
        OrderFailureKind.forbidden,
        'No tienes permiso para consultar este recurso.',
      ),
      404 => const OrderFailure(
        OrderFailureKind.notFound,
        'No encontramos el pedido solicitado.',
      ),
      409 => const OrderFailure(
        OrderFailureKind.conflict,
        'El estado del pedido no permite esta consulta.',
      ),
      400 || 422 => const OrderFailure(
        OrderFailureKind.validation,
        'No pudimos procesar la consulta del pedido.',
      ),
      _ => const OrderFailure(
        OrderFailureKind.server,
        'Chifa ASIA no está disponible por el momento. Inténtalo nuevamente.',
      ),
    };
  }
}
