enum AppFlavor { dev, stage, prod }

class AppConfig {
  AppConfig._();

  static AppFlavor flavor = AppFlavor.dev;

  static String get baseUrl {
    switch (flavor) {
      case AppFlavor.dev:
        return 'https://api.dev.example.com';
      case AppFlavor.stage:
        return 'https://api.stage.example.com';
      case AppFlavor.prod:
        return 'https://api.example.com';
    }
  }

  static const String termsUrl = 'https://example.com/terms';
  static const String privacyUrl = 'https://example.com/privacy';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);

  static const int minSupportedBuild = 1;
}
