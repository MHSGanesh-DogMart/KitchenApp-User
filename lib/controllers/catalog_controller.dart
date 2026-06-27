import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/utils/logger.dart';
import '../models/home_feed.dart';

/// Browse kitchens & dishes (GET /api/user/kitchens, /dishes).
class CatalogController {
  CatalogController._();
  static final CatalogController instance = CatalogController._();

  Future<List<HomeCuisine>> getCuisines() async {
    final list = await _getList(ApiEndpoints.userCuisines);
    return list.map((e) => HomeCuisine.fromJson(e)).toList();
  }

  Future<Paged<HomeCook>> listKitchens({
    double? lat,
    double? lng,
    String? cuisineId,
    int page = 1,
    int limit = 20,
  }) async {
    return _getPaged(
      ApiEndpoints.userKitchens,
      {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (cuisineId != null && cuisineId.isNotEmpty) 'cuisineId': cuisineId,
        'page': page,
        'limit': limit,
      },
      (e) => HomeCook.fromJson(e),
    );
  }

  Future<HomeCook?> getKitchen(String id, {double? lat, double? lng}) async {
    final data = await _getData(
      ApiEndpoints.userKitchenById(id),
      query: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      },
    );
    return data == null ? null : HomeCook.fromJson(data);
  }

  Future<List<HomeDish>> getKitchenMenu(String id) async {
    final list = await _getList(ApiEndpoints.userKitchenMenu(id));
    return list.map((e) => HomeDish.fromJson(e)).toList();
  }

  Future<Paged<HomeDish>> listDishes({
    String? cuisineId,
    int page = 1,
    int limit = 20,
  }) async {
    return _getPaged(
      ApiEndpoints.userDishes,
      {
        if (cuisineId != null && cuisineId.isNotEmpty) 'cuisineId': cuisineId,
        'page': page,
        'limit': limit,
      },
      (e) => HomeDish.fromJson(e),
    );
  }

  Future<DishDetail?> getDish(String id) async {
    final data = await _getData(ApiEndpoints.userDishById(id));
    return data == null ? null : DishDetail.fromJson(data);
  }

  // ── helpers ──
  Future<Paged<T>> _getPaged<T>(
    String path,
    Map<String, dynamic> query,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final res = await ApiClient.instance.get(path, query: query);
      if (res.statusCode == 200 && res.data?['data'] is List) {
        final items = (res.data['data'] as List)
            .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final p = res.data['pagination'] as Map?;
        return Paged<T>(
          items: items,
          page: (p?['page'] as num?)?.toInt() ?? 1,
          totalPages: (p?['totalPages'] as num?)?.toInt() ?? 1,
          hasMore: p?['hasMore'] as bool? ?? false,
        );
      }
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('GET $path failed: $e');
    }
    return Paged<T>(items: <T>[], page: 1, totalPages: 1, hasMore: false);
  }

  Future<List<Map<String, dynamic>>> _getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await ApiClient.instance.get(path, query: query);
      if (res.statusCode == 200 && res.data?['data'] is List) {
        return (res.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('GET $path failed: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> _getData(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await ApiClient.instance.get(path, query: query);
      if (res.statusCode == 200 && res.data?['data'] is Map) {
        return Map<String, dynamic>.from(res.data['data']);
      }
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('GET $path failed: $e');
    }
    return null;
  }
}
