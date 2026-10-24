import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../application/payment_status_contracts.dart';
import '../domain/payment_models.dart';
import 'payment_status_json_mapper.dart';

final class PaymentStatusRestRepository implements PaymentStatusRepository {
  factory PaymentStatusRestRepository({
    required Uri baseUri,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 15),
  }) {
    return PaymentStatusRestRepository._(baseUri, client, requestTimeout);
  }

  const PaymentStatusRestRepository._(
    this._baseUri,
    this._client,
    this.requestTimeout,
  );

  final Uri _baseUri;
  final http.Client _client;
  final Duration requestTimeout;

  @override
  Future<AdvanceSummary> getAdvance(
    String orderId, {
    required String accessToken,
  }) async {
    final http.Response response = await _get(
      orderId,
      'advance',
      accessToken: accessToken,
    );
    return PaymentStatusJsonMapper.decodeAdvance(_decodeJson(response));
  }

  @override
  Future<PaymentSummary> getPayments(
    String orderId, {
    required String accessToken,
  }) async {
    final http.Response response = await _get(
      orderId,
      'payments',
      accessToken: accessToken,
    );
    return PaymentStatusJsonMapper.decodePayments(_decodeJson(response));
  }

  Future<http.Response> _get(
    String orderId,
    String resource, {
    required String accessToken,
  }) async {
    final String normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.validation,
        'El pedido indicado no es válido.',
      );
    }
    _requireAccessToken(accessToken);
    final http.Response response = await _send(
      () => _client.get(
        _endpoint(<String>['orders', normalizedOrderId, resource]),
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
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.timeout,
        'La conexión tardó demasiado. Inténtalo nuevamente.',
      );
    } on PaymentStatusFailure {
      rethrow;
    } on Object {
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.network,
        'No pudimos conectar con Chifa ASIA. Revisa tu conexión.',
      );
    }
  }

  Object? _decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on Object {
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.malformedResponse,
        'El servidor devolvió una respuesta de pago no válida.',
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
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
  }

  PaymentStatusFailure _failureFor(int statusCode) {
    return switch (statusCode) {
      401 => const PaymentStatusFailure(
        PaymentStatusFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      ),
      403 => const PaymentStatusFailure(
        PaymentStatusFailureKind.forbidden,
        'No tienes permiso para consultar los pagos de este pedido.',
      ),
      404 => const PaymentStatusFailure(
        PaymentStatusFailureKind.notFound,
        'No encontramos el pedido solicitado.',
      ),
      409 => const PaymentStatusFailure(
        PaymentStatusFailureKind.conflict,
        'Este pedido no admite la consulta de anticipo solicitada.',
      ),
      400 || 422 => const PaymentStatusFailure(
        PaymentStatusFailureKind.validation,
        'No pudimos consultar los pagos de este pedido.',
      ),
      _ => const PaymentStatusFailure(
        PaymentStatusFailureKind.server,
        'Chifa ASIA no está disponible por el momento. Inténtalo nuevamente.',
      ),
    };
  }
}
