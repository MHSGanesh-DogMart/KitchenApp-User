import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import 'padosi_chips.dart';

/// Rounded surface card with subtle shadow + border.
/// Pass [onTap] for a Material ripple.
class PadosiCard extends StatelessWidget {
  const PadosiCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.borderWidth = 1,
    this.background = AppColors.surface,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double borderWidth;
  final Color background;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.radiusXl);
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: borderColor ?? AppColors.line, width: borderWidth),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16181D).withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Big featured cook card (used on Home).
class CookFeatureCard extends StatelessWidget {
  const CookFeatureCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.tier,
    required this.heroEmoji,
    required this.heroGradient,
    this.imageUrl,
    this.distanceKm,
    this.etaMin,
    this.onTap,
  });

  final String name;
  final String subtitle;
  final double rating;
  final int tier; // 1 or 2
  final String heroEmoji;
  final List<Color> heroGradient;
  final String? imageUrl;
  final double? distanceKm;
  final int? etaMin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PadosiCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero image (network) ──
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Shimmer.fromColors(
                      baseColor: AppColors.line,
                      highlightColor: Colors.white,
                      child: Container(color: AppColors.line),
                    ),
                    errorWidget: (_, _, _) => _GradientFallback(
                      gradient: heroGradient,
                      emoji: heroEmoji,
                    ),
                  )
                else
                  _GradientFallback(gradient: heroGradient, emoji: heroEmoji),
                // Soft gradient overlay so chips & text stay readable
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x44000000),
                      ],
                      stops: [0.55, 1],
                    ),
                  ),
                ),
                // Tier badge top-left
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: tier == 1
                        ? const TierBadge.tier1()
                        : const TierBadge.tier2(),
                  ),
                ),
                // Favourite top-right
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.favorite_border_rounded,
                        color: AppColors.ink, size: 16.sp),
                  ),
                ),
                // Rating bottom-right over image
                Positioned(
                  bottom: 10.h,
                  right: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded,
                            color: const Color(0xFFFFD24A), size: 12.sp),
                        SizedBox(width: 3.w),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Info row ──
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFamily,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    letterSpacing: -.3,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(subtitle,
                    style: AppTextStyles.tiny
                        .copyWith(color: AppColors.inkSoft)),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    if (distanceKm != null)
                      PadosiChip(
                        icon: Icons.place_outlined,
                        label: '${distanceKm!.toStringAsFixed(1)} km',
                        dense: true,
                      ),
                    if (etaMin != null && etaMin! > 0)
                      PadosiChip(
                        icon: Icons.schedule_rounded,
                        label: '$etaMin min',
                        dense: true,
                      ),
                    const PadosiChip(
                      icon: Icons.verified_rounded,
                      label: 'Verified',
                      variant: PadosiChipVariant.verified,
                      dense: true,
                    ),
                    const PadosiChip(
                      icon: Icons.shield_outlined,
                      label: 'Refund protected',
                      variant: PadosiChipVariant.fresh,
                      dense: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientFallback extends StatelessWidget {
  const _GradientFallback({required this.gradient, required this.emoji});
  final List<Color> gradient;
  final String emoji;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Center(child: Text(emoji, style: TextStyle(fontSize: 48.sp))),
    );
  }
}

/// Compact horizontal cook row (used on Discover).
class CookListRow extends StatelessWidget {
  const CookListRow({
    super.key,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.tier,
    required this.heroEmoji,
    required this.heroGradient,
    this.isNew = false,
    this.onTap,
  });

  final String name;
  final String subtitle;
  final double rating;
  final int tier;
  final String heroEmoji;
  final List<Color> heroGradient;
  final bool isNew;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PadosiCard(
      padding: EdgeInsets.all(12.w),
      onTap: onTap,
      child: Row(
          children: [
            Container(
              width: 74.w,
              height: 74.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: heroGradient,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: Text(heroEmoji, style: TextStyle(fontSize: 32.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      tier == 1
                          ? const TierBadge.tier1(label: '🏠 Tier 1')
                          : const TierBadge.tier2(label: '✓ Tier 2'),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: AppTextStyles.tiny),
                  SizedBox(height: 8.h),
                  Wrap(spacing: 6.w, runSpacing: 4.h, children: [
                    PadosiChip(
                      label: tier == 1 ? '✓ FSSAI Basic' : '✓ FSSAI Licensed',
                      variant: PadosiChipVariant.verified,
                      dense: true,
                    ),
                    PadosiChip(label: '⭐ ${rating.toStringAsFixed(1)}', dense: true),
                    if (isNew)
                      const PadosiChip(label: '🆕 New', variant: PadosiChipVariant.violet, dense: true),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
