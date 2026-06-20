import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Small pill chip with semantic color variant.
class PadosiChip extends StatelessWidget {
  const PadosiChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = PadosiChipVariant.line,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final PadosiChipVariant variant;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      PadosiChipVariant.verified => (
        AppColors.secondarySoft,
        AppColors.secondary,
        null,
      ),
      PadosiChipVariant.coral => (
        AppColors.primarySoft,
        AppColors.primaryDark,
        null,
      ),
      PadosiChipVariant.fresh => (AppColors.freshSoft, AppColors.fresh, null),
      PadosiChipVariant.tier1 => (AppColors.tier1Soft, AppColors.tier1, null),
      PadosiChipVariant.tier2 => (AppColors.tier2Soft, AppColors.tier2, null),
      PadosiChipVariant.violet => (
        AppColors.violetSoft,
        AppColors.violet,
        null,
      ),
      PadosiChipVariant.line => (
        Colors.transparent,
        AppColors.inkSoft,
        AppColors.line,
      ),
      PadosiChipVariant.dark => (
        Colors.white.withValues(alpha: .12),
        Colors.white,
        null,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8.w : 10.w,
        vertical: dense ? 4.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11.sp, color: fg),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: dense ? 10.sp : 10.5.sp,
              fontWeight: FontWeight.w600,
              color: fg,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

enum PadosiChipVariant {
  verified,
  coral,
  fresh,
  tier1,
  tier2,
  violet,
  line,
  dark,
}

/// Tier badge — slightly heavier, square-ish.
class TierBadge extends StatelessWidget {
  const TierBadge.tier1({super.key, this.label = '🏠 Home Chef · FSSAI Basic'})
    : _isTier1 = true;
  const TierBadge.tier2({super.key, this.label = '✓ FSSAI Licensed Kitchen'})
    : _isTier1 = false;

  final String label;
  final bool _isTier1;

  @override
  Widget build(BuildContext context) {
    final bg = _isTier1 ? AppColors.tier1Soft : AppColors.tier2Soft;
    final fg = _isTier1 ? AppColors.tier1 : AppColors.tier2;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Geist',
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
