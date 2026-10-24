import 'dart:convert';

import 'package:customer_app/features/m04_orders/choose_fulfillment/application/fulfillment_contracts.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/domain/fulfillment_models.dart';
import 'package:customer_app/features/m04_orders/choose_fulfillment/infrastructure/tables_rest_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String baseUrl = 'https://api.example.test/api/v1';

  test('uses only public GET /tables and maps exact backend fields', () async {
    late http.Request captured;
    final TablesRestRepository repository = TablesRestRepository(
      baseUri: Uri.parse('$baseUrl/'),
      client: MockClient((http.Request request) async {
        captured = request;
        return http.Response(
          jsonEncode(<Object?>[
            <String, Object?>{
              'id': 'table-1',
              'code': 'A-01',
              'area_label': 'Zona principal',
              'is_occupied': false,
            },
            <String, Object?>{
              'id': 'table-2',
              'code': 'A-02',
              'area_label': null,
              'is_occupied': true,
            },
          ]),
          200,
        );
      }),
    );

    final List<RestaurantTable> tables = await repository.listTables();

    expect(captured.method, 'GET');
    expect(captured.url.toString(), '$baseUrl/tables');
    expect(captured.headers['accept'], 'application/json');
    expect(captured.headers, isNot(contains('authorization')));
    expect(tables, const <RestaurantTable>[
      RestaurantTable(
        id: 'table-1',
        code: 'A-01',
        areaLabel: 'Zona principal',
        isOccupied: false,
      ),
      RestaurantTable(
        id: 'table-2',
        code: 'A-02',
        areaLabel: null,
        isOccupied: true,
      ),
    ]);
  });

  test('rejects malformed table fields safely', () async {
    final TablesRestRepository repository = TablesRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient(
        (_) async => http.Response(
          jsonEncode(<Object?>[
            <String, Object?>{
              'id': 'table-1',
              'code': 'A-01',
              'area_label': 2,
              'is_occupied': false,
            },
          ]),
          200,
        ),
      ),
    );

    await expectLater(
      repository.listTables(),
      throwsA(
        isA<TablesFailure>().having(
          (TablesFailure value) => value.kind,
          'kind',
          TablesFailureKind.malformedResponse,
        ),
      ),
    );
  });

  test('maps transport and HTTP errors to safe failures', () async {
    final TablesRestRepository networkRepository = TablesRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient((_) async => throw Exception('private host detail')),
    );
    final TablesRestRepository serverRepository = TablesRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient(
        (_) async => http.Response('sensitive backend body', 503),
      ),
    );

    await expectLater(
      networkRepository.listTables(),
      throwsA(
        isA<TablesFailure>()
            .having(
              (TablesFailure value) => value.kind,
              'kind',
              TablesFailureKind.network,
            )
            .having(
              (TablesFailure value) => value.message,
              'message',
              isNot(contains('private')),
            ),
      ),
    );
    await expectLater(
      serverRepository.listTables(),
      throwsA(
        isA<TablesFailure>()
            .having(
              (TablesFailure value) => value.kind,
              'kind',
              TablesFailureKind.server,
            )
            .having(
              (TablesFailure value) => value.message,
              'message',
              isNot(contains('sensitive')),
            ),
      ),
    );
  });

  test('maps timeout separately', () async {
    final TablesRestRepository repository = TablesRestRepository(
      baseUri: Uri.parse(baseUrl),
      requestTimeout: const Duration(milliseconds: 1),
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return http.Response('[]', 200);
      }),
    );

    await expectLater(
      repository.listTables(),
      throwsA(
        isA<TablesFailure>().having(
          (TablesFailure value) => value.kind,
          'kind',
          TablesFailureKind.timeout,
        ),
      ),
    );
  });
}
