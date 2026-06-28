import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/coupon.dart';
import '../auth/_auth_widgets.dart';
import '_discover_widgets.dart';

/// Mockup 17 — Coupons / offers.
///
/// Live list from /api/user/coupons. Each card reflects the current cart:
///   • applied      → highlighted, "Remove"
///   • applicable   → normal, "Apply"
///   • locked       → greyed, "Add ₹X more to unlock"
///   • other applied→ greyed (one coupon at a time)
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});
  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  final _ctrl = TextEditingController();
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

  Future<void> _apply(String code) async {
    if (code.trim().isEmpty) return;
    final ok = await CartController.instance.applyCoupon(code.trim().toUpperCase());
    if (!mounted) return;
    if (ok) Navigator.pop(context, code.trim().toUpperCase());
  }

  Future<void> _remove() async {
    await CartController.instance.removeCoupon();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final subtotal = cart.cart.bill.itemTotal;
    final appliedCode = cart.cart.bill.couponCode;

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
                  _ApplyField(controller: _ctrl, onApply: () => _apply(_ctrl.text)),
                  if (subtotal > 0) ...[
                    SizedBox(height: 10.h),
                    Text(
                      'Cart total ₹${subtotal.round()} · offers update as your cart grows',
                      style: GoogleFonts.inter(fontSize: 11.5.sp, color: AppColors.muted),
                    ),
                  ],
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
                    ..._coupons.map((c) {
                      final isApplied = appliedCode == c.code;
                      final meetsMin = subtotal >= c.minOrderValue;
                      final blockedByOther = appliedCode != null && !isApplied;
                      final needed = (c.minOrderValue - subtotal).ceil();
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _CouponCard(
                          coupon: c,
                          isApplied: isApplied,
                          locked: !meetsMin,
                          blockedByOther: blockedByOther,
                          amountToUnlock: needed > 0 ? needed : 0,
                          onApply: () => _apply(c.code),
                          onRemove: _remove,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── apply field ───────────────────────────

class _ApplyField extends StatelessWidget {
  const _ApplyField({required this.controller, required this.onApply});
  final TextEditingController controller;
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                border: Border.all(color: AppColors.line),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseFormatter()],
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter code',
                  hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.muted),
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
              onPressed: onApply,
            ),
          ),
        ],
      ),
    );
  }
}

/// Forces the coupon code field to uppercase.
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

// ─────────────────────────── coupon card ───────────────────────────

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.isApplied,
    required this.locked,
    required this.blockedByOther,
    required this.amountToUnlock,
    required this.onApply,
    required this.onRemove,
  });
  final Coupon coupon;
  final bool isApplied;
  final bool locked;
  final bool blockedByOther;
  final int amountToUnlock;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  bool get _dimmed => !isApplied && (locked || blockedByOther);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isApplied ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isApplied ? AppColors.primary : AppColors.line,
          width: isApplied ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Benefit tile
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: locked ? AppColors.cream : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  coupon.type == 'free_delivery'
                      ? Icons.delivery_dining_rounded
                      : Icons.local_offer_rounded,
                  color: locked ? AppColors.muted : AppColors.primary,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          coupon.code,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Text(
                            coupon.benefit,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (coupon.description.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        coupon.description,
                        style: GoogleFonts.inter(fontSize: 11.5.sp, color: AppColors.inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _actionButton(),
            ],
          ),
          // Status subline
          SizedBox(height: 8.h),
          _statusLine(),
        ],
      ),
    );

    return Opacity(opacity: _dimmed ? 0.6 : 1, child: card);
  }

  Widget _statusLine() {
    if (isApplied) {
      return Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 13.sp, color: AppColors.success),
          SizedBox(width: 5.w),
          Text(
            'Applied to this order',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      );
    }
    if (locked) {
      return Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 13.sp, color: AppColors.primary),
          SizedBox(width: 5.w),
          Text(
            'Add ₹$amountToUnlock more to unlock',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }
    if (blockedByOther) {
      return Text(
        'Remove the applied coupon to use this one',
        style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.muted),
      );
    }
    return Text(
      coupon.minOrderValue > 0 ? 'Min order ₹${coupon.minOrderValue.round()}' : 'No minimum order',
      style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.muted),
    );
  }

  Widget _actionButton() {
    if (isApplied) {
      return _pill('Remove', onRemove, filled: false);
    }
    final enabled = !locked && !blockedByOther;
    return _pill('Apply', enabled ? onApply : null, filled: true, enabled: enabled);
  }

  Widget _pill(String label, VoidCallback? onTap, {required bool filled, bool enabled = true}) {
    final bg = !enabled
        ? AppColors.line
        : filled
            ? AppColors.primary
            : Colors.transparent;
    final fg = !enabled
        ? AppColors.muted
        : filled
            ? Colors.white
            : AppColors.primaryDark;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(99.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(99.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: filled || !enabled
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(99.r),
                  border: Border.all(color: AppColors.primary),
                ),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
