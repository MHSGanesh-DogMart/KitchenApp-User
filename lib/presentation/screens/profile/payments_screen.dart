import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../discover/_discover_widgets.dart';
import '_profile_widgets.dart';

/// Mockup 35 — Payments & refunds.
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PlainAppBar(title: 'Payments'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                children: [
                  const ProfileKicker('Saved'),
                  CardGroup(children: [
                    MenuRow(
                      leadingEmoji: '📱',
                      title: 'PhonePe UPI',
                      onTap: () {},
                    ),
                    MenuRow(
                      leadingEmoji: '💳',
                      title: 'HDFC •• 4421',
                      onTap: () {},
                    ),
                    MenuRow(
                      leadingIcon: Icons.add_rounded,
                      title: 'Add new payment method',
                      onTap: () {},
                    ),
                  ]),
                  const ProfileKicker('Refunds'),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.check_rounded,
                              color: AppColors.secondary, size: 18.sp),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Refund · #PD4012',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'PhonePe · 8 May',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+ ₹120',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
