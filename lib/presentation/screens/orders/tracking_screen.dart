import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../auth/_auth_widgets.dart';
import '../discover/_discover_widgets.dart';
import '../padosi/mock/mock_data.dart';

/// Mockup 21 — Order tracking.
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, this.cook});
  final Cook? cook;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                PlainAppBar(
                  title: 'Your order',
                  trailing: Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: const BorderSide(color: AppColors.line),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.chat),
                      child: SizedBox(
                        width: 38.w,
                        height: 38.w,
                        child: Icon(Icons.chat_bubble_outline_rounded,
                            size: 18.sp, color: AppColors.ink),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 110.h),
                    children: [
                      // Map placeholder
                      Container(
                        height: 140.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: AppColors.line),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD6EBE5), Color(0xFFE9F4F0)],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 32.h,
                              left: 38.w,
                              child: Icon(Icons.home_rounded,
                                  color: AppColors.secondary, size: 22.sp),
                            ),
                            Positioned(
                              bottom: 22.h,
                              right: 44.w,
                              child: Icon(Icons.location_on_rounded,
                                  color: AppColors.primary, size: 22.sp),
                            ),
                            Positioned(
                              top: 60.h,
                              left: 80.w,
                              child: Transform.rotate(
                                angle: 0.42,
                                child: Container(
                                  width: 110.w,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius:
                                        BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 64.h,
                              left: 124.w,
                              child: Icon(Icons.directions_bike_rounded,
                                  color: AppColors.primary, size: 22.sp),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Delivery partner card
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        padding: EdgeInsets.all(12.w),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 19.r,
                              backgroundColor: AppColors.ink,
                              child: Text(
                                'RK',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 11.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ravi · Delivery',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    '~10 min away',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _RoundIcon(
                              icon: Icons.call_rounded,
                              color: AppColors.secondary,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      // Status header
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20.h, 0, 10.h),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Status',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              '#PD4821',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Timeline
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        padding:
                            EdgeInsets.fromLTRB(15.w, 16.h, 15.w, 4.h),
                        child: const Column(
                          children: [
                            _Step(
                              done: true,
                              title: 'Confirmed',
                              time: '11:02',
                            ),
                            _Step(
                              done: true,
                              title: 'Cooking',
                              time: '11:10',
                            ),
                            _Step(
                              active: true,
                              title: 'Out for delivery',
                              time: '11:48',
                            ),
                            _Step(
                              title: 'Delivered',
                              time: 'Est. 12:00',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // OTP banner (shortcut to mockup 22)
                      Material(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(16.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () => Navigator.pushNamed(
                              context, RouteNames.deliveryOtp),
                          child: Padding(
                            padding: EdgeInsets.all(13.w),
                            child: Row(
                              children: [
                                Icon(Icons.vpn_key_rounded,
                                    color: AppColors.primaryDark,
                                    size: 18.sp),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: AppColors.primaryDark,
                                      ),
                                      children: const [
                                        TextSpan(
                                            text: 'Delivery code: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700)),
                                        TextSpan(
                                          text: '3914',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '   — show to rider',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    color: AppColors.primaryDark,
                                    size: 18.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyBar(
              child: AuthButton(
                label: 'Report a problem',
                variant: AuthBtnVariant.ghost,
                icon: Icons.flag_outlined,
                onPressed: () => Navigator.pushNamed(
                    context, RouteNames.reportProblem),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: SizedBox(
          width: 38.w,
          height: 38.w,
          child: Icon(icon, color: color, size: 18.sp),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.time,
    this.done = false,
    this.active = false,
    this.isLast = false,
  });
  final String title;
  final String time;
  final bool done;
  final bool active;
  final bool isLast;
  @override
  Widget build(BuildContext context) {
    final dotColor = done
        ? AppColors.secondary
        : active
            ? AppColors.primary
            : AppColors.line;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: done || active ? dotColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 10)
                    : active
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 34,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  color: done ? dotColor : AppColors.line,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? AppColors.primaryDark
                          : done
                              ? AppColors.ink
                              : AppColors.muted,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
