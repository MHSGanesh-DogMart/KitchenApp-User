import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(Object? msg) {
    if (kDebugMode) debugPrint('🟦 $msg');
  }

  static void i(Object? msg) {
    if (kDebugMode) debugPrint('🟩 $msg');
  }

  static void w(Object? msg) {
    if (kDebugMode) debugPrint('🟧 $msg');
  }

  static void e(Object? msg, [Object? error, StackTrace? st]) {
    if (kDebugMode) {
      debugPrint('🟥 $msg');
      if (error != null) debugPrint('   $error');
      if (st != null) debugPrint('$st');
    }
  }
}
