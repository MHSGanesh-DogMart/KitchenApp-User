import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/connectivity_provider.dart';

/// Static, slim, ambient banner. Shows only after the device has been
/// offline for a short grace window — avoids flicker during quick
/// network handoffs (Wi-Fi ↔ 4G). No motion, no modal — just a quiet
/// signal at the top of [AppScaffold].
class NoInternetBanner extends StatefulWidget {
  const NoInternetBanner({super.key});

  @override
  State<NoInternetBanner> createState() => _NoInternetBannerState();
}

class _NoInternetBannerState extends State<NoInternetBanner> {
  static const _grace = Duration(seconds: 2);

  Timer? _debounce;
  bool _show = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _scheduleShow(bool online) {
    _debounce?.cancel();
    if (online) {
      // Back online → hide immediately.
      if (_show) setState(() => _show = false);
      return;
    }
    // Offline → wait the grace period before showing.
    _debounce = Timer(_grace, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityProvider>().isOnline;
    _scheduleShow(online);

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: !_show ? const SizedBox.shrink() : const _BannerRow(),
    );
  }
}

class _BannerRow extends StatelessWidget {
  const _BannerRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 14.sp, color: Colors.white),
          SizedBox(width: AppSizes.sm),
          Text(
            AppStrings.noInternet,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}
