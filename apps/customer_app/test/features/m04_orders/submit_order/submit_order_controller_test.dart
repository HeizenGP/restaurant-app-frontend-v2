import 'dart:async';

import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/order_contracts.dart';
import 'package:customer_app/features/m04_orders/submit_order/application/submit_order_controller.dart';
import 'package:customer_app/features/m04_orders/submit_order/domain/order_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps the key for the same payload and rotates it after an edit', () {
    int generated = 0;
    final SubmitOrderController controller = SubmitOrderController(
      repository: _FakeOrdersRepository(),
      accessTokenProvider: () => 'token',
      refreshAccessToken: () async => false,
      idempotencyKeyGenerator: () => 'key-${++generated}',
    );
    addTearDown(controller.dispose);
    final CreateOrderCommand first = _command(quantity: 1);
    final CreateOrderCommand edited = _command(quantity: 2);

    expect(controller.prepareReview(first), isTrue);
    expect(controller.state.idempotencyKey, 'key-1');
    expect(controller.prepareReview(first), isTrue);
    expect(controller.state.idempotencyKey, 'key-1');
    expect(controller.prepareReview(edited), isTrue);
    expect(controller.state.idempotencyKey, 'key-2');
    expect(controller.state.phase, OrderSubmissionPhase.review);
  });

  test('starts a second identical logical order with a new key', () async {
    int generated = 0;
    final _FakeOrdersRepository repository = _FakeOrdersRepository();
    final SubmitOrderController controller = SubmitOrderController(
      repository: repository,
      accessTokenProvider: () => 'token',
      refreshAccessToken: () async => false,
      idempotencyKeyGenerator: () => 'key-${++generated}',
    );
    addTearDown(controller.dispose);
    final CreateOrderCommand command = _command();

    controller.startNewLogicalRequest(command);
    expect(await controller.submit(), isTrue);
    controller.startNewLogicalRequest(command);
    expect(await controller.submit(), isTrue);

    expect(
      repository.createCalls.map((_CreateCall call) => call.key),
      <String>['key-1', 'key-2'],
    );
  });

  test('retries a network failure with the exact payload and key', () async {
    final _FakeOrdersRepository repository = _FakeOrdersRepository();
    repository.createHandler =
        (CreateOrderCommand command, String token, String key) async {
          if (repository.createCalls.length == 1) {
            throw const OrderFailure(OrderFailureKind.network, 'Sin conexión.');
          }
          return _order();
        };
    final SubmitOrderController controller = _controller(repository);
    addTearDown(controller.dispose);
    final CreateOrderCommand command = _command();
    controller.prepareReview(command);

    expect(await controller.submit(), isFalse);
    expect(controller.state.canRetrySubmission, isTrue);
    expect(await controller.retrySubmission(), isTrue);

    expect(repository.createCalls, hasLength(2));
    expect(repository.createCalls[0].command, command);
    expect(repository.createCalls[1].command, command);
    expect(repository.createCalls[0].key, 'fixed-key');
    expect(repository.createCalls[1].key, 'fixed-key');
    expect(controller.state.order, _order());
  });

  test('does not offer an automatic retry for a conflict', () async {
    final _FakeOrdersRepository repository = _FakeOrdersRepository()
      ..createHandler = (_, _, _) async {
        throw const OrderFailure(
          OrderFailureKind.conflict,
          'Conflicto de idempotencia.',
        );
      };
    final SubmitOrderController controller = _controller(repository);
    addTearDown(controller.dispose);
    controller.prepareReview(_command());

    expect(await controller.submit(), isFalse);
    expect(controller.state.failure?.kind, OrderFailureKind.conflict);
    expect(controller.state.canRetrySubmission, isFalse);
    expect(await controller.retrySubmission(), isFalse);
    expect(repository.createCalls, hasLength(1));
  });

  test('a malformed success can retry with the same key', () async {
    final _FakeOrdersRepository repository = _FakeOrdersRepository()
      ..createHandler = (_, _, _) async {
        throw const OrderFailure(
          OrderFailureKind.malformedResponse,
          'Respuesta incompleta.',
        );
      };
    final SubmitOrderController controller = _controller(repository);
    addTearDown(controller.dispose);
    controller.prepareReview(_command());

    expect(await controller.submit(), isFalse);
    expect(controller.state.canRetrySubmission, isTrue);
    expect(repository.createCalls.single.key, 'fixed-key');
  });

  test('rejects a create response that did not start as REQUESTED', () async {
    final _FakeOrdersRepository repository = _FakeOrdersRepository()
      ..createHandler = (_, _, _) async {
        final OrderSnapshot requested = _order();
        return OrderSnapshot(
          id: requested.id,
          modality: requested.modality,
          channel: requested.channel,
          status: 'APPROVED',
          tableId: requested.tableId,
          totalAmount: requested.totalAmount,
          lines: requested.lines,
          createdAt: requested.createdAt,
        );
      };
    final SubmitOrderController controller = _controller(repository);
    addTearDown(controller.dispose);
    controller.prepareReview(_command());

    expect(await controller.submit(), isFalse);
    expect(
      controller.state.failure?.kind,
      OrderFailureKind.malformedResponse,
    );
    expect(controller.state.canRetrySubmission, isTrue);
  });

  test('refreshes once after 401 and preserves the idempotency key', () async {
    String token = 'expired-token';
    int refreshes = 0;
    final _FakeOrdersRepository repository = _FakeOrdersRepository()
      ..createHandler = (_, String accessToken, _) async {
        if (accessToken == 'expired-token') {
          throw const OrderFailure(OrderFailureKind.unauthorized, 'Expirada.');
        }
        return _order();
      };
    final SubmitOrderController controller = SubmitOrderController(
      repository: repository,
      accessTokenProvider: () => token,
      refreshAccessToken: () async {
        refreshes += 1;
        token = 'renewed-token';
        return true;
      },
      idempotencyKeyGenerator: () => 'auth-safe-key',
    );
    addTearDown(controller.dispose);
    controller.prepareReview(_command());

    expect(await controller.submit(), isTrue);
    expect(refreshes, 1);
    expect(
      repository.createCalls.map((_CreateCall call) => call.token),
      <String>['expired-token', 'renewed-token'],
    );
    expect(
      repository.createCalls.map((_CreateCall call) => call.key).toSet(),
      <String>{'auth-safe-key'},
    );
  });

  test(
    'fails safely without a token and never reaches the repository',
    () async {
      int refreshes = 0;
      final _FakeOrdersRepository repository = _FakeOrdersRepository();
      final SubmitOrderController controller = SubmitOrderController(
        repository: repository,
        accessTokenProvider: () => ' ',
        refreshAccessToken: () async {
          refreshes += 1;
          return true;
        },
        idempotencyKeyGenerator: () => 'safe-key',
      );
      addTearDown(controller.dispose);
      controller.prepareReview(_command());

      expect(await controller.submit(), isFalse);
      expect(controller.state.failure?.kind, OrderFailureKind.unauthorized);
      expect(repository.createCalls, isEmpty);
      expect(refreshes, 0);
    },
  );

  test('blocks a second submit while the first request is in flight', () async {
    final Completer<OrderSnapshot> pending = Completer<OrderSnapshot>();
    final _FakeOrdersRepository repository = _FakeOrdersRepository()
      ..createHandler = (_, _, _) => pending.future;
    final SubmitOrderController controller = _controller(repository);
    addTearDown(controller.dispose);
    controller.prepareReview(_command());

    final Future<bool> first = controller.submit();
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.phase, OrderSubmissionPhase.submitting);
    expect(await controller.submit(), isFalse);
    expect(repository.createCalls, hasLength(1));

    pending.complete(_order());
    expect(await first, isTrue);
    expect(repository.createCalls, hasLength(1));
  });

  test(
    'a GET detail failure never repeats POST and retries only GET',
    () async {
      int detailAttempts = 0;
      final _FakeOrdersRepository repository = _FakeOrdersRepository()
        ..getHandler = (String orderId, String token) async {
          detailAttempts += 1;
          if (detailAttempts == 1) {
            throw const OrderFailure(OrderFailureKind.network, 'Sin conexión.');
          }
          return _order();
        };
      final SubmitOrderController controller = _controller(repository);
      addTearDown(controller.dispose);
      controller.prepareReview(_command());
      expect(await controller.submit(), isTrue);

      expect(await controller.loadOrderDetail(_order().id), isFalse);
      expect(controller.state.failedOperation, OrderOperation.detail);
      expect(repository.createCalls, hasLength(1));
      expect(repository.getCalls, hasLength(1));

      expect(await controller.retryDetail(), isTrue);
      expect(repository.createCalls, hasLength(1));
      expect(repository.getCalls, hasLength(2));
      expect(
        repository.getCalls.map((_GetCall call) => call.orderId).toSet(),
        <String>{_order().id},
      );
    },
  );

  test(
    'never exposes an unexpected exception and uses a valid fallback key',
    () async {
      final _FakeOrdersRepository repository = _FakeOrdersRepository()
        ..createHandler = (_, _, _) async {
          throw StateError('private implementation detail');
        };
      final SubmitOrderController controller = SubmitOrderController(
        repository: repository,
        accessTokenProvider: () => 'token',
        refreshAccessToken: () async => false,
        idempotencyKeyGenerator: () => 'x' * 129,
      );
      addTearDown(controller.dispose);
      controller.prepareReview(_command());

      expect(await controller.submit(), isFalse);
      expect(controller.state.failure?.kind, OrderFailureKind.server);
      expect(
        controller.state.failure?.message,
        isNot(contains('private implementation')),
      );
      expect(controller.state.idempotencyKey, startsWith('app-order-'));
      expect(controller.state.idempotencyKey, hasLength(58));
      expect(
        repository.createCalls.single.key,
        controller.state.idempotencyKey,
      );
    },
  );

  test('generated keys are non-empty, bounded and distinct', () {
    final String first = generateSecureIdempotencyKey();
    final String second = generateSecureIdempotencyKey();

    expect(first, matches(RegExp(r'^app-order-[0-9a-f]{48}$')));
    expect(first.length, lessThanOrEqualTo(128));
    expect(second, isNot(first));
  });
}

SubmitOrderController _controller(_FakeOrdersRepository repository) {
  return SubmitOrderController(
    repository: repository,
    accessTokenProvider: () => 'token',
    refreshAccessToken: () async => false,
    idempotencyKeyGenerator: () => 'fixed-key',
  );
}

CreateOrderCommand _command({int quantity = 1}) {
  return CreateOrderCommand(
    items: <CreateOrderItem>[
      CreateOrderItem(productId: 'product-1', quantity: quantity),
    ],
    fulfillment: FulfillmentDraft.local(tableId: 'table-1'),
  );
}

OrderSnapshot _order() {
  return OrderSnapshot(
    id: 'order-1',
    modality: FulfillmentMode.local,
    channel: 'APP',
    status: 'REQUESTED',
    tableId: 'table-1',
    totalAmount: '12.00',
    lines: const <OrderLineSnapshot>[
      OrderLineSnapshot(
        productId: 'product-1',
        productName: 'Arroz chaufa',
        quantity: 1,
        unitPrice: '12.00',
      ),
    ],
    createdAt: DateTime.utc(2026, 10, 24, 15, 30),
  );
}

final class _CreateCall {
  const _CreateCall(this.command, this.token, this.key);

  final CreateOrderCommand command;
  final String token;
  final String key;
}

final class _GetCall {
  const _GetCall(this.orderId, this.token);

  final String orderId;
  final String token;
}

final class _FakeOrdersRepository implements OrdersRepository {
  Future<OrderSnapshot> Function(
    CreateOrderCommand command,
    String token,
    String key,
  )?
  createHandler;
  Future<OrderSnapshot> Function(String orderId, String token)? getHandler;

  final List<_CreateCall> createCalls = <_CreateCall>[];
  final List<_GetCall> getCalls = <_GetCall>[];

  @override
  Future<OrderSnapshot> createOrder(
    CreateOrderCommand command, {
    required String accessToken,
    required String idempotencyKey,
  }) async {
    createCalls.add(_CreateCall(command, accessToken, idempotencyKey));
    return await createHandler?.call(command, accessToken, idempotencyKey) ??
        _order();
  }

  @override
  Future<OrderSnapshot> getOrder(
    String orderId, {
    required String accessToken,
  }) async {
    getCalls.add(_GetCall(orderId, accessToken));
    return await getHandler?.call(orderId, accessToken) ?? _order();
  }
}
