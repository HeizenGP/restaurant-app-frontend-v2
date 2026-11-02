import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../application/order_contracts.dart';
import '../domain/order_models.dart';
import 'order_json_mapper.dart';

final class OrdersRestRepository implements OrdersRepository {
  factory OrdersRestRepository({
    required Uri baseUri,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 15),
  }) {
    return OrdersRestRepository._(baseUri, client, requestTimeout);
  }

  const OrdersRestRepository._(
    this._baseUri,
    this._client,
    this.requestTimeout,
  );

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<OrderSnapshot> createOrder(
    CreateOrderCommand command, {
    required String accessToken,
    required String idempotencyKey,
  }) async {
    _requireAccessToken(accessToken);
    _requireIdempotencyKey(idempotencyKey);
    final http.Response response = await _send(
      () => _client.post(
        _endpoint(const <String>['orders']),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'Idempotency-Key': idempotencyKey,
        },
        body: jsonEncode(OrderJsonMapper.encodeCreate(command)),
      ),
    );
    if (response.statusCode != 201) throw _failureFor(response);
    return OrderJsonMapper.decodeOrder(_decodeJson(response));
  }

  @override
  Future<OrderSnapshot> getOrder(
    String orderId, {
    required String accessToken,
  }) async {
    _requireAccessToken(accessToken);
    final String normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      throw const OrderFailure(
        OrderFailureKind.validation,
        'El pedido indicado no es válido.',
      );
    }
    final http.Response response = await _send(
      () => _client.get(
        _endpoint(<String>['orders', normalizedOrderId]),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    if (response.statusCode != 200) throw _failureFor(response);
    return OrderJsonMapper.decodeOrder(_decodeJson(response));
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(requestTimeout);
    } on TimeoutException {
      throw const OrderFailure(
        OrderFailureKind.timeout,
        'La conexión tardó demasiado. Puedes reintentar sin duplicar el pedido.',
      );
    } on OrderFailure {
      rethrow;
    } on Object {
      throw const OrderFailure(
        OrderFailureKind.network,
        'No pudimos conectar con KAIRO. Revisa tu conexión.',
      );
    }
  }

  Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on Object {
      throw const OrderFailure(
        OrderFailureKind.malformedResponse,
        'El servidor devolvió un pedido no válido.',
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

  void _requireIdempotencyKey(String idempotencyKey) {
    if (idempotencyKey.isEmpty ||
        idempotencyKey.trim() != idempotencyKey ||
        idempotencyKey.length > 128) {
      throw const OrderFailure(
        OrderFailureKind.validation,
        'No pudimos preparar el envío seguro del pedido.',
      );
    }
  }

  OrderFailure _failureFor(http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode == 409) {
      final String detail = _errorDetail(response).toLowerCase();
      if (detail.contains('product')) {
        return const OrderFailure(
          OrderFailureKind.productUnavailable,
          'Uno de los productos ya no está disponible. Revisa tu carrito.',
        );
      }
      if (detail.contains('idempotency')) {
        return const OrderFailure(
          OrderFailureKind.idempotencyConflict,
          'La solicitud cambió después de prepararse. Revísala antes de volver a enviar.',
        );
      }
    }
    return switch (statusCode) {
      401 => const OrderFailure(
        OrderFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      ),
      403 => const OrderFailure(
        OrderFailureKind.forbidden,
        'No tienes permiso para consultar o enviar este pedido.',
      ),
      404 => const OrderFailure(
        OrderFailureKind.notFound,
        'No encontramos el pedido solicitado.',
      ),
      409 => const OrderFailure(
        OrderFailureKind.conflict,
        'La solicitud entra en conflicto con su estado actual. Revísala antes de continuar.',
      ),
      422 => const OrderFailure(
        OrderFailureKind.validation,
        'Revisa los productos y datos de atención antes de enviar.',
      ),
      400 => const OrderFailure(
        OrderFailureKind.validation,
        'Revisa los productos y datos de atención antes de enviar.',
      ),
      _ => const OrderFailure(
        OrderFailureKind.server,
        'KAIRO no está disponible por el momento. Inténtalo nuevamente.',
      ),
    };
  }

  String _errorDetail(http.Response response) {
    try {
      final Object? body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, Object?> && body['detail'] is String) {
        return body['detail']! as String;
      }
    } on Object {
      // Error bodies are optional; status codes remain authoritative.
    }
    return '';
  }
}
