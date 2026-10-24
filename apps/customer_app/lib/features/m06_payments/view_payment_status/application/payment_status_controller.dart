import 'package:flutter/foundation.dart';

import '../domain/payment_models.dart';
import 'payment_status_contracts.dart';

enum PaymentStatusView { advance, payments }

enum PaymentStatusPhase { idle, loading, ready, failure }

final class PaymentStatusState {
  const PaymentStatusState({
    this.phase = PaymentStatusPhase.idle,
    this.view = PaymentStatusView.advance,
    this.orderId,
    this.advance,
    this.paymentSummary,
    this.failure,
  });

  final PaymentStatusPhase phase;
  final PaymentStatusView view;
  final String? orderId;
  final AdvanceSummary? advance;
  final PaymentSummary? paymentSummary;
  final PaymentStatusFailure? failure;

  bool get canRetry {
    return phase == PaymentStatusPhase.failure &&
        orderId != null &&
        failure?.canRetrySafely == true;
  }
}

final class PaymentStatusController extends ChangeNotifier {
  factory PaymentStatusController({
    required PaymentStatusRepository repository,
    required PaymentAccessTokenProvider accessTokenProvider,
    required RefreshPaymentAccessToken refreshAccessToken,
  }) {
    return PaymentStatusController._(
      repository,
      accessTokenProvider,
      refreshAccessToken,
    );
  }

  PaymentStatusController._(
    this._repository,
    this._accessTokenProvider,
    this._refreshAccessToken,
  );

  final PaymentStatusRepository _repository;
  final PaymentAccessTokenProvider _accessTokenProvider;
  final RefreshPaymentAccessToken _refreshAccessToken;

  PaymentStatusState _state = const PaymentStatusState();
  bool _operationInFlight = false;
  bool _disposed = false;

  PaymentStatusState get state => _state;

  Future<bool> loadAdvance(String orderId) {
    return _load(orderId, PaymentStatusView.advance);
  }

  Future<bool> loadPayments(String orderId) {
    return _load(orderId, PaymentStatusView.payments);
  }

  Future<bool> retry() async {
    final String? orderId = _state.orderId;
    if (!_state.canRetry || orderId == null) return false;
    return _load(orderId, _state.view);
  }

  Future<bool> _load(String orderId, PaymentStatusView view) async {
    if (_operationInFlight) return false;
    final String normalizedOrderId = orderId.trim();
    if (normalizedOrderId.isEmpty) {
      _emit(
        PaymentStatusState(
          phase: PaymentStatusPhase.failure,
          view: view,
          failure: const PaymentStatusFailure(
            PaymentStatusFailureKind.validation,
            'El pedido indicado no es válido.',
          ),
        ),
      );
      return false;
    }

    _operationInFlight = true;
    _emit(
      PaymentStatusState(
        phase: PaymentStatusPhase.loading,
        view: view,
        orderId: normalizedOrderId,
      ),
    );
    try {
      switch (view) {
        case PaymentStatusView.advance:
          final AdvanceSummary advance = await _withOneAuthRefresh(
            (String token) =>
                _repository.getAdvance(normalizedOrderId, accessToken: token),
          );
          _emit(
            PaymentStatusState(
              phase: PaymentStatusPhase.ready,
              view: view,
              orderId: normalizedOrderId,
              advance: advance,
            ),
          );
        case PaymentStatusView.payments:
          final PaymentSummary paymentSummary = await _withOneAuthRefresh(
            (String token) =>
                _repository.getPayments(normalizedOrderId, accessToken: token),
          );
          _emit(
            PaymentStatusState(
              phase: PaymentStatusPhase.ready,
              view: view,
              orderId: normalizedOrderId,
              paymentSummary: paymentSummary,
            ),
          );
      }
      return true;
    } on Object catch (error) {
      _emit(
        PaymentStatusState(
          phase: PaymentStatusPhase.failure,
          view: view,
          orderId: normalizedOrderId,
          failure: _safeFailure(error),
        ),
      );
      return false;
    } finally {
      _operationInFlight = false;
    }
  }

  Future<T> _withOneAuthRefresh<T>(
    Future<T> Function(String token) operation,
  ) async {
    final String token = _requireToken();
    try {
      return await operation(token);
    } on PaymentStatusFailure catch (failure) {
      if (failure.kind != PaymentStatusFailureKind.unauthorized) rethrow;
    }

    final bool refreshed;
    try {
      refreshed = await _refreshAccessToken();
    } on Object {
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
    if (!refreshed) {
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
    return operation(_requireToken());
  }

  String _requireToken() {
    final String? token = _accessTokenProvider();
    if (token == null || token.trim().isEmpty) {
      throw const PaymentStatusFailure(
        PaymentStatusFailureKind.unauthorized,
        'Tu sesión terminó. Inicia sesión nuevamente.',
      );
    }
    return token;
  }

  PaymentStatusFailure _safeFailure(Object error) {
    if (error is PaymentStatusFailure) return error;
    return const PaymentStatusFailure(
      PaymentStatusFailureKind.server,
      'Ocurrió un error inesperado. Inténtalo nuevamente.',
    );
  }

  void _emit(PaymentStatusState value) {
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
