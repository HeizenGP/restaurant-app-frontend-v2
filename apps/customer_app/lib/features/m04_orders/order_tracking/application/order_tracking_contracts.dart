import '../../submit_order/domain/order_models.dart';
import '../domain/order_tracking_models.dart';

abstract interface class OrderTrackingRepository {
  Future<List<OrderSnapshot>> listOrders({required String accessToken});

  Future<OrderSnapshot> getOrder(
    String orderId, {
    required String accessToken,
  });

  Future<OrderTrackingSnapshot> getTracking(
    String orderId, {
    required String accessToken,
  });
}

typedef OrderAccessTokenProvider = String? Function();
typedef RefreshOrderAccessToken = Future<bool> Function();
