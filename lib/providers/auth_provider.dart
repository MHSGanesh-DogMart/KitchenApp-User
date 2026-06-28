import 'package:flutter/foundation.dart';

import '../controllers/user_auth_controller.dart';
import '../core/notifications/notification_service.dart';
import '../core/routing/route_names.dart';
import '../core/services/navigation_service.dart';
import '../core/services/toast_service.dart';
import '../core/storage/secure_storage.dart';
import '../core/utils/logger.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> restoreSession() async {
    final token = await SecureStorage.instance.getToken();
    _status = (token != null && token.isNotEmpty)
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> onLoginSuccess(String token, {String? refreshToken}) async {
    await SecureStorage.instance.saveToken(token);
    if (refreshToken != null) {
      await SecureStorage.instance.saveRefreshToken(refreshToken);
    }
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout({bool silent = false}) async {
    // Drop this device's token server-side first (best-effort, while the JWT
    // is still valid), then invalidate the local FCM token + clear storage.
    final deviceToken = NotificationService.instance.token;
    try {
      await UserAuthController.instance.logout(fcmToken: deviceToken);
    } catch (e) {
      AppLogger.w('Customer logout API failed (continuing): $e');
    }
    try {
      await NotificationService.instance.deleteToken();
    } catch (e) {
      AppLogger.w('FCM deleteToken on logout failed: $e');
    }
    await SecureStorage.instance.clear();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    if (!silent) {
      NavigationService.pushNamedAndRemoveUntil(RouteNames.login);
    }
  }

  Future<void> handleUnauthorized() async {
    if (_status == AuthStatus.unauthenticated) return;
    ToastService.error('Session expired. Please login again.');
    await logout();
  }

  void setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
