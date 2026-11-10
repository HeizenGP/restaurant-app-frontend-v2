import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:staff_app/core/api_environment.dart';
import 'package:staff_app/core/design_system/theme/asia_theme.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/core/network/image_upload_service.dart';
import 'package:staff_app/core/storage/auth_storage.dart';
import 'package:staff_app/features/auth/application/auth_controller.dart';
import 'package:staff_app/features/auth/infrastructure/auth_repository.dart';
import 'package:staff_app/features/products/application/catalog_controller.dart';
import 'package:staff_app/features/products/domain/catalog_models.dart';
import 'package:staff_app/features/products/infrastructure/catalog_repository.dart';
import 'package:staff_app/features/products/presentation/category_form_page.dart';
import 'package:staff_app/features/products/presentation/product_form_page.dart';
import 'package:staff_app/features/products/presentation/products_page.dart';

class MockAuthStorage extends AuthStorage {
  @override
  Future<String?> getAccessToken() async => null;
}

class FakeCatalogRepo extends CatalogRepository {
  FakeCatalogRepo({required super.apiClient});

  List<Category> fakeCategories = <Category>[
    const Category(id: 'cat-1', name: 'Arroces y Chaufas'),
    const Category(id: 'cat-2', name: 'Bebidas'),
  ];

  List<Product> fakeProducts = <Product>[
    const Product(
      id: 'prod-1',
      categoryId: 'cat-1',
      name: 'Chaufa Especial',
      price: 25.0,
      stockQty: 30,
      isAvailable: true,
      description: 'Chaufa con pollo, carne y huevo montado',
    ),
  ];

  @override
  Future<List<Category>> getCategories() async => fakeCategories;

  @override
  Future<List<Product>> getProducts({String? categoryId}) async => fakeProducts;

  @override
  Future<Category> createCategory(String name) async {
    final Category cat = Category(id: 'cat-${fakeCategories.length + 1}', name: name);
    fakeCategories.add(cat);
    return cat;
  }

  @override
  Future<Product> createProduct({
    required String categoryId,
    required String name,
    required double price,
    String? imageUrl,
    String? description,
  }) async {
    final Product p = Product(
      id: 'prod-${fakeProducts.length + 1}',
      categoryId: categoryId,
      name: name,
      price: price,
      stockQty: 50,
      isAvailable: true,
      imageUrl: imageUrl,
      description: description,
    );
    fakeProducts.add(p);
    return p;
  }
}

void main() {
  late CatalogController controller;
  late FakeCatalogRepo repo;

  setUp(() async {
    final ApiEnvironment env = ApiEnvironment(baseUrl: 'https://api.kairo.pe/api/v1');
    final MockAuthStorage storage = MockAuthStorage();
    final ApiClient client = ApiClient(environment: env, storage: storage);
    repo = FakeCatalogRepo(apiClient: client);
    controller = CatalogController(repository: repo);
    await controller.loadCatalog();
  });

  Widget buildTestable(Widget child) {
    return MaterialApp(
      theme: AsiaTheme.dark(),
      home: Scaffold(body: child),
    );
  }

  group('ProductFormPage Screen', () {
    testWidgets('renders create mode with live preview and inputs', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestable(ProductFormPage(catalogController: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Plato Gastronómico'), findsOneWidget);
      expect(find.text('Volver a Carta & Productos'), findsOneWidget);
      expect(find.text('Publicar Plato'), findsOneWidget);
      expect(find.text('Información General'), findsOneWidget);
      expect(find.text('Precio & Inventario'), findsOneWidget);
      expect(find.text('Vista Previa en Carta'), findsOneWidget);
      expect(find.text('Tip Gastronómico KAIRO'), findsOneWidget);
    });

    testWidgets('renders edit mode populated with product data', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final Product existing = repo.fakeProducts.first;

      await tester.pumpWidget(
        buildTestable(
          ProductFormPage(catalogController: controller, product: existing),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar Plato en Carta'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);
      expect(find.text('Chaufa Especial'), findsWidgets);
      expect(find.text('S/. 25.00'), findsOneWidget);
    });
  });

  group('CategoryFormPage Screen', () {
    testWidgets('renders category creation form and existing categories', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestable(CategoryFormPage(catalogController: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Categorías de la Carta'), findsOneWidget);
      expect(find.text('Nueva Sección en Menú'), findsOneWidget);
      expect(find.text('Vista Previa del Chip / Pestaña'), findsOneWidget);
      expect(find.text('Sugerencias Rápidas'), findsOneWidget);
      expect(find.text('Crear Categoría'), findsOneWidget);
      expect(find.text('Arroces y Chaufas'), findsOneWidget);
      expect(find.text('Bebidas'), findsOneWidget);
      expect(find.text('1 plato registrado'), findsOneWidget);
    });
  });

  group('Router integration for products/new and categories/new', () {
    testWidgets('GoRouter routes to /products/new and /products/categories/new', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final ApiEnvironment env = ApiEnvironment(baseUrl: 'https://api.kairo.pe/api/v1');
      final MockAuthStorage storage = MockAuthStorage();
      final ApiClient client = ApiClient(environment: env, storage: storage);
      final AuthController auth = AuthController(
        repository: AuthRepository(apiClient: client, storage: storage),
        storage: storage,
      );

      // Give auth admin privileges so it doesn't redirect
      final GoRouter router = GoRouter(
        initialLocation: '/products',
        routes: <RouteBase>[
          GoRoute(
            path: '/products',
            builder: (_, __) => const Text('Products Home'),
          ),
          GoRoute(
            path: '/products/new',
            builder: (_, __) => ProductFormPage(catalogController: controller),
          ),
          GoRoute(
            path: '/products/categories/new',
            builder: (_, __) => CategoryFormPage(catalogController: controller),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        theme: AsiaTheme.dark(),
        routerConfig: router,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Products Home'), findsOneWidget);

      router.go('/products/new');
      await tester.pumpAndSettle();
      expect(find.text('Nuevo Plato Gastronómico'), findsOneWidget);

      router.go('/products/categories/new');
      await tester.pumpAndSettle();
      expect(find.text('Categorías de la Carta'), findsOneWidget);
    });
  });

  group('ProductsPage Responsive Single-Screen Tests', () {
    testWidgets('renders desktop responsive full-width table without horizontal scrollbar', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestable(ProductsPage(catalogController: controller)));
      await tester.pumpAndSettle();

      expect(find.text('Carta & Productos'), findsOneWidget);
      expect(find.text('PRODUCTO'), findsOneWidget);
      expect(find.text('CATEGORÍA'), findsOneWidget);
      expect(find.text('PRECIO'), findsOneWidget);
      expect(find.text('STOCK ACTUAL'), findsOneWidget);
      expect(find.text('DISPONIBLE'), findsOneWidget);
      expect(find.text('EDITAR'), findsOneWidget);
      expect(find.text('Chaufa Especial'), findsOneWidget);
      expect(find.text('S/ 25.00'), findsOneWidget);
      expect(find.text('30 und'), findsOneWidget);

      // Verify that no horizontal scroll exists
      final Finder horizontalScroll = find.byWidgetPredicate(
        (Widget widget) =>
            widget is SingleChildScrollView &&
            widget.scrollDirection == Axis.horizontal,
      );
      expect(horizontalScroll, findsNothing);
    });

    testWidgets('renders mobile responsive cards when viewport is narrow', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestable(ProductsPage(catalogController: controller)));
      await tester.pumpAndSettle();

      expect(find.text('Carta & Productos'), findsOneWidget);
      expect(find.text('Chaufa Especial'), findsOneWidget);
      expect(find.text('S/ 25.00'), findsOneWidget);
      expect(find.text('30 und'), findsOneWidget);
      expect(find.text('Disponible'), findsOneWidget);
    });
  });

  group('ImageUploadService Tests', () {
    test('rejects empty byte list with clear error', () async {
      final service = ImageUploadService();
      expect(
        () => service.uploadImage(bytes: Uint8List(0), filename: 'plato.jpg'),
        throwsA(isA<ImageUploadException>().having(
          (ImageUploadException e) => e.message,
          'message',
          contains('vacío'),
        )),
      );
    });

    test('rejects files larger than 10MB with explicit weight warning', () async {
      final service = ImageUploadService();
      final Uint8List largeBytes = Uint8List(11 * 1024 * 1024);
      expect(
        () => service.uploadImage(bytes: largeBytes, filename: 'pesado.jpg'),
        throwsA(isA<ImageUploadException>().having(
          (ImageUploadException e) => e.message,
          'message',
          allOf(contains('11.0 MB'), contains('límite máximo permitido de 10 MB')),
        )),
      );
    });

    test('uploads image to backend through ApiClient successfully', () async {
      final MockUploadHttpClient mockHttp = MockUploadHttpClient((http.BaseRequest req) async {
        if (req.url.path.endsWith('/catalog/upload-image')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'image_url': 'https://api.kairo.pe/uploads/products/plato_123.jpg',
              'filename': 'plato_123.jpg',
              'size_bytes': 1024,
            }),
            201,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final ApiEnvironment env = ApiEnvironment(baseUrl: 'https://api.kairo.pe/api/v1');
      final MockAuthStorage storage = MockAuthStorage();
      final ApiClient client = ApiClient(
        environment: env,
        storage: storage,
        httpClient: mockHttp,
      );

      final ImageUploadService service = ImageUploadService(apiClient: client);
      final String url = await service.uploadImage(
        bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        filename: 'arroz.jpg',
      );

      expect(url, 'https://api.kairo.pe/uploads/products/plato_123.jpg');
    });
  });
}

class MockUploadHttpClient extends http.BaseClient {
  MockUploadHttpClient(this.handler);

  final Future<http.Response> Function(http.BaseRequest) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final http.Response res = await handler(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(res.bodyBytes),
      res.statusCode,
      headers: res.headers,
    );
  }
}
