import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';

/// Mockup 27 — Refund status (premium redesign).
///
/// Same header DNA as every other polished screen — single
/// `IconButton` back arrow + headline + subtitle.
///
///   1. Status hero — success-green check tile + "Refunded" + arrival
///      ETA pill.
///   2. Refund amount card with order ID + payment method.
///   3. "TIMELINE" kicker + 3-step rail (Approved → Processed →
///      Reaching account).
///   4. "Need help?" RowCard.
///   5. Sticky "Back to orders" ghost CTA + tangerine "Done".
class RefundStatusScreen extends StatelessWidget {
  const RefundStatusScreen({
    super.key,
    this.amount = 120,
    this.orderId = '#PD4790',
    this.method = 'UPI · PhonePe',
  });
  final int amount;
  final String orderId;
  final String method;

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
                _Header(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 130.h),
                    children: [
                      // ── Status hero ──
                      _StatusHero(eta: '1-3 working days'),

                      SizedBox(height: 16.h),

                      // ── Amount card ──
                      _AmountCard(
                        amount: amount,
                        orderId: orderId,
                        method: method,
                      ),

                      SizedBox(height: 18.h),

                      _Kicker('REFUND TIMELINE'),
                      SizedBox(height: 10.h),

                      // ── Timeline card ──
                      Container(
                        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          children: [
                            const _Step(
                              done: true,
                              title: 'Refund approved',
                              time: '8 May, 2:10 PM',
                            ),
                            const _Step(
                              done: true,
                              title: 'Processed to PhonePe',
                              time: '8 May, 2:12 PM',
                            ),
                            const _Step(
                              active: true,
                              title: 'Reaching your account',
                              time: '1-3 working days',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 18.h),

                      // ── Help row card ──
                      _HelpRow(
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouteNames.help,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky footer ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FooterBar(
              onBackToOrders: () =>
                  Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.orders,
                (_) => false,
              ),
              onDone: () => Navigator.maybePop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── header (same in all app) ─────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 20.w, 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.ink,
            iconSize: 22.sp,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refund status',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.5,
                    color: AppColors.ink,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tracked end-to-end',
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

// ─────────────────────── kicker ───────────────────────

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─────────────────────── status hero ───────────────────

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.eta});
  final String eta;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refund approved',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Your money is on the way back',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(99.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 13.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 3.w),
                Text(
                  eta,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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

// ─────────────────────── amount card ───────────────────

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.amount,
    required this.orderId,
    required this.method,
  });
  final int amount;
  final String orderId;
  final String method;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REFUND AMOUNT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '+ ₹$amount',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: AppColors.line),
          SizedBox(height: 14.h),
          Row(
            children: [
              _Cell(label: 'Order', value: orderId),
              Container(
                width: 1,
                height: 30.h,
                color: AppColors.line,
              ),
              _Cell(label: 'Paid via', value: method),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: AppColors.muted,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── timeline step ──────────────────

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
        ? AppColors.success
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
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: done || active ? dotColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                alignment: Alignment.center,
                child: done
                    ? Icon(Icons.check_rounded,
                        color: Colors.white, size: 13.sp)
                    : active
                        ? Container(
                            width: 7.w,
                            height: 7.w,
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
                  height: 38.h,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: done
                      ? AppColors.success.withValues(alpha: .6)
                      : AppColors.line,
                ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 18.h : 22.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? AppColors.primary
                          : done
                              ? AppColors.ink
                              : AppColors.muted,
                      letterSpacing: -.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
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

// ─────────────────────── help row ───────────────────────

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund taking longer than expected?',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Tap to chat with support',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── footer ───────────────────────

class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.onBackToOrders,
    required this.onDone,
  });
  final VoidCallback onBackToOrders;
  final VoidCallback onDone;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: onBackToOrders,
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Text(
                      'Back to orders',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: onDone,
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Text(
                      'Done',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
