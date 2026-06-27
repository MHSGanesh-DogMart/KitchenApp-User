import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/storage/secure_storage.dart';
import '../core/utils/logger.dart';

/// Customer authentication against the backend (/api/user/auth).
/// Two-step OTP: sendOtp → verifyOtp (saves the JWT on success).
class UserAuthController {
  UserAuthController._();
  static final UserAuthController instance = UserAuthController._();

  /// Request an OTP for [phone] (10 digits, no +91). Dummy code is 1234.
  Future<bool> sendOtp(String phone) async {
    try {
      AppLogger.i('Customer requesting OTP for $phone');
      final res = await ApiClient.instance.post(
        ApiEndpoints.userSendOtp,
        body: {'phone': phone},
      );
      if (res.statusCode == 200 && res.data != null) {
        final ok = res.data['success'] as bool? ?? false;
        final msg = res.data['message'] as String? ?? '';
        if (msg.isNotEmpty) {
          ok ? ToastService.success(msg) : ToastService.error(msg);
        }
        return ok;
      }
      return false;
    } on ApiException catch (e) {
      ToastService.error(e.message);
      return false;
    } catch (e) {
      AppLogger.e('Customer sendOtp failed: $e');
      ToastService.error('Failed to send OTP');
      return false;
    }
  }

  /// Verify [otp] for [phone]. On success saves the token + user id and
  /// returns the auth payload; returns null on failure.
  Future<Map<String, dynamic>?> verifyOtp(
    String phone,
    String otp, {
    required String name,
    String? email,
    String? fcmToken,
  }) async {
    try {
      AppLogger.i('Customer verifying OTP for $phone');
      final res = await ApiClient.instance.post(
        ApiEndpoints.userVerifyOtp,
        body: {
          'phone': phone,
          'otp': otp,
          'name': name,
          if (email != null && email.isNotEmpty) 'email': email,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );
      if (res.statusCode == 200 && res.data != null) {
        final ok = res.data['success'] as bool? ?? false;
        final msg = res.data['message'] as String? ?? '';
        if (ok && res.data['data'] != null) {
          final data = res.data['data'] as Map<String, dynamic>;
          final token = data['token'] as String?;
          final user = data['user'] as Map<String, dynamic>?;
          if (token != null && token.isNotEmpty) {
            await SecureStorage.instance.saveToken(token);
          }
          if (user != null && user['id'] != null) {
            await SecureStorage.instance.saveUserId(user['id'].toString());
          }
          if (msg.isNotEmpty) ToastService.success(msg);
          return {
            'token': token,
            'isRegistered': data['isRegistered'] as bool? ?? false,
            'status': data['status'] as String?,
            'user': user,
          };
        } else if (msg.isNotEmpty) {
          ToastService.error(msg);
        }
      }
      return null;
    } on ApiException catch (e) {
      ToastService.error(e.message);
      return null;
    } catch (e) {
      AppLogger.e('Customer verifyOtp failed: $e');
      ToastService.error('Verification failed');
      return null;
    }
  }
}
