import 'package:flutter/material.dart';

void dismissKeyboard(BuildContext context) {
  final scope = FocusScope.of(context);
  if (!scope.hasPrimaryFocus && scope.hasFocus) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
