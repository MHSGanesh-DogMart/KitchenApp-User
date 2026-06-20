import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppProvider extends ChangeNotifier {
  String _appVersion = '';
  String _buildNumber = '';
  bool _forceUpdate = false;
  bool _maintenance = false;

  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;
  bool get forceUpdate => _forceUpdate;
  bool get maintenance => _maintenance;

  Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    _buildNumber = info.buildNumber;
    notifyListeners();
  }

  void setForceUpdate(bool v) {
    _forceUpdate = v;
    notifyListeners();
  }

  void setMaintenance(bool v) {
    _maintenance = v;
    notifyListeners();
  }
}
