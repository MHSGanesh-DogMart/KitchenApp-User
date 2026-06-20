import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';

/// Your Refunds — list of past refunds with status pills.
class RefundsScreen extends StatelessWidget {
  const RefundsScreen({super.key});

  static const _items = <_Refund>[
    _Refund(
      orderId: '#PD4790',
      cookName: 'Sunita Aunty',
      reason: 'Order cancelled — kitchen unavailable',
      amount: 240,
      status: _Status.completed,
      date: '3 Jun 2026',
    ),
    _Refund(
      orderId: '#PD4742',
      cookName: 'Lakshmi Amma',
      reason: 'Wrong item delivered',
      amount: 120,
      status: _Status.processing,
      date: '28 May 2026',
    ),
    _Refund(
      orderId: '#PD4701',
      cookName: 'Jain Rasoi',
      reason: 'Late delivery — refund requested',
      amount: 90,
      status: _Status.declined,
      date: '14 Apr 2026',
    ),
  ];

  int get _totalRefunded =>
      _items.where((r) => r.status == _Status.completed).fold(0, (a, b) => a + b.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                children: [
                  // ── Summary hero ──
                  _SummaryHero(amount: _totalRefunded, count: _items.length),
                  SizedBox(height: 18.h),
                  _Kicker('YOUR REFUNDS'),
                  SizedBox(height: 10.h),
                  for (var i = 0; i < _items.length; i++) ...[
                    _RefundCard(refund: _items[i]),
                    if (i < _items.length - 1) SizedBox(height: 10.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Status { completed, processing, declined }

class _Refund {
  const _Refund({
    required this.orderId,
    required this.cookName,
    required this.reason,
    required this.amount,
    required this.status,
    required this.date,
  });
  final String orderId;
  final String cookName;
  final String reason;
  final int amount;
  final _Status status;
  final String date;
}

// ─────────────────────── header ───────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 20.w, 10.h),
      child: Row(
        children: [
          const AuthBackButton(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your refunds',
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

// ─────────────────────── summary hero ───────────────────

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({required this.amount, required this.count});
  final int amount;
  final int count;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.success,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refunded this year',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹$amount',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        letterSpacing: -.5,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '· $count refund${count == 1 ? '' : 's'}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── refund card ─────────────────────

class _RefundCard extends StatelessWidget {
  const _RefundCard({required this.refund});
  final _Refund refund;

  ({IconData icon, String label, Color fg, Color bg}) _statusFor() {
    switch (refund.status) {
      case _Status.completed:
        return (
          icon: Icons.check_circle_rounded,
          label: 'Refunded',
          fg: AppColors.success,
          bg: AppColors.success.withValues(alpha: .12),
        );
      case _Status.processing:
        return (
          icon: Icons.schedule_rounded,
          label: 'Processing',
          fg: AppColors.primary,
          bg: AppColors.primarySoft,
        );
      case _Status.declined:
        return (
          icon: Icons.cancel_rounded,
          label: 'Declined',
          fg: AppColors.muted,
          bg: AppColors.cream,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _statusFor();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.line),
          ),
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 9.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: s.bg,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(s.icon, size: 13.sp, color: s.fg),
                        SizedBox(width: 4.w),
                        Text(
                          s.label,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: s.fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${refund.amount}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                refund.cookName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -.2,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                refund.reason,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.inkSoft,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '${refund.orderId} · ${refund.date}',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
