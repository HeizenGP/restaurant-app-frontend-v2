import 'dart:math';

import 'package:flutter/foundation.dart';

import '../domain/order_models.dart';
import 'order_contracts.dart';

enum OrderSubmissionPhase {
  review,
  submitting,
  success,
  failure,
  detailLoading,
}

enum OrderOperation { submission, detail }

@immutable
final class OrderSubmissionState {
  const OrderSubmissionState({
    this.phase = OrderSubmissionPhase.review,
    this.command,
    this.idempotencyKey,
    this.order,
    this.failure,
    this.failedOperation,
    this.detailOrderId,
  });

  final OrderSubmissionPhase phase;
  final CreateOrderCommand? command;
  final String? idempotencyKey;
  final OrderSnapshot? order;
  final OrderFailure? failure;
  final OrderOperation? failedOperation;
  final String? detailOrderId;

  bool get canRetrySubmission {
    return phase == OrderSubmissionPhase.failure &&
        failedOperation == OrderOperation.submission &&
        failure?.canRetrySafely == true;
  }

  bool get canRetryDetail {
    return phase == OrderSubmissionPhase.failure &&
        failedOperation == OrderOperation.detail &&
        detailOrderId != null &&
        failure?.canRetrySafely == true;
  }
}

final class SubmitOrderController extends ChangeNotifier {
  factory SubmitOrderController({
    required OrdersRepository repository,
    required AccessTokenProvider accessTokenProvider,
    required RefreshAccessToken refreshAccessToken,
    IdempotencyKeyGenerator? idempotencyKeyGenerator,
    CreateOrderCommand? initialCommand,
  }) {
    final SubmitOrderController controller = SubmitOrderController._(
      repository,
      accessTokenProvider,
      refreshAccessToken,
      idempotencyKeyGenerator ?? generateSecureIdempotencyKey,
    );
    if (initialCommand != null) controller.prepareReview(initialCommand);
    return controller;
  }

  SubmitOrderController._(
    this._repository,
    this._accessTokenProvider,
    this._refreshAccessToken,
    this._idempotencyKeyGenerator,
  );

  final OrdersRepository _repository;
  final AccessTokenProvider _accessTokenProvider;
  final RefreshAccessToken _refreshAccessToken;
  final IdempotencyKeyGenerator _idempotencyKeyGenerator;

  OrderSubmissionState _state = const OrderSubmissionState();
  bool _operationInFlight = false;
  bool _disposed = false;

  OrderSubmissionState get state => _state;

  bool prepareReview(CreateOrderCommand command) {
    if (_operationInFlight) return false;
    final bool samePayload = _state.command == command;
    _emit(
      OrderSubmissionState(
        command: command,
        idempotencyKey: samePayload
            ? _state.idempotencyKey ?? _newIdempotencyKey()
            : _newIdempotencyKey(),
      ),
    );
    return true;
  }

  bool startNewLogicalRequest(CreateOrderCommand command) {
    if (_operationInFlight) return false;
    _emit(
      OrderSubmissionState(
        command: command,
        idempotencyKey: _newIdempotencyKey(),
      ),
    );
    return true;
  }

  Future<bool> submit() async {
    if (_operationInFlight) return false;
    final CreateOrderCommand? command = _state.command;
    if (command == null) {
      _emit(
        const OrderSubmissionState(
          phase: OrderSubmissionPhase.failure,
          failure: OrderFailure(
            OrderFailureKind.validation,
            'No hay una solicitud lista para enviar.',
          ),
          failedOperation: OrderOperation.submission,
        ),
      );
      return false;
    }
    final String key = _state.idempotencyKey ?? _newIdempotencyKey();
    _operationInFlight = true;
    _emit(
      OrderSubmissionState(
        phase: OrderSubmissionPhase.submitting,
        command: command,
        idempotencyKey: key,
      ),
    );

    try {
      final OrderSnapshot order = await _withOneAuthRefresh(
        (String token) => _repository.createOrder(
          command,
          accessToken: token,
          idempotencyKey: key,
        ),
      );
      if (!order.isRequested) {
        throw const OrderFailure(
          OrderFailureKind.malformedResponse,
          'El servidor devolvió un estado inicial no válido.',
        );
      }
      _emit(
        OrderSubmissionState(
          phase: OrderSubmissionPhase.success,
          command: command,
          idempotencyKey: key,
          order: order,
          detailOrderId: order.id,
        ),
      );
      return true;
    } on Object catch (error) {
      _emit(
        OrderSubmissionState(
          phase: OrderSubmissionPhase.failure,
          command: command,
          idempotencyKey: key,
          failure: _safeFailure(error),
          failedOperation: OrderOperation.submission,
        ),
      );
      return false;
    } finally {
      _operationInFlight = false;
    }
  }

  Future<bool> retrySubmission() async {
    if (!_state.canRetrySubmission) return false;
    return submit();
  }

  Future<bool> loadOrderDetail(String orderId) async {
    if (_operationInFlight) return false;
    final String normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      _emit(
        OrderSubmissionState(
          phase: OrderSubmissionPhase.failure,
          command: _state.command,
          idempotencyKey: _state.idempotencyKey,
          order: _state.order,
          failure: const OrderFailure(
            OrderFailureKind.validation,
            'El pedido indicado no es válido.',
          ),
          failedOperation: OrderOperation.detail,
        ),
      );
      return false;
    }

    _operationInFlight = true;
    final CreateOrderCommand? command = _state.command;
    final String? key = _state.idempotencyKey;
    final OrderSnapshot? currentOrder = _state.order;
    _emit(
      OrderSubmissionState(
        phase: OrderSubmissionPhase.detailLoading,
        command: command,
        idempotencyKey: key,
        order: currentOrder,
        detailOrderId: normalizedOrderId,
      ),
    );

    try {
      final OrderSnapshot order = await _withOneAuthRefresh(
        (String token) =>
            _repository.getOrder(normalizedOrderId, accessToken: token),
      );
      _emit(
        OrderSubmissionState(
          phase: OrderSubmissionPhase.success,
          command: command,
          idempotencyKey: key,
          order: order,
          detailOrderId: normalizedOrderId,
        ),
      );
      return true;
    } on Object catch (error) {
      _emit(
        OrderSubmissionState(
          phase: OrderSubmissionPhase.failure,
          command: command,
          idempotencyKey: key,
          order: currentOrder,
          failure: _safeFailure(error),
          failedOperation: OrderOperation.detail,
          detailOrderId: normalizedOrderId,
        ),
      );
      return false;
    } finally {
      _operationInFlight = false;
    }
  }

  Future<bool> retryDetail() async {
    final String? orderId = _state.detailOrderId;
    if (!_state.canRetryDetail || orderId == null) return false;
    return loadOrderDetail(orderId);
  }

  Future<OrderSnapshot> _withOneAuthRefresh(
    Future<OrderSnapshot> Function(String token) operation,
  ) async {
    final String token = _requireToken();
    try {
      return await operation(token);
    } on OrderFailure catch (failure) {
      if (failure.kind != OrderFailureKind.unauthorized) rethrow;
    }

    final bool refreshed;
    try {
      refreshed = await _refreshAccessToken();
    } on Object {
      throw const OrderFailure(
        OrderFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
    if (!refreshed) {
      throw const OrderFailure(
        OrderFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
    return operation(_requireToken());
  }

  String _requireToken() {
    final String? token = _accessTokenProvider();
    if (token == null || token.trim().isEmpty) {
      throw const OrderFailure(
        OrderFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
    return token;
  }

  String _newIdempotencyKey() {
    final String value = _idempotencyKeyGenerator();
    if (value.isEmpty || value.trim() != value || value.length > 128) {
      return generateSecureIdempotencyKey();
    }
    return value;
  }

  OrderFailure _safeFailure(Object error) {
    if (error is OrderFailure) return error;
    return const OrderFailure(
      OrderFailureKind.server,
      'Ocurrió un error inesperado. Inténtalo nuevamente.',
    );
  }

  void _emit(OrderSubmissionState value) {
    if (_disposed) return;
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

String generateSecureIdempotencyKey() {
  final Random random = Random.secure();
  final StringBuffer buffer = StringBuffer('app-order-');
  for (int index = 0; index < 24; index += 1) {
    buffer.write(random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
