import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../domain/payment_models.dart';
import '../infrastructure/payment_repository.dart';

class PaymentController extends ChangeNotifier {
  PaymentController({required this.repository});

  final PaymentRepository repository;

  List<PaymentRecord> _payments = <PaymentRecord>[];
  String? _methodFilter;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<PaymentRecord> get payments => _payments;
  String? get methodFilter => _methodFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<PaymentRecord> get filteredPayments {
    return _payments.where((PaymentRecord p) {
      final bool matchesMethod = _methodFilter == null ||
          _methodFilter!.isEmpty ||
          p.methodCode == _methodFilter ||
          (p.kind == 'ADVANCE' && _methodFilter == 'ADVANCE');
      final bool matchesSearch = _searchQuery.isEmpty ||
          p.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.referenceCode?.contains(_searchQuery) ?? false);
      return matchesMethod && matchesSearch;
    }).toList();
  }

  double get totalCollected =>
      _payments.fold(0.0, (double acc, PaymentRecord p) => acc + p.amount);

  Future<void> loadPayments({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _payments = await repository.getPayments();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar el historial de pagos y cobros.';
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void setMethodFilter(String? method) {
    _methodFilter = method;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> recordCollection({
    required String orderId,
    required double amount,
    required String methodCode,
    String? referenceCode,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.recordCollection(
        orderId: orderId,
        amount: amount,
        methodCode: methodCode,
        referenceCode: referenceCode,
      );
      // Reload payments
      _payments = await repository.getPayments();
      _isSaving = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
