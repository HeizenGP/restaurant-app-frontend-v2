import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_storage.dart';
import '../domain/auth_models.dart';
import '../infrastructure/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.repository, required this.storage});

  final AuthRepository repository;
  final AuthStorage storage;

  StaffUser? _currentUser;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  StaffUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isCashier => _currentUser?.isCashier ?? false;
  bool get isWaiter => _currentUser?.isWaiter ?? false;
  bool get isKitchen => _currentUser?.isKitchen ?? false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      final String? token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // First try to load cached user for instant render
        final Map<String, dynamic>? cached = await storage.getUserData();
        if (cached != null) {
          _currentUser = StaffUser.fromJson(cached);
        }

        // Then verify against the live backend
        try {
          _currentUser = await repository.getCurrentUser();
        } catch (e) {
          // If token expired, clear
          if (e is ApiException && e.statusCode == 401) {
            await storage.clear();
            _currentUser = null;
          }
        }
      }
    } catch (_) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final StaffSession session = await repository.login(
        email: email,
        password: password,
      );
      _currentUser = session.user;

      _currentUser ??= await repository.getCurrentUser();

      // Check that user is not just a customer without staff access
      if (!_currentUser!.roles.any((RoleCode r) => r != RoleCode.customer)) {
        _errorMessage = 'Tu cuenta no tiene privilegios de personal (Mozo, Cajero, Cocina o Admin).';
        await logout();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado de conexión con el servidor.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await repository.logout();
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
