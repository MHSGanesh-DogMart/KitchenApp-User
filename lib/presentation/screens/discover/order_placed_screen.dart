import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../models/order.dart';
import '../auth/_auth_widgets.dart';

/// Mockup 20 — Order placed (server-backed) with a premium success animation:
/// elastic check pop + radiating rings + staggered fade/slide-up content.
class OrderPlacedScreen extends StatefulWidget {
  const OrderPlacedScreen({super.key, this.order, this.total = 0});
  final Order? order;
  final int total;

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen>
    with TickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _c.forward();
    // Premium feel — a little haptic when the tick lands.
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String get _shortId {
    final id = widget.order?.id ?? '';
    return id.isEmpty ? '—' : '#${id.substring(0, 8).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final isPickup = o?.isPickup ?? false;
    final grand = o?.grandTotal.round() ?? widget.total;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
          child: Column(
            children: [
              const Spacer(),

              // ── Animated success tile with radiating rings ──
              SizedBox(
                width: 200.w,
                height: 200.w,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _ring(160.w, 0.05),
                        _ring(130.w, 0.0),
                        _ring(104.w, -0.05),
                        Transform.scale(
                          scale: Curves.elasticOut.transform(_c.value.clamp(0.0, 1.0)),
                          child: child,
                        ),
                      ],
                    );
                  },
                  child: Container(
                    width: 92.w,
                    height: 92.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.secondary, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .35),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 50.sp),
                  ),
                ),
              ),

              SizedBox(height: 6.h),
              _Stagger(
                controller: _c,
                start: 0.35,
                child: Text(
                  'Order placed!',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.4,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              _Stagger(
                controller: _c,
                start: 0.42,
                child: SizedBox(
                  width: 280.w,
                  child: Text(
                    '${o?.kitchenName ?? 'The kitchen'} has your order. '
                    '${isPickup ? 'Pick it up using the code below.' : "We'll send a rider the moment it's ready."}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.inkSoft, height: 1.55),
                  ),
                ),
              ),
              SizedBox(height: 22.h),

              if (o?.handoffCode?.isNotEmpty ?? false)
                _Stagger(
                  controller: _c,
                  start: 0.55,
                  child: _CodeCard(code: o!.handoffCode!, isPickup: isPickup),
                ),
              SizedBox(height: 12.h),

              _Stagger(
                controller: _c,
                start: 0.66,
                child: _SummaryCard(orderId: _shortId, isPickup: isPickup, items: o?.itemCount, grand: grand),
              ),

              const Spacer(),
              _Stagger(
                controller: _c,
                start: 0.8,
                child: Column(
                  children: [
                    if (!isPickup) ...[
                      AuthButton(
                        label: 'Track order',
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          RouteNames.orderTracking,
                          arguments: {'orderId': o?.id},
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
                    AuthButton(
                      label: 'Back to home',
                      variant: isPickup ? AuthBtnVariant.primary : AuthBtnVariant.ghost,
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteNames.home,
                        (_) => false,
                      ),
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

  /// One expanding + fading ring behind the tick.
  Widget _ring(double size, double delay) {
    final t = ((_c.value - 0.1 - delay) / 0.6).clamp(0.0, 1.0);
    return Opacity(
      opacity: (1 - t) * 0.5,
      child: Container(
        width: size * (0.6 + 0.4 * t),
        height: size * (0.6 + 0.4 * t),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
    );
  }
}

/// Fade + slide-up wrapper driven by an interval of the shared controller.
class _Stagger extends StatelessWidget {
  const _Stagger({required this.controller, required this.start, required this.child});
  final AnimationController controller;
  final double start;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, (start + 0.3).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, c) => Opacity(
        opacity: anim.value,
        child: Transform.translate(offset: Offset(0, 18 * (1 - anim.value)), child: c),
      ),
      child: child,
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({required this.code, required this.isPickup});
  final String code;
  final bool isPickup;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Text(
            isPickup ? 'PICKUP CODE' : 'DELIVERY OTP',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            code,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 40.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
              color: AppColors.ink,
              height: 1,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            isPickup ? 'Show this at the kitchen counter' : 'Share with the rider on delivery',
            style: GoogleFonts.inter(fontSize: 11.5.sp, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.orderId, required this.isPickup, required this.items, required this.grand});
  final String orderId;
  final bool isPickup;
  final int? items;
  final int grand;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _row('Order', orderId),
          SizedBox(height: 8.h),
          _row('Type', isPickup ? 'Pickup' : 'Delivery'),
          if (items != null) ...[
            SizedBox(height: 8.h),
            _row('Items', '$items'),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paid',
                style: GoogleFonts.spaceGrotesk(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
              Text(
                '₹$grand',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.muted)),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
        ],
      );
}
