import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/utils/logger.dart';
import '../models/home_feed.dart';

/// Wishlist / favourites for kitchens and dishes.
/// type is 'kitchen' or 'dish'.
class WishlistController {
  WishlistController._();
  static final WishlistController instance = WishlistController._();

  Future<bool> add(String type, String targetId) async {
    try {
      final res = await ApiClient.instance.post(
        ApiEndpoints.userWishlist,
        body: {'type': type, 'targetId': targetId},
      );
      if (res.statusCode == 200 && res.data?['success'] == true) {
        final msg = res.data?['message']?.toString();
        if (msg != null && msg.isNotEmpty) ToastService.success(msg);
        return true;
      }
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('wishlist add failed: $e');
    }
    return false;
  }

  Future<bool> remove(String type, String targetId) async {
    try {
      final res =
          await ApiClient.instance.delete(ApiEndpoints.userWishlistItem(type, targetId));
      if (res.statusCode == 200 && res.data?['success'] == true) {
        final msg = res.data?['message']?.toString();
        if (msg != null && msg.isNotEmpty) ToastService.success(msg);
        return true;
      }
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('wishlist remove failed: $e');
    }
    return false;
  }

  /// Toggle helper for the heart UI. Returns the new state (true = wishlisted).
  /// Optimistic callers pass the *current* state.
  Future<bool> toggle(String type, String targetId, bool currentlyWishlisted) async {
    final ok = currentlyWishlisted
        ? await remove(type, targetId)
        : await add(type, targetId);
    // On failure keep the old state; on success flip it.
    return ok ? !currentlyWishlisted : currentlyWishlisted;
  }

  Future<List<HomeCook>> getKitchens() async {
    final data = await _get(type: 'kitchen');
    return ((data?['kitchens'] as List?) ?? [])
        .map((e) => HomeCook.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<HomeDish>> getDishes() async {
    final data = await _get(type: 'dish');
    return ((data?['dishes'] as List?) ?? [])
        .map((e) => HomeDish.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>?> _get({String? type}) async {
    try {
      final res = await ApiClient.instance.get(
        ApiEndpoints.userWishlist,
        query: {if (type != null) 'type': type},
      );
      if (res.statusCode == 200 && res.data?['data'] is Map) {
        return Map<String, dynamic>.from(res.data['data']);
      }
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('wishlist get failed: $e');
    }
    return null;
  }
}
