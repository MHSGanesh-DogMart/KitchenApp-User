import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/coupon.dart';
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

  List<Coupon> _coupons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await CartController.instance.fetchCoupons();
    if (!mounted) return;
    setState(() {
      _coupons = list;
      _loading = false;
    });
  }

  /// Apply [code] to the server cart; on success return it to the caller.
  Future<void> _apply(String code) async {
    if (code.isEmpty) return;
    final ok = await CartController.instance.applyCoupon(code.toUpperCase());
    if (!mounted) return;
    if (ok) {
      setState(() => _applied = code.toUpperCase());
      Navigator.pop(context, code.toUpperCase());
    }
  }

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
                            onPressed: () => _apply(_ctrl.text.trim()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  if (_loading)
                    Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (_coupons.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: Text(
                        'No offers available right now',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.muted),
                      ),
                    )
                  else
                    ..._coupons.map((c) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _CouponCard(
                            coupon: c,
                            applied: _applied == c.code,
                            onApply: () => _apply(c.code),
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

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.applied,
    required this.onApply,
  });
  final Coupon coupon;
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
            coupon.benefit,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          if (coupon.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              coupon.description,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
