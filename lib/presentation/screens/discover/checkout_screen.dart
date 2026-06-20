import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../padosi/mock/mock_data.dart';

/// Mockup 18 — Checkout.
/// Premium polish: custom hero header, ink/cream cards with kicker
/// labels, animated selected-state for delivery/pickup pills,
/// sticky tangerine "Pay ₹X" pill with `Lock` icon to convey trust.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.cook,
    required this.cart,
    required this.subtotal,
  });
  final Cook cook;
  final Map<String, int> cart;
  final int subtotal;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _mode = 0; // 0 delivery, 1 pickup
  String? _coupon = 'FRESH50';
  String _payment = 'UPI · PhonePe';

  int get _delivery => _mode == 0 ? 25 : 0;
  int get _taxes => 14;
  int get _discount => _coupon == 'FRESH50' ? 90 : 0;
  int get _total =>
      (widget.subtotal + _delivery + _taxes - _discount).clamp(0, 999999);

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
                _CheckoutHeader(eta: widget.cook.etaMin),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 140.h),
                    children: [
                      // ── Address ──
                      _SectionLabel(label: 'DELIVER TO'),
                      SizedBox(height: 8.h),
                      _RowCard(
                        leadingIcon: Icons.place_rounded,
                        leadingBg: AppColors.primarySoft,
                        leadingFg: AppColors.primary,
                        title: 'Home · Koramangala 5th',
                        sub: 'Flat 402, Brigade Towers · 30 m away',
                        action: 'Change',
                        onAction: () {},
                      ),

                      SizedBox(height: 18.h),

                      // ── Delivery / Pickup ──
                      _SectionLabel(label: 'HOW SHOULD WE SEND IT?'),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: _ModeCard(
                              selected: _mode == 0,
                              icon: Icons.delivery_dining_rounded,
                              title: 'Delivery',
                              sub: '${widget.cook.etaMin} min',
                              foot: '₹25',
                              onTap: () => setState(() => _mode = 0),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _ModeCard(
                              selected: _mode == 1,
                              icon: Icons.takeout_dining_rounded,
                              title: 'Pickup',
                              sub: 'Ready in 20 min',
                              foot: 'Save ₹25',
                              footHighlight: true,
                              onTap: () => setState(() => _mode = 1),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18.h),

                      // ── Payment ──
                      _SectionLabel(label: 'PAYMENT'),
                      SizedBox(height: 8.h),
                      _RowCard(
                        leadingIcon:
                            Icons.account_balance_wallet_rounded,
                        leadingBg: AppColors.cream,
                        leadingFg: AppColors.ink,
                        title: _payment,
                        sub: 'Prepaid · Tap to change',
                        action: 'Change',
                        onAction: () async {
                          final r = await Navigator.pushNamed(
                              context, RouteNames.paymentMethod);
                          if (r is String) setState(() => _payment = r);
                        },
                      ),
                      SizedBox(height: 10.h),
                      _RowCard(
                        leadingIcon: Icons.local_offer_rounded,
                        leadingBg: AppColors.secondarySoft,
                        leadingFg: AppColors.secondary,
                        title: _coupon == null
                            ? 'Apply coupon'
                            : 'Coupon $_coupon applied',
                        sub: _coupon == null
                            ? 'See available offers'
                            : 'You saved ₹$_discount',
                        action: _coupon == null ? 'Apply' : 'Remove',
                        onAction: () async {
                          if (_coupon != null) {
                            setState(() => _coupon = null);
                            return;
                          }
                          final r = await Navigator.pushNamed(
                              context, RouteNames.coupons);
                          if (r is String) setState(() => _coupon = r);
                        },
                      ),

                      SizedBox(height: 18.h),

                      // ── Bill ──
                      _SectionLabel(label: 'BILL DETAILS'),
                      SizedBox(height: 8.h),
                      _BillCard(
                        subtotal: widget.subtotal,
                        delivery: _delivery,
                        taxes: _taxes,
                        discount: _discount,
                        couponLabel: _coupon,
                        total: _total,
                      ),

                      SizedBox(height: 12.h),

                      // ── Protection ribbon ──
                      _ProtectionRibbon(),
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
            child: _PayBar(
              total: _total,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                RouteNames.orderPlaced,
                arguments: {'cook': widget.cook, 'total': _total},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── header ───────────────────────────

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.eta});
  final int eta;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 16.w, 6.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.ink,
            iconSize: 22.sp,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checkout',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.5,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Confirm your order · ETA $eta min',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────── row card ───────────────────────────

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.leadingIcon,
    required this.leadingBg,
    required this.leadingFg,
    required this.title,
    required this.sub,
    required this.action,
    required this.onAction,
  });
  final IconData leadingIcon;
  final Color leadingBg;
  final Color leadingFg;
  final String title;
  final String sub;
  final String action;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onAction,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: leadingBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child:
                    Icon(leadingIcon, size: 19.sp, color: leadingFg),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  action,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── mode card ───────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.sub,
    required this.foot,
    this.footHighlight = false,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String sub;
  final String foot;
  final bool footHighlight;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: selected ? AppColors.ink : AppColors.line,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: .12)
                      : AppColors.cream,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 19.sp,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.ink,
                  letterSpacing: -.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                sub,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: selected
                      ? Colors.white.withValues(alpha: .7)
                      : AppColors.muted,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: footHighlight
                      ? AppColors.success.withValues(alpha: .15)
                      : (selected
                          ? Colors.white.withValues(alpha: .12)
                          : AppColors.cream),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  foot,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: footHighlight
                        ? AppColors.success
                        : (selected ? Colors.white : AppColors.ink),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── bill card ───────────────────────────

class _BillCard extends StatelessWidget {
  const _BillCard({
    required this.subtotal,
    required this.delivery,
    required this.taxes,
    required this.discount,
    required this.couponLabel,
    required this.total,
  });
  final int subtotal;
  final int delivery;
  final int taxes;
  final int discount;
  final String? couponLabel;
  final int total;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _row('Item total', '₹$subtotal'),
          SizedBox(height: 8.h),
          _row(
            'Delivery',
            delivery == 0 ? 'FREE' : '₹$delivery',
            positive: delivery == 0,
          ),
          SizedBox(height: 8.h),
          _row('Taxes & charges', '₹$taxes'),
          if (discount > 0) ...[
            SizedBox(height: 8.h),
            _row(
              'Coupon $couponLabel',
              '− ₹$discount',
              positive: true,
            ),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To pay',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '₹$total',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool positive = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              color: AppColors.inkSoft,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: positive ? AppColors.success : AppColors.ink,
            ),
          ),
        ],
      );
}

// ─────────────────────── protection ribbon ──────────────────────

class _ProtectionRibbon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded,
              color: AppColors.secondary, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  color: AppColors.secondary,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                    text: 'Padosi Protection. ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        "Full refund if it doesn't arrive or isn't right.",
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

// ─────────────────────── sticky pay bar ────────────────────────

class _PayBar extends StatelessWidget {
  const _PayBar({required this.total, required this.onTap});
  final int total;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
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
          padding: EdgeInsets.all(8.w),
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: onTap,
              child: Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded,
                        color: Colors.white, size: 17.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Pay securely',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹$total',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 17.sp),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
