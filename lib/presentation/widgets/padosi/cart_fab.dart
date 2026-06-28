import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';

/// Compact floating cart button — used on the 5 tab screens where the
/// full [GlobalCartBar] would clash with the floating bottom nav.
///
/// Tangerine circle with a shopping-bag icon and an ink badge in the
/// top-right showing the live cart count. Auto-hides when empty.
class CartFab extends StatelessWidget {
  const CartFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (_, cart, _) {
        final n = cart.itemCount;
        if (n == 0) return const SizedBox.shrink();
        return Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pushNamed(context, RouteNames.cart),
            child: SizedBox(
              width: 56.w,
              height: 56.w,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Shadow ring under the icon (matches floating nav vibe)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.shopping_bag_rounded,
                    color: Colors.white,  
                    size: 24.sp,
                  ),
                  // Badge — top right
                  Positioned(
                    top: -2.h,
                    right: -2.w,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 20.w,
                        minHeight: 20.w,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(99.r),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        n > 99 ? '99+' : '$n',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          height: 1,
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
