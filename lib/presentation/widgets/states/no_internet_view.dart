import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../buttons/app_primary_button.dart';

/// Full-screen inline "you're offline" state (image-2 style).
/// Keeps the surrounding chrome (AppBar / bottom nav) and replaces only
/// the failing content area. Hand it an [onRetry] that re-runs the
/// fetch that failed.
class NoInternetView extends StatelessWidget {
  const NoInternetView({
    super.key,
    this.title = 'Ooops!',
    this.message =
        'It seems there is something wrong with your internet connection. Please connect and try again.',
    this.actionLabel = 'Try Again',
    required this.onRetry,
    this.isRetrying = false,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.xxl,
          vertical: AppSizes.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Illustration(isDark: isDark),
            SizedBox(height: AppSizes.xxl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppSizes.xxxl),
            SizedBox(
              width: 220.w,
              child: AppPrimaryButton(
                label: actionLabel,
                onPressed: onRetry,
                isLoading: isRetrying,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? AppColors.primary.withValues(alpha: .12)
        : AppColors.primary.withValues(alpha: .08);
    final iconColor = AppColors.primary;
    final ringColor = iconColor.withValues(alpha: .15);

    return SizedBox(
      width: 180.r,
      height: 180.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          ),
          Container(
            width: 140.r,
            height: 140.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 2),
            ),
          ),
          Icon(Icons.wifi_off_rounded, size: 72.sp, color: iconColor),
        ],
      ),
    );
  }
}
