import 'package:shared_preferences/shared_preferences.dart';

class PrefsStorage {
  PrefsStorage._();
  static final PrefsStorage instance = PrefsStorage._();

  static const _kOnboardingDone = 'onboarding_done';
  static const _kThemeMode = 'theme_mode';
  static const _kLanguage = 'language';
  static const _kNotificationsEnabled = 'notifications_enabled';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    final p = _prefs;
    if (p == null) {
      throw StateError('PrefsStorage.init() must be called before use.');
    }
    return p;
  }

  bool get onboardingDone => _p.getBool(_kOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool v) => _p.setBool(_kOnboardingDone, v);

  String? get themeMode => _p.getString(_kThemeMode);
  Future<void> setThemeMode(String v) => _p.setString(_kThemeMode, v);

  String? get language => _p.getString(_kLanguage);
  Future<void> setLanguage(String v) => _p.setString(_kLanguage, v);

  bool get notificationsEnabled => _p.getBool(_kNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool v) =>
      _p.setBool(_kNotificationsEnabled, v);

  Future<void> clear() async {
    await _p.clear();
  }
}
