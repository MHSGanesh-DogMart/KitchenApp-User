import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../screens/padosi/mock/mock_data.dart';

/// Premium dish/menu card — same recipe used everywhere a dish is shown:
///   pastel tint surface · 1.08:1 hero with kcal pill · name + subtitle ·
///   price + dark "+" that morphs into a "− N +" stepper.
///
/// Works inside a SliverGrid (cell-sized) AND inside a horizontal
/// ListView (caller provides a SizedBox with explicit width + height).
class DishGridCard extends StatelessWidget {
  const DishGridCard({
    super.key,
    required this.dish,
    required this.tint,
    required this.subtitle,
    required this.count,
    required this.onInc,
    required this.onDec,
    this.onTap,
  });
  final Dish dish;
  final Color tint;
  final String subtitle;
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap ?? onInc,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero (1.08:1) with optional kcal pill
              AspectRatio(
                aspectRatio: 1.08,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: SizedBox.expand(
                        child: dish.image != null
                            ? CachedNetworkImage(
                                imageUrl: dish.image!,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Shimmer.fromColors(
                                  baseColor:
                                      Colors.white.withValues(alpha: .35),
                                  highlightColor: Colors.white,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (_, _, _) => _fallback(),
                              )
                            : _fallback(),
                      ),
                    ),
                    if (dish.kcal != null)
                      Positioned(
                        bottom: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .6),
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Text(
                            '${dish.kcal} kcal',
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -.2,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.ink.withValues(alpha: .65),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${dish.price}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: count == 0
                              ? DishAddBtn(
                                  key: const ValueKey('add'),
                                  onTap: onInc,
                                )
                              : DishStepper(
                                  key: const ValueKey('step'),
                                  count: count,
                                  onInc: onInc,
                                  onDec: onDec,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dish.heroGradient,
          ),
        ),
        child: Center(
          child: Text(dish.emoji, style: TextStyle(fontSize: 40.sp)),
        ),
      );
}

/// 28×28 dark ink "+" circle. Used by [DishGridCard] when count == 0.
class DishAddBtn extends StatelessWidget {
  const DishAddBtn({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 17.sp),
        ),
      ),
    );
  }
}

/// Dark ink pill stepper (− N +). Used by [DishGridCard] when count > 0.
class DishStepper extends StatelessWidget {
  const DishStepper({
    super.key,
    required this.count,
    required this.onInc,
    required this.onDec,
  });
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.w,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onDec,
            child: SizedBox(
              width: 26.w,
              height: 28.w,
              child:
                  Icon(Icons.remove_rounded, color: Colors.white, size: 15.sp),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: SizedBox(
              key: ValueKey(count),
              width: 18.w,
              child: Center(
                child: Text(
                  '$count',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onInc,
            child: SizedBox(
              width: 26.w,
              height: 28.w,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 15.sp),
            ),
          ),
        ],
      ),
    );
  }
}
