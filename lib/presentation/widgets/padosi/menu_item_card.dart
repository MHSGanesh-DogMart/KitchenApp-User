import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../screens/padosi/mock/mock_data.dart';

/// Premium "today's menu" card — pastel surface, hero food image,
/// serif name + price/kcal. Inspired by the croissant reference card.
class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.width,
    this.onTap,
    this.onAdd,
  });

  final MenuItem item;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: item.tint,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(22.r),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ──
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18.r),
                        child: _NetworkPhoto(url: item.image),
                      ),
                      if (item.badge != null)
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: _Badge(label: item.badge!),
                        ),
                      Positioned(
                        bottom: 8.h,
                        right: 8.w,
                        child: _KcalPill(kcal: item.kcal),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // ── Name + weight ──
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.3,
                    color: AppColors.ink,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${item.cookName}${item.weightLabel != null ? " · ${item.weightLabel}" : ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.ink.withValues(alpha: .65),
                  ),
                ),
                SizedBox(height: 10.h),
                // ── Price + Add button row ──
                Row(
                  children: [
                    Text(
                      '₹${item.priceInr}',
                      style: TextStyle(
                        fontFamily: AppTextStyles.displayFamily,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: AppColors.ink,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onAdd,
                        child: SizedBox(
                          width: 32.w,
                          height: 32.w,
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded,
              color: AppColors.primary, size: 11.sp),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFamily,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _KcalPill extends StatelessWidget {
  const _KcalPill({required this.kcal});
  final int kcal;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Text(
        '$kcal kcal',
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFamily,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Reusable network image with shimmer placeholder + graceful fallback.
class _NetworkPhoto extends StatelessWidget {
  const _NetworkPhoto({required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: .35),
        highlightColor: Colors.white.withValues(alpha: .8),
        child: Container(color: Colors.white.withValues(alpha: .4)),
      ),
      errorWidget: (_, _, _) => Container(
        color: Colors.black.withValues(alpha: .04),
        alignment: Alignment.center,
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.ink.withValues(alpha: .25),
          size: 36.sp,
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 220),
    );
  }
}
