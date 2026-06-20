import 'package:flutter/foundation.dart';

import '../core/storage/prefs_storage.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider() {
    _enabled = PrefsStorage.instance.notificationsEnabled;
  }

  bool _enabled = true;
  int _unreadCount = 0;

  bool get enabled => _enabled;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  Future<void> setEnabled(bool v) async {
    _enabled = v;
    await PrefsStorage.instance.setNotificationsEnabled(v);
    notifyListeners();
  }

  void setUnreadCount(int v) {
    if (v == _unreadCount) return;
    _unreadCount = v;
    notifyListeners();
  }

  void increment() {
    _unreadCount += 1;
    notifyListeners();
  }

  void clear() {
    if (_unreadCount == 0) return;
    _unreadCount = 0;
    notifyListeners();
  }
}
