import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  ConnectivityProvider() {
    _init();
  }

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamSubscription<bool>? _sub;

  Future<void> _init() async {
    _isOnline = await ConnectivityService.instance.isOnline();
    notifyListeners();
    _sub = ConnectivityService.instance.onStatusChange.listen((online) {
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
