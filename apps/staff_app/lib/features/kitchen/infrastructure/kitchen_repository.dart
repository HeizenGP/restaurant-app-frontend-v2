import '../../../core/network/api_client.dart';
import '../domain/kitchen_models.dart';

class KitchenRepository {
  const KitchenRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<List<KitchenTicket>> getTickets({String? modality}) async {
    final dynamic response = await apiClient.get(
      '/kitchen/tickets',
      queryParameters: modality != null && modality.isNotEmpty
          ? <String, dynamic>{'modality': modality}
          : null,
    );
    if (response is! List<dynamic>) return <KitchenTicket>[];
    return response
        .map(
          (dynamic item) =>
              KitchenTicket.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<KitchenTicket> startTicket(String ticketId) async {
    final dynamic response = await apiClient.post(
      '/kitchen/tickets/$ticketId/start',
      requiresAuth: true,
    );
    return KitchenTicket.fromJson(response as Map<String, dynamic>);
  }

  Future<KitchenTicket> markTicketReady(String ticketId) async {
    final dynamic response = await apiClient.post(
      '/kitchen/tickets/$ticketId/ready',
      body: const <String, dynamic>{'all_items_prepared': true},
      requiresAuth: true,
    );
    return KitchenTicket.fromJson(response as Map<String, dynamic>);
  }
}
