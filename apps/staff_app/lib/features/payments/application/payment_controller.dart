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
  TableAccountSummary? _selectedTableAccount;
  CashRegisterSession? _currentSession;
  final List<CashRegisterSession> _sessionHistory = <CashRegisterSession>[];

  List<PaymentRecord> get payments => _payments;
  String? get methodFilter => _methodFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  TableAccountSummary? get selectedTableAccount => _selectedTableAccount;
  CashRegisterSession? get currentSession => _currentSession;
  bool get isCashRegisterOpen =>
      _currentSession != null && _currentSession!.isOpen;
  List<CashRegisterSession> get sessionHistory => _sessionHistory;

  double get sessionInitialAmount => _currentSession?.initialAmount ?? 0.0;

  double get sessionCashCollected {
    if (_currentSession == null) return 0.0;
    final DateTime sessionOpenedUtc = _currentSession!.openedAt.toUtc();
    return _payments
        .where(
          (PaymentRecord p) =>
              !p.recordedAt.toUtc().isBefore(sessionOpenedUtc) &&
              (p.methodCode == 'EFECTIVO' || p.kind == 'ADVANCE'),
        )
        .fold(0.0, (double acc, PaymentRecord p) => acc + p.amount);
  }

  double get sessionDigitalCollected {
    if (_currentSession == null) return 0.0;
    final DateTime sessionOpenedUtc = _currentSession!.openedAt.toUtc();
    return _payments
        .where(
          (PaymentRecord p) =>
              !p.recordedAt.toUtc().isBefore(sessionOpenedUtc) &&
              p.methodCode != 'EFECTIVO' &&
              p.kind != 'ADVANCE',
        )
        .fold(0.0, (double acc, PaymentRecord p) => acc + p.amount);
  }

  double get sessionTotalExpectedCash =>
      sessionInitialAmount + sessionCashCollected;

  void openCashRegister({
    required double initialAmount,
    required String userName,
    String? notes,
  }) {
    _currentSession = CashRegisterSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      openedAt: DateTime.now().toUtc(),
      openedByUserName: userName,
      initialAmount: initialAmount,
      openingNotes: notes,
      isOpen: true,
    );
    notifyListeners();
  }

  void closeCashRegister({
    required double realAmount,
    required String userName,
    String? notes,
  }) {
    if (_currentSession == null) return;
    final double expected = sessionTotalExpectedCash;
    final double diff = realAmount - expected;
    final CashRegisterSession closed = _currentSession!.copyWith(
      closedAt: DateTime.now(),
      closedByUserName: userName,
      finalAmount: expected,
      realAmount: realAmount,
      difference: diff,
      closingNotes: notes,
      isOpen: false,
    );
    _sessionHistory.insert(0, closed);
    _currentSession = null;
    notifyListeners();
  }

  List<PaymentRecord> get filteredPayments {
    return _payments.where((PaymentRecord p) {
      final bool matchesMethod =
          _methodFilter == null ||
          _methodFilter!.isEmpty ||
          p.methodCode == _methodFilter ||
          (p.kind == 'ADVANCE' && _methodFilter == 'ADVANCE');
      final bool matchesSearch =
          _searchQuery.isEmpty ||
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

  Future<TableAccountSummary?> loadTableAccount(String tableId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedTableAccount = await repository.getTableAccount(tableId);
      return _selectedTableAccount;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (_) {
      _errorMessage = 'No se pudo cargar la cuenta de la mesa.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TableAccountSummary?> recordTableAccountPayment({
    required String tableId,
    required double amount,
    required String methodCode,
    String? referenceCode,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedTableAccount = await repository.recordTableAccountPayment(
        tableId: tableId,
        amount: amount,
        methodCode: methodCode,
        referenceCode: referenceCode,
      );
      _payments = await repository.getPayments();
      return _selectedTableAccount;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (_) {
      _errorMessage = 'No se pudo cobrar la cuenta de la mesa.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
