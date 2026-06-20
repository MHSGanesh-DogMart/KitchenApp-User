import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '_discover_widgets.dart';

/// Mockup 17 — Coupons / offers.
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});
  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final _ctrl = TextEditingController();
  String? _applied;

  static const _coupons = <_Coupon>[
    _Coupon(
      code: 'FRESH50',
      title: '50% off your first order',
      sub: 'Up to ₹100 · min ₹149',
    ),
    _Coupon(
      code: 'HOME20',
      title: '20% off home chefs',
      sub: 'Up to ₹60',
    ),
    _Coupon(
      code: 'WEEKEND',
      title: 'Free delivery this weekend',
      sub: 'On orders above ₹199',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PlainAppBar(title: 'Offers'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                children: [
                  // Apply field
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(11.r),
                              border: Border.all(
                                color: AppColors.line,
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            child: TextField(
                              controller: _ctrl,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                letterSpacing: 1.2,
                              ),
                              textCapitalization:
                                  TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Enter code',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: AppColors.muted,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        SizedBox(
                          width: 80.w,
                          child: AuthButton(
                            label: 'Apply',
                            variant: AuthBtnVariant.ink,
                            onPressed: () {
                              if (_ctrl.text.isEmpty) return;
                              setState(() =>
                                  _applied = _ctrl.text.toUpperCase());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  ..._coupons.map((c) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _CouponCard(
                          coupon: c,
                          applied: _applied == c.code,
                          onApply: () {
                            setState(() => _applied = c.code);
                            Navigator.pop(context, c.code);
                          },
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Coupon {
  const _Coupon({
    required this.code,
    required this.title,
    required this.sub,
  });
  final String code;
  final String title;
  final String sub;
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.applied,
    required this.onApply,
  });
  final _Coupon coupon;
  final bool applied;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: applied ? AppColors.primary : AppColors.line,
          width: applied ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                coupon.code,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: applied ? null : onApply,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                ),
                child: Text(
                  applied ? 'Applied' : 'Apply',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: applied
                        ? AppColors.success
                        : AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            coupon.title,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            coupon.sub,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
