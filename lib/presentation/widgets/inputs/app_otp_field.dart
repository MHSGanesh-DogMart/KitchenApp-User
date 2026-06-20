import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class AppOtpField extends StatelessWidget {
  const AppOtpField({
    super.key,
    this.controller,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.focusNode,
    this.autoFocus = true,
  });

  final TextEditingController? controller;
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    );
    return Pinput(
      controller: controller,
      length: length,
      focusNode: focusNode,
      autofocus: autoFocus,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: defaultTheme.copyDecorationWith(
        border: Border.all(color: AppColors.primary, width: 1.4),
      ),
      submittedPinTheme: defaultTheme.copyDecorationWith(
        border: Border.all(color: AppColors.primary),
      ),
      onCompleted: onCompleted,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
    );
  }
}
