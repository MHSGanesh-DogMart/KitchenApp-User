import 'package:permission_handler/permission_handler.dart';
import '../constants/app_strings.dart';
import 'dialog_service.dart';

class PermissionService {
  PermissionService._();

  static Future<bool> request(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      final open = await DialogService.confirm(
        title: AppStrings.permissionDenied,
        message: AppStrings.permissionPermDeniedMsg,
        confirmText: AppStrings.openSettings,
      );
      if (open) await openAppSettings();
      return false;
    }
    final result = await permission.request();
    return result.isGranted;
  }

  static Future<bool> camera() => request(Permission.camera);
  static Future<bool> photos() => request(Permission.photos);
  static Future<bool> storage() => request(Permission.storage);
  static Future<bool> microphone() => request(Permission.microphone);
  static Future<bool> locationWhenInUse() => request(Permission.locationWhenInUse);
  static Future<bool> notification() => request(Permission.notification);
}
