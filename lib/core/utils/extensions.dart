import 'package:flutter/material.dart';

extension StringX on String {
  bool get isEmail {
    final r = RegExp(r'^[\w\.\-+]+@[\w\-]+\.[a-zA-Z]{2,}$');
    return r.hasMatch(trim());
  }

  bool get isPhone {
    final r = RegExp(r'^\+?[0-9]{7,15}$');
    return r.hasMatch(trim());
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  MediaQueryData get mq => MediaQuery.of(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
