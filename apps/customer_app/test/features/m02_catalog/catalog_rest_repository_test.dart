import 'dart:convert';

import 'package:customer_app/features/m02_catalog/shared/application/catalog_contracts.dart';
import 'package:customer_app/features/m02_catalog/shared/infrastructure/catalog_rest_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/catalog_fakes.dart';

void main() {
  const String baseUrl = 'https://api.example.test/api/v1';

  test('lists public categories using only the exact GET contract', () async {
    late http.Request captured;
    final CatalogRestRepository repository = CatalogRestRepository(
      baseUri: Uri.parse('$baseUrl/'),
      client: MockClient((http.Request request) async {
        captured = request;
        return http.Response(
          jsonEncode(<Object?>[
            <String, Object?>{'id': categoryOneId, 'name': 'Arroces'},
          ]),
          200,
        );
      }),
    );

    final categories = await repository.listCategories();

    expect(captured.method, 'GET');
    expect(captured.url.toString(), '$baseUrl/catalog/categories');
    expect(captured.headers['accept'], 'application/json');
    expect(captured.headers, isNot(contains('authorization')));
    expect(categories, <Object>[categoryOne]);
  });

  test('lists category products and maps the public response only', () async {
    late http.Request captured;
    final CatalogRestRepository repository = CatalogRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient((http.Request request) async {
        captured = request;
        return http.Response(
          jsonEncode(<Object?>[
            <String, Object?>{
              'id': productOneId,
              'category_id': categoryOneId,
              'name': 'Chaufa especial',
              'price': '24.25',
              'available_for_sale': true,
            },
          ]),
          200,
        );
      }),
    );

    final products = await repository.listProducts(categoryOneId);

    expect(
      captured.url.toString(),
      '$baseUrl/catalog/categories/$categoryOneId/products',
    );
    expect(captured.headers, isNot(contains('authorization')));
    expect(products, <Object>[productOne]);
  });

  for (final (int status, CatalogFailureKind kind, String safeText)
      in <(int, CatalogFailureKind, String)>[
        (404, CatalogFailureKind.notFound, 'categoría'),
        (422, CatalogFailureKind.validation, 'consultar'),
        (503, CatalogFailureKind.server, 'no está disponible'),
      ]) {
    test('maps HTTP $status to a safe typed failure', () async {
      final CatalogRestRepository repository = CatalogRestRepository(
        baseUri: Uri.parse(baseUrl),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(<String, Object>{'detail': 'sensitive backend detail'}),
            status,
          ),
        ),
      );

      await expectLater(
        repository.listProducts(categoryOneId),
        throwsA(
          isA<CatalogFailure>()
              .having((CatalogFailure value) => value.kind, 'kind', kind)
              .having(
                (CatalogFailure value) => value.message,
                'message',
                allOf(contains(safeText), isNot(contains('sensitive'))),
              ),
        ),
      );
    });
  }

  test('maps transport errors without leaking exception details', () async {
    final CatalogRestRepository repository = CatalogRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient((_) async => throw Exception('private host detail')),
    );

    await expectLater(
      repository.listCategories(),
      throwsA(
        isA<CatalogFailure>()
            .having(
              (CatalogFailure value) => value.kind,
              'kind',
              CatalogFailureKind.network,
            )
            .having(
              (CatalogFailure value) => value.message,
              'message',
              isNot(contains('private')),
            ),
      ),
    );
  });

  test('maps request timeout separately from other network errors', () async {
    final CatalogRestRepository repository = CatalogRestRepository(
      baseUri: Uri.parse(baseUrl),
      requestTimeout: const Duration(milliseconds: 1),
      client: MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return http.Response('[]', 200);
      }),
    );

    await expectLater(
      repository.listCategories(),
      throwsA(
        isA<CatalogFailure>().having(
          (CatalogFailure value) => value.kind,
          'kind',
          CatalogFailureKind.timeout,
        ),
      ),
    );
  });

  test('rejects malformed JSON and a numeric price safely', () async {
    var call = 0;
    final CatalogRestRepository repository = CatalogRestRepository(
      baseUri: Uri.parse(baseUrl),
      client: MockClient((_) async {
        call += 1;
        if (call == 1) return http.Response('{invalid', 200);
        return http.Response(
          jsonEncode(<Object?>[
            <String, Object?>{
              'id': productOneId,
              'category_id': categoryOneId,
              'name': 'Chaufa especial',
              'price': 24.25,
              'available_for_sale': true,
            },
          ]),
          200,
        );
      }),
    );

    await expectLater(repository.listCategories(), throwsA(_malformed()));
    await expectLater(
      repository.listProducts(categoryOneId),
      throwsA(_malformed()),
    );
  });
}

Matcher _malformed() {
  return isA<CatalogFailure>().having(
    (CatalogFailure value) => value.kind,
    'kind',
    CatalogFailureKind.malformedResponse,
  );
}
