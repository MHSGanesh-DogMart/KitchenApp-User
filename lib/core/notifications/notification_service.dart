import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../services/navigation_service.dart';
import '../services/permission_service.dart';
import '../storage/prefs_storage.dart';
import '../utils/logger.dart';
import 'notification_payload.dart';

/// Top-level background handler — REQUIRED by FCM.
/// Must be top-level (not inside a class) and annotated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.i('🔔 BG message: ${message.messageId} data=${message.data}');
  // No UI work here. System tray shows the notification automatically
  // when the message contains a `notification` block.
}

/// Single entry point for FCM + local notifications. Wires:
///   • Foreground  → flutter_local_notifications heads-up
///   • Background  → system tray (handled by OS via @pragma handler)
///   • Terminated  → getInitialMessage on next launch
/// Tap → deep-link via [NotificationPayload].
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _token;
  String? get token => _token;

  static const _androidChannel = AndroidNotificationChannel(
    'default_high_importance',
    'General Notifications',
    description: 'Default channel for app notifications',
    importance: Importance.high,
  );

  /// Call after Firebase.initializeApp(). Safe to call once; no-ops on retry.
  Future<void> init({ValueChanged<String>? onTokenChanged}) async {
    if (_initialized) return;
    _initialized = true;

    // Background handler must be registered before anything else.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocal();

    // Foreground presentation on iOS (Android needs local notif manually).
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.i('FCM permission: ${settings.authorizationStatus}');
    // Android 13+ runtime POST_NOTIFICATIONS — request explicitly too.
    await PermissionService.notification();

    // Token
    _token = await _fcm.getToken();
    AppLogger.i('FCM token: $_token');
    if (_token != null) onTokenChanged?.call(_token!);

    _fcm.onTokenRefresh.listen((t) {
      _token = t;
      AppLogger.i('FCM token refreshed: $t');
      onTokenChanged?.call(t);
    });

    // Foreground messages → show local notif.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Background → tap opens app.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Terminated → tap launched the app.
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      // Delay so MaterialApp & navigator are ready.
      Future.delayed(const Duration(milliseconds: 600), () => _handleTap(initial));
    }
  }

  Future<void> _initLocal() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = (jsonDecode(payload) as Map).cast<String, dynamic>();
          _routeFromData(data);
        } catch (e) {
          AppLogger.e('Local notif payload decode error', e);
        }
      },
    );
    // Android channel.
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  void _onForegroundMessage(RemoteMessage message) {
    AppLogger.i('🔔 FG message: ${message.messageId} data=${message.data}');
    if (!PrefsStorage.instance.notificationsEnabled) return;

    final notif = message.notification;
    final title = notif?.title ?? message.data['title']?.toString();
    final body = notif?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return;

    _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleTap(RemoteMessage message) {
    AppLogger.i('🔔 Tap: ${message.messageId} data=${message.data}');
    _routeFromData(message.data);
  }

  void _routeFromData(Map<String, dynamic> data) {
    final payload = NotificationPayload.parse(data);
    if (payload == null) return;
    NavigationService.pushNamed(payload.route, args: payload.args);
  }

  Future<void> clearAll() => _local.cancelAll();

  /// Call on logout — invalidates the device's token.
  Future<void> deleteToken() async {
    try {
      await _fcm.deleteToken();
      _token = null;
    } catch (e) {
      AppLogger.e('deleteToken error', e);
    }
  }

  /// Subscribe / unsubscribe to topics (e.g., `user_<id>`, `all_users`).
  Future<void> subscribe(String topic) => _fcm.subscribeToTopic(topic);
  Future<void> unsubscribe(String topic) => _fcm.unsubscribeFromTopic(topic);
}
