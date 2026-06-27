import 'dart:io';

import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/utils/logger.dart';
import '../models/user.dart';

/// Customer profile: fetch, update, and avatar upload (/api/user/...).
class UserProfileController {
  UserProfileController._();
  static final UserProfileController instance = UserProfileController._();

  /// GET the logged-in customer's own profile (id comes from the JWT).
  Future<User?> getMyProfile() async {
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.userMe);
      if (res.statusCode == 200 && res.data?['data'] != null) {
        return User.fromJson(Map<String, dynamic>.from(res.data['data']));
      }
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('getMyProfile failed: $e');
    }
    return null;
  }

  /// PUT profile updates for the logged-in customer. Returns the saved user.
  Future<User?> updateMyProfile({
    String? name,
    String? email,
    String? dob,
    String? profilePicUrl,
  }) async {
    try {
      final res = await ApiClient.instance.put(
        ApiEndpoints.userMe,
        body: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (dob != null) 'dob': dob,
          if (profilePicUrl != null) 'profilePicUrl': profilePicUrl,
        },
      );
      if (res.statusCode == 200 && res.data?['success'] == true) {
        final msg = res.data['message']?.toString();
        if (msg != null && msg.isNotEmpty) ToastService.success(msg);
        return User.fromJson(Map<String, dynamic>.from(res.data['data']));
      }
      ToastService.error(res.data?['message']?.toString() ?? 'Update failed');
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('updateProfile failed: $e');
      ToastService.error('Could not update profile');
    }
    return null;
  }

  /// Upload an avatar image → returns the hosted URL (or null).
  Future<String?> uploadImage(File file) async {
    try {
      final result = await ApiClient.instance.uploadImage(
        path: ApiEndpoints.userUpload,
        file: file,
        folder: 'user-uploads',
        fieldName: 'image',
      );
      return result?['fileUrl'];
    } on ApiException catch (e) {
      ToastService.error(e.message);
    } catch (e) {
      AppLogger.e('uploadImage failed: $e');
      ToastService.error('Image upload failed');
    }
    return null;
  }
}
