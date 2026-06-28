import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  // NOTE: prints in ALL build modes (debug/profile/release) — the kDebugMode
  // gate was removed so API logs show on release/profile builds too.
  static void d(Object? msg) => debugPrint('🟦 $msg');

  static void i(Object? msg) => debugPrint('🟩 $msg');

  static void w(Object? msg) => debugPrint('🟧 $msg');

  static void e(Object? msg, [Object? error, StackTrace? st]) {
    debugPrint('🟥 $msg');
    if (error != null) debugPrint('   $error');
    if (st != null) debugPrint('$st');
  }
}
