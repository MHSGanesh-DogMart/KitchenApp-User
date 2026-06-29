import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/utils/logger.dart';
import '../models/order.dart';

/// Orders + Razorpay payment (API layer). The Razorpay checkout sheet itself
/// is opened from the cart screen; this just talks to the backend.
class OrderController {
  OrderController._();
  static final OrderController instance = OrderController._();

  /// Step 1 — validate cart + create a Razorpay order. Returns the params for
  /// the Razorpay sheet, or null (with a toast) on failure (e.g. out of range).
  Future<CheckoutResult?> checkout({
    required String fulfillment,
    String? addressId,
    String? note,
    double? lat,
    double? lng,
  }) async {
    try {
      final res = await ApiClient.instance.post(
        ApiEndpoints.userOrderCheckout,
        body: {
          'fulfillment': fulfillment,
          if (addressId != null) 'addressId': addressId,
          if (note != null && note.isNotEmpty) 'note': note,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );
      final data = (res.data is Map) ? res.data['data'] : null;
      if (data is Map<String, dynamic>) return CheckoutResult.fromJson(data);
      return null;
    } on ApiException catch (e) {
      ToastService.error(e.message); // e.g. "out of delivery range", "cart empty"
      return null;
    } catch (e) {
      AppLogger.e('checkout failed: $e');
      ToastService.error('Could not start checkout');
      return null;
    }
  }

  /// Step 2 — verify the Razorpay payment → confirm the order.
  Future<Order?> verify({
    required String orderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final res = await ApiClient.instance.post(
        ApiEndpoints.userOrderVerify,
        body: {
          'orderId': orderId,
          'razorpayPaymentId': razorpayPaymentId,
          'razorpayOrderId': razorpayOrderId,
          'razorpaySignature': razorpaySignature,
        },
      );
      final data = (res.data is Map) ? res.data['data'] : null;
      if (data is Map<String, dynamic>) return Order.fromJson(data);
      return null;
    } on ApiException catch (e) {
      ToastService.error(e.message);
      return null;
    } catch (e) {
      AppLogger.e('verify failed: $e');
      ToastService.error('Payment verification failed');
      return null;
    }
  }

  Future<List<Order>> listOrders() async {
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.userOrders);
      final list = (res.data is Map) ? res.data['data'] as List? : null;
      return list?.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } catch (e) {
      AppLogger.w('listOrders failed: $e');
      return [];
    }
  }

  /// Cancel an order (only allowed while PLACED/ACCEPTED — server enforces).
  Future<Order?> cancel(String id) async {
    try {
      final res = await ApiClient.instance.patch(ApiEndpoints.userOrderCancel(id));
      final data = (res.data is Map) ? res.data['data'] : null;
      final msg = (res.data is Map) ? res.data['message']?.toString() : null;
      if (data is Map<String, dynamic>) {
        if (msg != null) ToastService.success(msg);
        return Order.fromJson(data);
      }
      return null;
    } on ApiException catch (e) {
      ToastService.error(e.message); // e.g. "can no longer be cancelled"
      return null;
    } catch (e) {
      AppLogger.e('cancel failed: $e');
      ToastService.error('Could not cancel order');
      return null;
    }
  }

  Future<Order?> getOrder(String id) async {
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.userOrderById(id));
      final data = (res.data is Map) ? res.data['data'] : null;
      return data is Map<String, dynamic> ? Order.fromJson(data) : null;
    } catch (e) {
      AppLogger.w('getOrder failed: $e');
      return null;
    }
  }
}
