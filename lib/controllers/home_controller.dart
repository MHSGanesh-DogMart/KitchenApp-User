import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/utils/logger.dart';
import '../models/home_feed.dart';

/// Customer home feed (GET /api/user/home). lat/lng are mandatory;
/// pass a cuisineId to filter, omit for all.
class HomeController {
  HomeController._();
  static final HomeController instance = HomeController._();

  Future<HomeFeed?> getHome({
    required double lat,
    required double lng,
    String? cuisineId,
  }) async {
    try {
      final res = await ApiClient.instance.get(
        ApiEndpoints.userHome,
        query: {
          'lat': lat,
          'lng': lng,
          if (cuisineId != null && cuisineId.isNotEmpty) 'cuisineId': cuisineId,
        },
      );
      if (res.statusCode == 200 && res.data?['data'] != null) {
        return HomeFeed.fromJson(Map<String, dynamic>.from(res.data['data']));
      }
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('getHome failed: $e');
    }
    return null;
  }
}
