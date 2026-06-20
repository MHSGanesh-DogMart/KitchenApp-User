import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '../discover/_discover_widgets.dart';

/// Mockup 23 — Pickup code.
class PickupCodeScreen extends StatelessWidget {
  const PickupCodeScreen({
    super.key,
    this.cookName = 'Sunita Aunty',
    this.code = '82 01',
    this.distance = '~0.4 km',
    this.spot = 'Block 5 gate',
  });
  final String cookName;
  final String code;
  final String distance;
  final String spot;

  @override
  Widget build(BuildContext context) {
    final initials = cookName
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const PlainAppBar(title: 'Pickup'),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primary.withValues(alpha: .35),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Collect from $cookName',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$spot · $distance',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'Show this code at pickup',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      code,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 58.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: 10,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: AuthButton(
                label: 'Get directions',
                variant: AuthBtnVariant.ghost,
                icon: Icons.directions_rounded,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
