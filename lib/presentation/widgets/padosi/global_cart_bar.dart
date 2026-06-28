import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';

/// Floating cart bar shown on (almost) every screen when the cart
/// is non-empty. Single source of truth for "items in cart" UI —
/// dish detail / cook detail screens used to have their own — now
/// they all defer to this one.
///
/// Usage: drop inside a `Stack` overlaying the screen body, OR call
/// the convenience static [overlay] that wraps any widget with it.
class GlobalCartBar extends StatelessWidget {
  const GlobalCartBar({super.key, this.bottomInset = 0});

  /// Extra bottom padding (e.g. the height of a bottom-nav bar).
  final double bottomInset;

  /// Convenience: wrap [child] in a Stack with the bar floating at
  /// the bottom. Use this for screens that don't already have a
  /// Stack root.
  static Widget overlay(Widget child, {double bottomInset = 0}) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GlobalCartBar(bottomInset: bottomInset),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (_, cart, _) {
        final items = cart.itemCount;
        if (items == 0) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h + bottomInset),
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: .08),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 6.w, 10.h),
              child: Row(
                children: [
                  // Left: price total + items
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Price total',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${cart.subtotal.round()}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: -.4,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '$items item${items == 1 ? '' : 's'}',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Right: orange "View cart" pill
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.cart),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 14.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_bag_rounded,
                              color: Colors.white,
                              size: 17.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'View cart',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
