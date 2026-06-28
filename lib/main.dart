import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'controllers/user_auth_controller.dart';
import 'core/network/api_client.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/prefs_storage.dart';
import 'core/storage/secure_storage.dart';
import 'core/utils/logger.dart';
import 'providers/app_provider.dart';
import 'controllers/cart_controller.dart';
import 'providers/auth_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Status-bar icons correct from the very first frame (cold start), so they
    // don't stay wrong until a hot reload re-applies the style.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    await PrefsStorage.instance.init();

    final authProvider = AuthProvider();
    ApiClient.instance.setUnauthorizedHandler(authProvider.handleUnauthorized);

    final appProvider = AppProvider();
    unawaited(appProvider.init());

    // Guarded Firebase + FCM init. Will no-op until `flutterfire configure`
    // generates google-services.json / GoogleService-Info.plist.
    unawaited(_initFirebaseAndPush());

    FlutterError.onError = (details) {
      AppLogger.e('FlutterError', details.exception, details.stack);
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: appProvider),
          ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider<CartController>.value(value: CartController.instance),
        ],
        child: const App(),
      ),
    );
  }, (error, stack) {
    AppLogger.e('Uncaught zone error', error, stack);
  });
}

Future<void> _initFirebaseAndPush() async {
  try {
    await Firebase.initializeApp();
    await NotificationService.instance.init(
      onTokenChanged: (token) async {
        // Register/append this device's token, but only when logged in
        // (the verify call already registers it at login time).
        final jwt = await SecureStorage.instance.getToken();
        if (jwt != null && jwt.isNotEmpty) {
          await UserAuthController.instance.registerFcmToken(token);
        }
      },
    );
  } catch (e, st) {
    AppLogger.w('Firebase/FCM init skipped: $e');
    AppLogger.d(st);
  }
}
