import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/app_colors.dart';

class ToastService {
  ToastService._();

  static void success(String message) => _show(message, AppColors.success);
  static void error(String message) => _show(message, AppColors.error);
  static void info(String message) => _show(message, AppColors.info);

  static void _show(String message, Color bg) {
    if (message.trim().isEmpty) return;
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bg,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}
