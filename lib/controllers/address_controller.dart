import 'package:flutter/foundation.dart';

import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/utils/logger.dart';
import '../models/address.dart';

/// Saved delivery addresses (server-backed).
class AddressController extends ChangeNotifier {
  AddressController._();
  static final AddressController instance = AddressController._();

  List<Address> _addresses = [];
  List<Address> get addresses => _addresses;
  bool _loading = false;
  bool get loading => _loading;

  Address? get defaultAddress {
    for (final a in _addresses) {
      if (a.isDefault) return a;
    }
    return _addresses.isNotEmpty ? _addresses.first : null;
  }

  Future<List<Address>> fetch() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.userAddresses);
      final list = (res.data is Map) ? res.data['data'] as List? : null;
      _addresses = list?.map((e) => Address.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    } catch (e) {
      AppLogger.w('fetch addresses failed: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
    return _addresses;
  }

  /// Create an address. Returns the created Address (with id) or null.
  Future<Address?> add(Map<String, dynamic> body) async {
    try {
      final res = await ApiClient.instance.post(ApiEndpoints.userAddresses, body: body);
      final data = (res.data is Map) ? res.data['data'] : null;
      if (data is Map<String, dynamic>) {
        final addr = Address.fromJson(data);
        await fetch();
        ToastService.success('Address saved');
        return addr;
      }
      return null;
    } on ApiException catch (e) {
      ToastService.error(e.message);
      return null;
    } catch (e) {
      AppLogger.e('add address failed: $e');
      ToastService.error('Could not save address');
      return null;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> body) async {
    try {
      await ApiClient.instance.put(ApiEndpoints.userAddressById(id), body: body);
      await fetch();
      return true;
    } on ApiException catch (e) {
      ToastService.error(e.message);
      return false;
    } catch (e) {
      AppLogger.e('update address failed: $e');
      return false;
    }
  }

  Future<bool> remove(String id) async {
    try {
      await ApiClient.instance.delete(ApiEndpoints.userAddressById(id));
      await fetch();
      return true;
    } catch (e) {
      AppLogger.e('delete address failed: $e');
      return false;
    }
  }

  Future<bool> setDefault(String id) async {
    try {
      await ApiClient.instance.patch(ApiEndpoints.userAddressDefault(id));
      await fetch();
      return true;
    } catch (e) {
      AppLogger.e('set default address failed: $e');
      return false;
    }
  }
}
