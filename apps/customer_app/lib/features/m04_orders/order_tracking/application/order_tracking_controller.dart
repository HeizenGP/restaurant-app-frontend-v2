import 'package:flutter/foundation.dart';

import '../../submit_order/application/order_contracts.dart';
import '../../submit_order/domain/order_models.dart';
import '../domain/order_tracking_models.dart';
import 'order_tracking_contracts.dart';

enum OrderTrackingPhase { idle, loading, ready, failure }

final class OrderTrackingState {
  const OrderTrackingState({
    this.phase = OrderTrackingPhase.idle,
    this.orderId,
    this.order,
    this.tracking,
    this.failure,
  });

  final OrderTrackingPhase phase;
  final String? orderId;
  final OrderSnapshot? order;
  final OrderTrackingSnapshot? tracking;
  final OrderFailure? failure;

  bool get canRetry {
    return phase == OrderTrackingPhase.failure &&
        orderId != null &&
        failure?.canRetrySafely == true;
  }
}

final class OrderTrackingController extends ChangeNotifier {
  factory OrderTrackingController({
    required OrderTrackingRepository repository,
    required OrderAccessTokenProvider accessTokenProvider,
    required RefreshOrderAccessToken refreshAccessToken,
  }) {
    return OrderTrackingController._(
      repository,
      accessTokenProvider,
      refreshAccessToken,
    );
  }

  OrderTrackingController._(
    this._repository,
    this._accessTokenProvider,
    this._refreshAccessToken,
  );

  final OrderTrackingRepository _repository;
  final OrderAccessTokenProvider _accessTokenProvider;
  final RefreshOrderAccessToken _refreshAccessToken;

  OrderTrackingState _state = const OrderTrackingState();
  bool _operationInFlight = false;
  bool _disposed = false;

  OrderTrackingState get state => _state;

  Future<bool> load(String orderId) async {
    if (_operationInFlight) return false;
    final String normalizedId = orderId.trim();
    if (normalizedId.isEmpty) {
      _emit(
        const OrderTrackingState(
          phase: OrderTrackingPhase.failure,
          failure: OrderFailure(
            OrderFailureKind.validation,
            'El pedido indicado no es válido.',
          ),
        ),
      );
      return false;
    }

    _operationInFlight = true;
    _emit(
      OrderTrackingState(
        phase: OrderTrackingPhase.loading,
        orderId: normalizedId,
      ),
    );

    try {
      final (OrderSnapshot order, OrderTrackingSnapshot tracking) =
          await _withOneAuthRefresh(
        (String token) async {
          final OrderSnapshot order = await _repository.getOrder(
            normalizedId,
            accessToken: token,
          );
          final OrderTrackingSnapshot tracking = await _repository.getTracking(
            normalizedId,
            accessToken: token,
          );
          return (order, tracking);
        },
      );

      _emit(
        OrderTrackingState(
          phase: OrderTrackingPhase.ready,
          orderId: normalizedId,
          order: order,
          tracking: tracking,
        ),
      );
      return true;
    } on Object catch (error) {
      _emit(
        OrderTrackingState(
          phase: OrderTrackingPhase.failure,
          orderId: normalizedId,
          failure: _safeFailure(error),
        ),
      );
      return false;
    } finally {
      _operationInFlight = false;
    }
  }

  Future<bool> retry() async {
    final String? orderId = _state.orderId;
    if (!_state.canRetry || orderId == null) return false;
    return load(orderId);
  }

  void clear() {
    _emit(const OrderTrackingState());
  }

  Future<T> _withOneAuthRefresh<T>(
    Future<T> Function(String token) operation,
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

  OrderFailure _safeFailure(Object error) {
    if (error is OrderFailure) return error;
    return const OrderFailure(
      OrderFailureKind.server,
      'Ocurrió un error inesperado al consultar el seguimiento.',
    );
  }

  void _emit(OrderTrackingState value) {
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
