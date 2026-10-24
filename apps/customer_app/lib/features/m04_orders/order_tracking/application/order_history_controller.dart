import 'package:flutter/foundation.dart';

import '../../submit_order/application/order_contracts.dart';
import '../../submit_order/domain/order_models.dart';
import '../domain/order_tracking_models.dart';
import 'order_tracking_contracts.dart';

enum OrderHistoryPhase { idle, loading, ready, failure }

final class OrderHistoryState {
  const OrderHistoryState({
    this.phase = OrderHistoryPhase.idle,
    this.orders = const <OrderSnapshot>[],
    this.selectedFilter = OrderHistoryFilter.all,
    this.failure,
  });

  final OrderHistoryPhase phase;
  final List<OrderSnapshot> orders;
  final OrderHistoryFilter selectedFilter;
  final OrderFailure? failure;

  List<OrderSnapshot> get filteredOrders {
    return switch (selectedFilter) {
      OrderHistoryFilter.all => orders,
      OrderHistoryFilter.pending => orders
          .where(
            (OrderSnapshot o) =>
                o.status == 'REQUESTED' || o.status == 'APPROVED',
          )
          .toList(growable: false),
      OrderHistoryFilter.confirmed => orders
          .where(
            (OrderSnapshot o) =>
                o.status == 'CONFIRMED' || o.status == 'CLOSED',
          )
          .toList(growable: false),
    };
  }

  bool get canRetry {
    return phase == OrderHistoryPhase.failure &&
        failure?.canRetrySafely == true;
  }
}

final class OrderHistoryController extends ChangeNotifier {
  factory OrderHistoryController({
    required OrderTrackingRepository repository,
    required OrderAccessTokenProvider accessTokenProvider,
    required RefreshOrderAccessToken refreshAccessToken,
  }) {
    return OrderHistoryController._(
      repository,
      accessTokenProvider,
      refreshAccessToken,
    );
  }

  OrderHistoryController._(
    this._repository,
    this._accessTokenProvider,
    this._refreshAccessToken,
  );

  final OrderTrackingRepository _repository;
  final OrderAccessTokenProvider _accessTokenProvider;
  final RefreshOrderAccessToken _refreshAccessToken;

  OrderHistoryState _state = const OrderHistoryState();
  bool _operationInFlight = false;
  bool _disposed = false;

  OrderHistoryState get state => _state;

  Future<bool> loadOrders() async {
    if (_operationInFlight) return false;
    _operationInFlight = true;
    _emit(
      OrderHistoryState(
        phase: OrderHistoryPhase.loading,
        orders: _state.orders,
        selectedFilter: _state.selectedFilter,
      ),
    );

    try {
      final List<OrderSnapshot> orders = await _withOneAuthRefresh(
        (String token) => _repository.listOrders(accessToken: token),
      );
      _emit(
        OrderHistoryState(
          phase: OrderHistoryPhase.ready,
          orders: orders,
          selectedFilter: _state.selectedFilter,
        ),
      );
      return true;
    } on Object catch (error) {
      _emit(
        OrderHistoryState(
          phase: OrderHistoryPhase.failure,
          orders: _state.orders,
          selectedFilter: _state.selectedFilter,
          failure: _safeFailure(error),
        ),
      );
      return false;
    } finally {
      _operationInFlight = false;
    }
  }

  void setFilter(OrderHistoryFilter filter) {
    if (_state.selectedFilter == filter) return;
    _emit(
      OrderHistoryState(
        phase: _state.phase,
        orders: _state.orders,
        selectedFilter: filter,
        failure: _state.failure,
      ),
    );
  }

  Future<bool> retry() async {
    if (!_state.canRetry) return false;
    return loadOrders();
  }

  void clear() {
    _emit(const OrderHistoryState());
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
      'Ocurrió un error inesperado al consultar tus pedidos.',
    );
  }

  void _emit(OrderHistoryState value) {
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
