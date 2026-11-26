import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../domain/order_models.dart';
import '../infrastructure/order_repository.dart';

class OrderController extends ChangeNotifier {
  OrderController({required this.repository});

  final OrderRepository repository;

  List<StaffOrder> _orders = <StaffOrder>[];
  OrderStatus? _statusFilter;
  OrderModality? _modalityFilter;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<StaffOrder> get orders => _orders;
  OrderStatus? get statusFilter => _statusFilter;
  OrderModality? get modalityFilter => _modalityFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;

  List<StaffOrder> get filteredOrders {
    return _orders.where((StaffOrder order) {
      final bool matchesStatus =
          _statusFilter == null || order.status == _statusFilter;
      final bool matchesModality =
          _modalityFilter == null || order.modality == _modalityFilter;
      final bool matchesSearch =
          _searchQuery.isEmpty ||
          order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (order.contactName?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false) ||
          (order.tableId?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesStatus && matchesModality && matchesSearch;
    }).toList();
  }

  Future<void> loadOrders({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _orders = await repository.getOrders();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar la lista de pedidos.';
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setModalityFilter(OrderModality? modality) {
    _modalityFilter = modality;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> decideOrder(String orderId, {required bool approved}) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final StaffOrder updated = await repository.decideOrder(
        orderId,
        approved: approved,
      );
      _updateOrderInList(updated);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmOrder(String orderId) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final StaffOrder updated = await repository.confirmOrder(orderId);
      _updateOrderInList(updated);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fulfillOrder(String orderId, OrderModality modality) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      switch (modality) {
        case OrderModality.local:
          await repository.serveOrder(orderId);
          break;
        case OrderModality.pickup:
          await repository.pickupOrder(orderId);
          break;
        case OrderModality.delivery:
          await repository.deliverOrder(orderId);
          break;
      }
      // Reload order details
      final StaffOrder reloaded = await repository.getOrder(orderId);
      _updateOrderInList(reloaded);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> closeOrder(String orderId) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.closeOrder(orderId);
      final StaffOrder reloaded = await repository.getOrder(orderId);
      _updateOrderInList(reloaded);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordPayment({
    required String orderId,
    required double amount,
    required String methodCode,
    String? referenceCode,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.recordPayment(
        orderId: orderId,
        amount: amount,
        methodCode: methodCode,
        referenceCode: referenceCode,
      );
      final StaffOrder reloaded = await repository.getOrder(orderId);
      _updateOrderInList(reloaded);
      _isActionLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo registrar el cobro.';
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<StaffOrder?> createTableOrder({
    required String tableId,
    required List<Map<String, dynamic>> items,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final StaffOrder created = await repository.createOrder(
        modality: 'LOCAL',
        tableId: tableId,
        items: items,
      );
      // Auto-approve and confirm local table order for staff/admin
      await repository.decideOrder(
        created.id,
        approved: true,
        tableVerified: true,
      );
      final StaffOrder confirmed = await repository.confirmOrder(created.id);
      _updateOrderInList(confirmed);
      _isActionLoading = false;
      notifyListeners();
      return confirmed;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isActionLoading = false;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'No se pudo crear el pedido para la mesa.';
      _isActionLoading = false;
      notifyListeners();
      return null;
    }
  }

  void _updateOrderInList(StaffOrder updated) {
    final int idx = _orders.indexWhere((StaffOrder o) => o.id == updated.id);
    if (idx != -1) {
      _orders[idx] = updated;
    } else {
      _orders = <StaffOrder>[updated, ..._orders];
    }
  }
}
