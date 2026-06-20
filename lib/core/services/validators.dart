import '../constants/app_strings.dart';
import '../utils/extensions.dart';

class Validators {
  Validators._();

  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.required;
    return null;
  }

  static String? email(String? v) {
    final r = required(v);
    if (r != null) return r;
    if (!v!.isEmail) return AppStrings.invalidEmail;
    return null;
  }

  static String? phone(String? v) {
    final r = required(v);
    if (r != null) return r;
    if (!v!.isPhone) return AppStrings.invalidPhone;
    return null;
  }

  static String? password(String? v, {int min = 8}) {
    final r = required(v);
    if (r != null) return r;
    if (v!.length < min) return AppStrings.weakPassword;
    return null;
  }

  static String? Function(String?) match(String? other, {String message = AppStrings.passwordMismatch}) {
    return (v) {
      final r = required(v);
      if (r != null) return r;
      if (v != other) return message;
      return null;
    };
  }

  static String? minLength(String? v, int min) {
    final r = required(v);
    if (r != null) return r;
    if (v!.length < min) return 'Must be at least $min characters';
    return null;
  }
}
