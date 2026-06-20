import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../states/app_loader.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || isLoading || onPressed == null;
    final btn = ElevatedButton(
      onPressed: disabled ? null : onPressed,
      child: isLoading
          ? const AppLoader(size: 22, strokeWidth: 2.4, color: Colors.white)
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppSizes.iconMd),
                  SizedBox(width: AppSizes.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
