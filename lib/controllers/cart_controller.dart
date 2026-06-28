import 'package:flutter/foundation.dart';

import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/storage/prefs_storage.dart';
import '../core/utils/logger.dart';
import '../models/address.dart';
import '../models/cart.dart';
import '../models/coupon.dart';

/// Server-backed cart. Single source of truth for the customer cart — every
/// price/total comes from the backend. Listen to it for the floating cart bar,
/// the cart screen, and the checkout bill.
class CartController extends ChangeNotifier {
  CartController._();
  static final CartController instance = CartController._();

  CartData _cart = CartData.empty;
  CartData get cart => _cart;

  bool _loading = false;
  bool get loading => _loading;

  int get itemCount => _cart.itemCount;
  bool get isEmpty => _cart.isEmpty;

  /// Server-computed item subtotal (for the floating cart bar).
  num get subtotal => _cart.bill.itemTotal;

  /// Quantity of a given menu item currently in the cart (0 if none).
  int qtyOf(String menuItemId) {
    for (final i in _cart.items) {
      if (i.menuItemId == menuItemId) return i.qty;
    }
    return 0;
  }

  // Location + fulfillment drive the bill (delivery fee + serviceable radius).
  double? _lat;
  double? _lng;
  String _fulfillment = 'delivery';
  String get fulfillment => _fulfillment;

  /// Set the delivery location (from the selected address) used for the bill.
  void setLocation(double? lat, double? lng) {
    _lat = lat;
    _lng = lng;
  }

  /// The delivery address the customer picked (null → using home GPS).
  Address? _selectedAddress;
  Address? get selectedAddress => _selectedAddress;

  /// Pick a saved address for delivery — drives the serviceable-radius check.
  Future<void> setSelectedAddress(Address a) async {
    _selectedAddress = a;
    _lat = a.lat;
    _lng = a.lng;
    await refresh();
  }

  /// Default the cart location to the saved home GPS when nothing is set yet
  /// (so the very first cart call uses the home screen's lat/lng).
  void loadHomeLocationIfNeeded() {
    if (_lat == null || _lng == null) {
      final lat = PrefsStorage.instance.homeLat;
      final lng = PrefsStorage.instance.homeLng;
      if (lat != null && lng != null) {
        _lat = lat;
        _lng = lng;
      }
    }
  }

  Map<String, dynamic> _ctx([Map<String, dynamic>? extra]) => {
        if (_lat != null) 'lat': _lat,
        if (_lng != null) 'lng': _lng,
        'fulfillment': _fulfillment,
        ...?extra,
      };

  Map<String, dynamic> _query() => {
        if (_lat != null) 'lat': _lat,
        if (_lng != null) 'lng': _lng,
        'fulfillment': _fulfillment,
      };

  void _apply(dynamic res) {
    final data = (res?.data is Map) ? res.data['data'] : null;
    if (data is Map<String, dynamic>) {
      _cart = CartData.fromJson(data);
      notifyListeners();
    }
  }

  /// Toggle delivery / pickup, then refresh the bill from the server.
  Future<void> setFulfillment(String value) async {
    _fulfillment = value == 'pickup' ? 'pickup' : 'delivery';
    notifyListeners();
    await refresh();
  }

  /// Pull the latest cart + bill.
  Future<void> refresh() async {
    _loading = true;
    Future.delayed(Duration(seconds: 0), () {
      notifyListeners();
    });

    try {
      final res = await ApiClient.instance.get(ApiEndpoints.userCart, query: _query());
      _apply(res);
    } on ApiException catch (e) {
      AppLogger.w('Cart refresh failed: ${e.message}');
    } catch (e) {
      AppLogger.e('Cart refresh error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Add a dish. On a single-kitchen conflict returns a result carrying the
  /// conflict (so the UI shows a "clear cart?" dialog). Pass force to switch.
  Future<AddToCartResult> addItem(String menuItemId, {int qty = 1, bool force = false}) async {
    try {
      final res = await ApiClient.instance.post(
        ApiEndpoints.userCartAdd,
        body: _ctx({'menuItemId': menuItemId, 'qty': qty, if (force) 'force': true}),
      );
      _apply(res);
      return AddToCartResult(cart: _cart);
    } on ApiException catch (e) {
      if (e.statusCode == 409 && e.raw is Map && e.raw['code'] == 'CART_KITCHEN_CONFLICT') {
        return AddToCartResult(
          conflict: CartKitchenConflict(
            currentKitchen: e.raw['currentKitchen']?.toString() ?? 'another kitchen',
            newKitchen: e.raw['newKitchen']?.toString() ?? 'this kitchen',
            message: e.raw['message']?.toString(),
          ),
        );
      }
      ToastService.error(e.message);
      return AddToCartResult(error: e.message);
    } catch (e) {
      AppLogger.e('addItem error: $e');
      ToastService.error('Could not add to cart');
      return const AddToCartResult(error: 'Could not add to cart');
    }
  }

  Future<void> increment(String menuItemId) =>
      _mutate(() => ApiClient.instance.post(
            ApiEndpoints.userCartIncrement,
            body: _ctx({'menuItemId': menuItemId}),
          ));

  Future<void> decrement(String menuItemId) =>
      _mutate(() => ApiClient.instance.post(
            ApiEndpoints.userCartDecrement,
            body: _ctx({'menuItemId': menuItemId}),
          ));

  Future<void> removeItem(String menuItemId) =>
      _mutate(() => ApiClient.instance.delete(
            ApiEndpoints.userCartItem(menuItemId),
            body: _ctx(),
          ));

  Future<void> clear() => _mutate(() => ApiClient.instance.delete(
        ApiEndpoints.userCart,
        body: _ctx(),
      ));

  /// Apply a coupon. Returns the server message on failure (e.g. expired).
  Future<bool> applyCoupon(String code) async {
    try {
      final res = await ApiClient.instance.post(
        ApiEndpoints.userCartCoupon,
        body: _ctx({'code': code}),
      );
      _apply(res);
      return true;
    } on ApiException catch (e) {
      ToastService.error(e.message);
      return false;
    } catch (e) {
      AppLogger.e('applyCoupon error: $e');
      ToastService.error('Could not apply coupon');
      return false;
    }
  }

  Future<void> removeCoupon() => _mutate(() => ApiClient.instance.delete(
        ApiEndpoints.userCartCoupon,
        body: _ctx(),
      ));

  /// Fetch the list of usable coupons (active + not expired) for the Offers screen.
  Future<List<Coupon>> fetchCoupons() async {
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.userCoupons);
      final list = (res.data is Map) ? res.data['data'] as List? : null;
      return list?.map((e) => Coupon.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } catch (e) {
      AppLogger.w('fetchCoupons failed: $e');
      return [];
    }
  }

  Future<void> _mutate(Future<dynamic> Function() fn) async {
    try {
      final res = await fn();
      _apply(res);
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('Cart mutate error: $e');
    }
  }

  void reset() {
    _cart = CartData.empty;
    _fulfillment = 'delivery';
    notifyListeners();
  }
}
