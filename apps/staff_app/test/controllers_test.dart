import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/api_environment.dart';
import 'package:staff_app/core/network/api_client.dart';
import 'package:staff_app/core/storage/auth_storage.dart';
import 'package:staff_app/features/orders/application/order_controller.dart';
import 'package:staff_app/features/orders/domain/order_models.dart';
import 'package:staff_app/features/orders/infrastructure/order_repository.dart';
import 'package:staff_app/features/payments/application/payment_controller.dart';
import 'package:staff_app/features/payments/domain/payment_models.dart';
import 'package:staff_app/features/payments/infrastructure/payment_repository.dart';
import 'package:staff_app/features/products/application/catalog_controller.dart';
import 'package:staff_app/features/products/domain/catalog_models.dart';
import 'package:staff_app/features/products/infrastructure/catalog_repository.dart';

class FakePaymentRepository extends PaymentRepository {
  FakePaymentRepository({required super.apiClient});

  List<PaymentRecord> fakeRecords = <PaymentRecord>[
    PaymentRecord(
      id: 'p-1',
      orderId: 'ord-100',
      kind: 'COLLECTION',
      amount: 45.0,
      methodCode: 'EFECTIVO',
      recordedByUserId: 'u1',
      recordedAt: DateTime.now(),
    ),
    PaymentRecord(
      id: 'p-2',
      orderId: 'ord-200',
      kind: 'COLLECTION',
      amount: 60.0,
      methodCode: 'YAPE',
      referenceCode: '998877',
      recordedByUserId: 'u1',
      recordedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<PaymentRecord>> getPayments({int limit = 100}) async => fakeRecords;

  @override
  Future<OrderPaymentSummary> recordCollection({
    required String orderId,
    required double amount,
    required String methodCode,
    String? referenceCode,
  }) async {
    final PaymentRecord rec = PaymentRecord(
      id: 'p-${fakeRecords.length + 1}',
      orderId: orderId,
      kind: 'COLLECTION',
      amount: amount,
      methodCode: methodCode,
      referenceCode: referenceCode,
      recordedByUserId: 'u1',
      recordedAt: DateTime.now(),
    );
    fakeRecords.add(rec);
    return OrderPaymentSummary(
      orderId: orderId,
      orderTotal: amount,
      totalPaid: amount,
      balance: 0.0,
      isSettled: true,
      payments: <PaymentRecord>[rec],
    );
  }
}

class FakeCatalogRepository extends CatalogRepository {
  FakeCatalogRepository({required super.apiClient});

  List<Category> fakeCategories = <Category>[
    const Category(id: 'cat-1', name: 'Chaufas'),
    const Category(id: 'cat-2', name: 'Bebidas'),
  ];

  List<Product> fakeProducts = <Product>[
    const Product(id: 'pr-1', categoryId: 'cat-1', name: 'Chaufa Especial', price: 28.0, stockQty: 15, isAvailable: true),
    const Product(id: 'pr-2', categoryId: 'cat-2', name: 'Té Jazmín', price: 8.0, stockQty: 3, isAvailable: true),
  ];

  @override
  Future<List<Category>> getCategories() async => fakeCategories;

  @override
  Future<List<Product>> getProducts({String? categoryId}) async => fakeProducts;
}

class FakeOrderRepository extends OrderRepository {
  FakeOrderRepository({required super.apiClient});

  List<StaffOrder> fakeOrders = <StaffOrder>[
    StaffOrder(
      id: 'ord-1',
      modality: OrderModality.local,
      channel: 'TABLE_QR',
      status: OrderStatus.confirmed,
      totalAmount: 50.0,
      createdAt: DateTime.now(),
      items: const <OrderItem>[],
    ),
    StaffOrder(
      id: 'ord-2',
      modality: OrderModality.pickup,
      channel: 'DIRECT_APP',
      status: OrderStatus.closed,
      totalAmount: 35.0,
      createdAt: DateTime.now(),
      items: const <OrderItem>[],
    ),
  ];

  @override
  Future<List<StaffOrder>> getOrders({OrderStatus? status, OrderModality? modality}) async => fakeOrders;
}

void main() {
  late ApiClient apiClient;

  setUp(() {
    apiClient = ApiClient(
      environment: ApiEnvironment(baseUrl: 'https://api.kairo.pe/api/v1'),
      storage: AuthStorage(),
    );
  });

  group('PaymentController Tests', () {
    test('Calculates total collected and filters by payment method', () async {
      final FakePaymentRepository repo = FakePaymentRepository(apiClient: apiClient);
      final PaymentController controller = PaymentController(repository: repo);

      await controller.loadPayments();
      expect(controller.payments.length, 2);
      expect(controller.totalCollected, 105.0);

      controller.setMethodFilter('YAPE');
      expect(controller.filteredPayments.length, 1);
      expect(controller.filteredPayments.first.methodCode, 'YAPE');

      controller.setMethodFilter(null);
      controller.setSearchQuery('998877');
      expect(controller.filteredPayments.length, 1);
      expect(controller.filteredPayments.first.referenceCode, '998877');
    });

    test('Records a new collection successfully', () async {
      final FakePaymentRepository repo = FakePaymentRepository(apiClient: apiClient);
      final PaymentController controller = PaymentController(repository: repo);

      await controller.loadPayments();
      final bool success = await controller.recordCollection(
        orderId: 'ord-300',
        amount: 80.0,
        methodCode: 'PLIN',
      );

      expect(success, isTrue);
      expect(controller.payments.length, 3);
      expect(controller.totalCollected, 185.0);
    });
  });

  group('CatalogController Tests', () {
    test('Loads categories and filters products', () async {
      final FakeCatalogRepository repo = FakeCatalogRepository(apiClient: apiClient);
      final CatalogController controller = CatalogController(repository: repo);

      await controller.loadCatalog();
      expect(controller.categories.length, 2);
      expect(controller.products.length, 2);

      controller.selectCategory('cat-1');
      expect(controller.filteredProducts.length, 1);
      expect(controller.filteredProducts.first.name, 'Chaufa Especial');

      controller.selectCategory(null);
      controller.setSearchQuery('Jazmín');
      expect(controller.filteredProducts.length, 1);
      expect(controller.filteredProducts.first.name, 'Té Jazmín');
    });
  });

  group('OrderController Tests', () {
    test('Filters orders by status and modality', () async {
      final FakeOrderRepository repo = FakeOrderRepository(apiClient: apiClient);
      final OrderController controller = OrderController(repository: repo);

      await controller.loadOrders();
      expect(controller.orders.length, 2);

      controller.setStatusFilter(OrderStatus.confirmed);
      expect(controller.filteredOrders.length, 1);
      expect(controller.filteredOrders.first.id, 'ord-1');

      controller.setStatusFilter(null);
      controller.setModalityFilter(OrderModality.pickup);
      expect(controller.filteredOrders.length, 1);
      expect(controller.filteredOrders.first.id, 'ord-2');
    });
  });
}
