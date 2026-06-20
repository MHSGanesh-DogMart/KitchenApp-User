import '../../../core/services/toast_service.dart';

class AppToast {
  AppToast._();
  static void success(String m) => ToastService.success(m);
  static void error(String m) => ToastService.error(m);
  static void info(String m) => ToastService.info(m);
}
