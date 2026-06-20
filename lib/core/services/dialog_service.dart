import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import 'navigation_service.dart';

class DialogService {
  DialogService._();

  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmText = AppStrings.yes,
    String cancelText = AppStrings.cancel,
    bool destructive = false,
  }) async {
    final ctx = NavigationService.context;
    if (ctx == null) return false;
    final result = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            style: destructive
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> alert({
    required String title,
    required String message,
    String okText = AppStrings.ok,
  }) async {
    final ctx = NavigationService.context;
    if (ctx == null) return;
    await showDialog<void>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(okText),
          ),
        ],
      ),
    );
  }

  static void showLoading() {
    final ctx = NavigationService.context;
    if (ctx == null) return;
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void hideLoading() {
    if (NavigationService.canPop()) NavigationService.pop();
  }
}
