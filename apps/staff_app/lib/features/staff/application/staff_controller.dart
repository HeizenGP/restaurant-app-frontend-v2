import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../auth/domain/auth_models.dart';
import '../infrastructure/staff_repository.dart';

class StaffController extends ChangeNotifier {
  StaffController({required this.repository});

  final StaffRepository repository;

  List<StaffUser> _staffList = <StaffUser>[];
  RoleCode? _roleFilter;
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<StaffUser> get staffList => _staffList;
  RoleCode? get roleFilter => _roleFilter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<StaffUser> get filteredStaff {
    return _staffList.where((StaffUser user) {
      if (!user.isStaff) return false;
      final bool matchesRole = _roleFilter == null || user.hasRole(_roleFilter!);
      final bool matchesSearch = _searchQuery.isEmpty ||
          user.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (user.phone?.contains(_searchQuery) ?? false);
      return matchesRole && matchesSearch;
    }).toList();
  }

  Future<void> loadStaff() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<StaffUser> list = await repository.getStaffList();
      _staffList = list.where((StaffUser u) => u.isStaff).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar el personal administrativo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRoleFilter(RoleCode? role) {
    _roleFilter = role;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> createStaff({
    required String displayName,
    required String email,
    required String password,
    required RoleCode role,
    String? phone,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final StaffUser created = await repository.createStaffMember(
        displayName: displayName,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
      _staffList = <StaffUser>[created, ..._staffList];
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

  Future<bool> toggleUserStatus(String userId, bool newStatus) async {
    try {
      final StaffUser updated = await repository.setUserStatus(userId, newStatus);
      final int idx = _staffList.indexWhere((StaffUser u) => u.id == userId);
      if (idx != -1) {
        _staffList[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> assignRole(String userId, RoleCode role) async {
    try {
      final StaffUser updated = await repository.assignRole(userId, role);
      final int idx = _staffList.indexWhere((StaffUser u) => u.id == userId);
      if (idx != -1) {
        _staffList[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
