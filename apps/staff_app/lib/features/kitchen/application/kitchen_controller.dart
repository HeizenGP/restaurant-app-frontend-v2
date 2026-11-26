import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../domain/kitchen_models.dart';
import '../infrastructure/kitchen_repository.dart';

class KitchenController extends ChangeNotifier {
  KitchenController({required this.repository});

  final KitchenRepository repository;

  List<KitchenTicket> _tickets = <KitchenTicket>[];
  String? _modalityFilter;
  bool _isLoading = false;
  String? _updatingTicketId;
  String? _errorMessage;

  List<KitchenTicket> get tickets => _tickets;
  String? get modalityFilter => _modalityFilter;
  bool get isLoading => _isLoading;
  String? get updatingTicketId => _updatingTicketId;
  String? get errorMessage => _errorMessage;

  List<KitchenTicket> get filteredTickets {
    if (_modalityFilter == null) return _tickets;
    return _tickets
        .where(
          (KitchenTicket t) =>
              t.modality.toUpperCase() == _modalityFilter!.toUpperCase(),
        )
        .toList();
  }

  List<KitchenTicket> get receivedTickets => filteredTickets
      .where((KitchenTicket t) => t.status == KitchenTicketStatus.received)
      .toList();

  List<KitchenTicket> get preparingTickets => filteredTickets
      .where((KitchenTicket t) => t.status == KitchenTicketStatus.preparing)
      .toList();

  List<KitchenTicket> get readyTickets => filteredTickets
      .where((KitchenTicket t) => t.status == KitchenTicketStatus.ready)
      .toList();

  void setModalityFilter(String? modality) {
    _modalityFilter = modality;
    notifyListeners();
  }

  Future<void> loadTickets({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _tickets = await repository.getTickets();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Error al cargar las comandas de cocina.';
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<bool> startTicket(String ticketId) async {
    _updatingTicketId = ticketId;
    _errorMessage = null;
    notifyListeners();

    try {
      final KitchenTicket updated = await repository.startTicket(ticketId);
      _replaceTicket(updated);
      _updatingTicketId = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _updatingTicketId = null;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo iniciar la preparación.';
      _updatingTicketId = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> markReady(String ticketId) async {
    _updatingTicketId = ticketId;
    _errorMessage = null;
    notifyListeners();

    try {
      final KitchenTicket updated = await repository.markTicketReady(ticketId);
      _replaceTicket(updated);
      _updatingTicketId = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _updatingTicketId = null;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No se pudo marcar el pedido como listo.';
      _updatingTicketId = null;
      notifyListeners();
      return false;
    }
  }

  void _replaceTicket(KitchenTicket updated) {
    final int idx = _tickets.indexWhere((KitchenTicket t) => t.id == updated.id);
    if (idx != -1) {
      _tickets[idx] = updated;
    } else {
      _tickets = <KitchenTicket>[updated, ..._tickets];
    }
  }
}
