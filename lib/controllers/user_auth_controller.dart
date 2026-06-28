import '../core/config/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/services/toast_service.dart';
import '../core/storage/secure_storage.dart';
import '../core/utils/logger.dart';
import '../models/user.dart';

/// Customer authentication against the backend (/api/user/auth).
/// Two-step OTP: sendOtp → verifyOtp (saves the JWT on success).
class UserAuthController {
  UserAuthController._();
  static final UserAuthController instance = UserAuthController._();

  /// Request an OTP for [phone] (10 digits, no +91). Dummy code is 1234.
  /// Returns whether the send succeeded + whether the phone is already
  /// registered (so the UI shows Login vs Create-account).
  Future<({bool ok, bool isRegistered})> sendOtp(String phone) async {
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
        return (ok: ok, isRegistered: res.data['isRegistered'] as bool? ?? false);
      }
      return (ok: false, isRegistered: false);
    } on ApiException catch (e) {
      ToastService.error(e.message);
      return (ok: false, isRegistered: false);
    } catch (e) {
      AppLogger.e('Customer sendOtp failed: $e');
      ToastService.error('Failed to send OTP');
      return (ok: false, isRegistered: false);
    }
  }

  /// Verify [otp] for [phone]. On success saves the token + user id and
  /// returns an [AuthResult]; returns null on failure.
  Future<AuthResult?> verifyOtp(
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
          final token = data['token']?.toString() ?? '';
          final userJson = data['user'] as Map<String, dynamic>?;
          if (token.isEmpty || userJson == null) return null;

          final user = User.fromJson(userJson);
          // Token is persisted by AuthProvider.onLoginSuccess (mirrors the
          // kitchen app); here we just keep the user id for profile calls.
          if (user.id.isNotEmpty) {
            await SecureStorage.instance.saveUserId(user.id);
          }
          if (msg.isNotEmpty) ToastService.success(msg);
          return AuthResult(
            token: token,
            user: user,
            isNewAccount: !(data['isRegistered'] as bool? ?? false),
          );
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

  /// Register/append this device's FCM token (server stores an array — one
  /// entry per device). Safe to call on login + on token refresh.
  Future<bool> registerFcmToken(String fcmToken) async {
    if (fcmToken.isEmpty) return false;
    try {
      final res = await ApiClient.instance.post(
        ApiEndpoints.userFcmToken,
        body: {'fcmToken': fcmToken},
      );
      return res.statusCode == 200;
    } catch (e) {
      AppLogger.w('registerFcmToken failed: $e');
      return false;
    }
  }

  /// Tell the server to drop this device's token so it stops getting pushes.
  /// Other devices stay logged in. The JWT is cleared by AuthProvider.logout.
  Future<void> logout({String? fcmToken}) async {
    try {
      await ApiClient.instance.post(
        ApiEndpoints.userLogout,
        body: {if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken},
      );
    } catch (e) {
      AppLogger.w('Customer logout API failed (continuing): $e');
    }
  }

  /// Permanently delete the customer's account + data.
  Future<bool> deleteAccount() async {
    try {
      final res = await ApiClient.instance.delete(ApiEndpoints.userDeleteAccount);
      if (res.statusCode == 200) {
        final msg = res.data?['message'] as String? ?? 'Account deleted';
        ToastService.success(msg);
        return true;
      }
      ToastService.error(res.data?['message'] as String? ?? 'Could not delete account');
      return false;
    } on ApiException catch (e) {
      ToastService.error(e.message);
      return false;
    } catch (e) {
      AppLogger.e('deleteAccount failed: $e');
      ToastService.error('Could not delete account');
      return false;
    }
  }
}
