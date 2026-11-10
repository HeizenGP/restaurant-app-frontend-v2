import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/auth/domain/auth_models.dart';
import 'package:staff_app/features/dashboard/domain/dashboard_models.dart';
import 'package:staff_app/features/inventory/domain/inventory_models.dart';
import 'package:staff_app/features/orders/domain/order_models.dart';
import 'package:staff_app/features/payments/domain/payment_models.dart';
import 'package:staff_app/features/products/domain/catalog_models.dart';
import 'package:staff_app/features/tables/domain/table_models.dart';

void main() {
  group('Auth Models', () {
    test('StaffUser parses json and determines roles correctly', () {
      final StaffUser user = StaffUser.fromJson(<String, dynamic>{
        'id': 'usr-123',
        'email': 'admin@kairo.pe',
        'display_name': 'Chef Carlos',
        'phone': '987654321',
        'is_active': true,
        'roles': <String>['ADMIN', 'CASHIER'],
      });

      expect(user.id, 'usr-123');
      expect(user.displayName, 'Chef Carlos');
      expect(user.isAdmin, isTrue);
      expect(user.isCashier, isTrue);
      expect(user.isWaiter, isFalse);
    });

    test('Super admin has full privileges', () {
      final StaffUser superUser = StaffUser.fromJson(<String, dynamic>{
        'id': 'super-1',
        'email': 'super@kairo.pe',
        'display_name': 'Owner',
        'roles': <String>['SUPER_ADMIN'],
      });

      expect(superUser.isAdmin, isTrue);
      expect(superUser.isCashier, isTrue);
      expect(superUser.isWaiter, isTrue);
      expect(superUser.isKitchen, isTrue);
    });
  });

  group('Catalog Models', () {
    test('Product parses json and checks low stock correctly', () {
      final Product p1 = Product.fromJson(<String, dynamic>{
        'id': 'prod-1',
        'name': 'Arroz Chaufa Especial',
        'price': 28.50,
        'stock_qty': 4,
        'is_available': true,
      });

      expect(p1.isLowStock, isTrue);

      final Product p2 = Product.fromJson(<String, dynamic>{
        'id': 'prod-2',
        'name': 'Tallarín Saltado',
        'price': 32.00,
        'stock_qty': 25,
        'is_available': true,
      });

      expect(p2.isLowStock, isFalse);

      final Product p3 = Product.fromJson(<String, dynamic>{
        'id': 'prod-3',
        'name': 'Aeropuerto Especial',
        'price': '25.00',
        'available_for_sale': true,
      });

      expect(p3.price, 25.00);
      expect(p3.isAvailable, isTrue);
    });
  });

  group('Order Models', () {
    test(
      'StaffOrder parses json and calculates modality and status labels',
      () {
        final StaffOrder order = StaffOrder.fromJson(<String, dynamic>{
          'id': 'ord-999',
          'modality': 'LOCAL',
          'channel': 'TABLE_QR',
          'status': 'CONFIRMED',
          'total_amount': 75.50,
          'created_at': '2026-11-07T12:00:00Z',
          'table_id': 'tbl-4',
          'items': <dynamic>[
            <String, dynamic>{
              'id': 'item-1',
              'product_id': 'prod-1',
              'product_name': 'Arroz Chaufa',
              'unit_price': 25.00,
              'quantity': 2,
              'subtotal': 50.00,
            },
          ],
        });

        expect(order.modality.displayName, 'Mesa / Salón');
        expect(order.status.displayName, 'Confirmado');
        expect(order.items.length, 1);
        expect(order.items.first.subtotal, 50.00);
      },
    );

    test('parses the backend lines contract and decimal strings', () {
      final StaffOrder order = StaffOrder.fromJson(<String, dynamic>{
        'id': 'ord-render',
        'modality': 'LOCAL',
        'channel': 'APP',
        'status': 'REQUESTED',
        'total_amount': '25.00',
        'created_at': '2026-11-07T12:00:00Z',
        'table_id': 'table-1',
        'lines': <dynamic>[
          <String, dynamic>{
            'product_id': 'product-1',
            'product_name_snapshot': 'Chaufa',
            'unit_price_snapshot': '12.50',
            'quantity': 2,
          },
        ],
      });

      expect(order.status, OrderStatus.requested);
      expect(order.totalAmount, 25.0);
      expect(order.items.single.productName, 'Chaufa');
      expect(order.items.single.subtotal, 25.0);
    });
  });

  group('Payment Models', () {
    test('PaymentRecord parses and identifies method labels', () {
      final PaymentRecord record = PaymentRecord.fromJson(<String, dynamic>{
        'id': 'pay-1',
        'order_id': 'ord-999',
        'kind': 'COLLECTION',
        'amount': 75.50,
        'method_code': 'YAPE',
        'reference_code': '128492',
        'recorded_by_user_id': 'usr-123',
        'recorded_at': '2026-11-07T12:30:00Z',
      });

      expect(record.amount, 75.50);
      expect(record.methodLabel, 'YAPE');
      expect(record.referenceCode, '128492');
    });

    test('parses a consolidated table account with orders and balances', () {
      final TableAccountSummary account = TableAccountSummary.fromJson(
        <String, dynamic>{
          'id': 'account-1',
          'table_id': 'table-1',
          'table_code': 'Mesa 1',
          'status': 'OPEN',
          'total_amount': '30.00',
          'advance_amount': '0.00',
          'paid_amount': '10.00',
          'balance': '20.00',
          'orders': <dynamic>[
            <String, dynamic>{
              'id': 'order-1',
              'status': 'CONFIRMED',
              'total_amount': '30.00',
              'paid_amount': '10.00',
              'balance': '20.00',
              'lines': <dynamic>[
                <String, dynamic>{
                  'product_name': 'Chaufa',
                  'quantity': 2,
                  'unit_price': '15.00',
                  'subtotal': '30.00',
                },
              ],
            },
          ],
        },
      );

      expect(account.balance, 20.0);
      expect(account.orders.single.lines.single.productName, 'Chaufa');
    });
  });

  group('Table and Inventory Models', () {
    test('RestaurantTable parses QR code and occupancy', () {
      final RestaurantTable table = RestaurantTable.fromJson(<String, dynamic>{
        'id': 'tbl-1',
        'code': 'M-01',
        'area_label': 'Terraza',
        'is_occupied': true,
      });

      expect(table.code, 'M-01');
      expect(table.areaLabel, 'Terraza');
      expect(table.isOccupied, isTrue);
    });

    test('StockMovement parses audit entries', () {
      final StockMovement move = StockMovement.fromJson(<String, dynamic>{
        'id': 'mov-1',
        'product_id': 'prod-1',
        'product_name': 'Sillao Especial',
        'kind': 'RECEPTION',
        'quantity_delta': 50,
        'recorded_at': '2026-11-07T08:00:00Z',
      });

      expect(move.quantityDelta, 50);
      expect(move.kind, 'RECEPTION');
    });
  });

  group('Dashboard Models', () {
    test('DashboardStats parses KPIs and modalities correctly', () {
      final DashboardStats stats = DashboardStats.fromJson(<String, dynamic>{
        'today_sales': 1250.80,
        'today_orders_count': 35,
        'active_orders_count': 4,
        'occupied_tables_count': 8,
        'total_tables_count': 12,
        'total_products_count': 48,
        'low_stock_count': 3,
        'orders_by_modality': <String, dynamic>{
          'DINE_IN': 25,
          'TAKEAWAY': 6,
          'DELIVERY': 4,
        },
        'orders_by_status': <String, dynamic>{'DELIVERED': 31, 'PREPARING': 4},
        'top_products': <dynamic>[
          <String, dynamic>{'name': 'Chaufa Especial', 'total_quantity': 42},
        ],
        'recent_orders': <dynamic>[],
      });

      expect(stats.todaySales, 1250.80);
      expect(stats.occupiedTablesCount, 8);
      expect(stats.topProducts.first.name, 'Chaufa Especial');
      expect(stats.topProducts.first.totalQuantity, 42);
    });

    test(
      'DashboardStats handles strings and nulls safely without crashing',
      () {
        final DashboardStats stats = DashboardStats.fromJson(<String, dynamic>{
          'today_sales': '1450.50',
          'today_orders_count': '15',
          'active_orders_count': 2,
          'occupied_tables_count': '3',
          'total_tables_count': 10,
          'total_products_count': '25',
          'low_stock_count': null,
          'orders_by_modality': <String, dynamic>{'LOCAL': '8', 'DELIVERY': 5},
          'orders_by_status': <String, dynamic>{'CONFIRMED': '3'},
          'top_products': <dynamic>[
            <String, dynamic>{'name': 'Aeropuerto', 'total_quantity': '18'},
          ],
          'recent_orders': <dynamic>[
            <String, dynamic>{
              'id': 'abc', // Short ID
              'modality': 'LOCAL',
              'channel': 'TABLE_QR',
              'status': 'CONFIRMED',
              'total_amount': '35.00',
              'table_id': '1', // Short table ID
            },
          ],
        });

        expect(stats.todaySales, 1450.50);
        expect(stats.todayOrdersCount, 15);
        expect(stats.lowStockCount, 0);
        expect(stats.ordersByModality['LOCAL'], 8);
        expect(stats.topProducts.first.totalQuantity, 18);
        expect(stats.recentOrders.first.id, 'abc');
        expect(stats.recentOrders.first.tableId, '1');
      },
    );
  });
}
