import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../buttons/app_primary_button.dart';
import 'no_internet_view.dart';

/// Smart error state. If the [error] is a [NoInternetException] it
/// renders [NoInternetView] automatically; otherwise it shows a generic
/// failure card with Retry.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    this.error,
    this.title = AppStrings.errorTitle,
    this.message = AppStrings.somethingWentWrong,
    this.onRetry,
    this.isRetrying = false,
  });

  /// Pass the exception/object that caused the failure so the widget
  /// can pick the right rendering. Optional.
  final Object? error;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool isRetrying;

  bool get _isOffline => error is NoInternetException;

  @override
  Widget build(BuildContext context) {
    if (_isOffline && onRetry != null) {
      return NoInternetView(onRetry: onRetry!, isRetrying: isRetrying);
    }

    // Generic error card.
    final theme = Theme.of(context);
    final msg = error is ApiException
        ? (error as ApiException).message
        : message;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.redAccent),
            SizedBox(height: AppSizes.lg),
            Text(title, style: theme.textTheme.titleLarge),
            SizedBox(height: AppSizes.sm),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSizes.xl),
              SizedBox(
                width: 200.w,
                child: AppPrimaryButton(
                  label: AppStrings.retry,
                  onPressed: onRetry,
                  isLoading: isRetrying,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
