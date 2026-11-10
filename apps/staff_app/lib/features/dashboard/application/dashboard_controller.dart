import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../domain/dashboard_models.dart';
import '../infrastructure/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({required this.repository});

  final DashboardRepository repository;

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _stats = await repository.getStats();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar las estadísticas del dashboard.';
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> refresh({bool silent = false}) async {
    await loadDashboard(silent: silent);
  }
}
