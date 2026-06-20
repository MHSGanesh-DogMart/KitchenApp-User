import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';

/// E-Gift Cards — buy/send gift cards for home food.
class GiftCardsScreen extends StatelessWidget {
  const GiftCardsScreen({super.key});

  static const _amounts = <int>[200, 500, 1000, 2000, 5000];

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
                  // ── Hero card preview ──
                  const _GiftHero(amount: 1000),

                  SizedBox(height: 22.h),

                  _Kicker('PICK AN AMOUNT'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.w,
                    children: _amounts
                        .map(
                          (a) => _AmountChip(amount: a, selected: a == 1000),
                        )
                        .toList(),
                  ),

                  SizedBox(height: 22.h),

                  _Kicker('SEND TO'),
                  SizedBox(height: 10.h),
                  _RecipientCard(),

                  SizedBox(height: 16.h),

                  _Kicker("PERSONAL MESSAGE (OPTIONAL)"),
                  SizedBox(height: 10.h),
                  _MessageCard(),

                  SizedBox(height: 24.h),

                  // ── CTA ──
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(99.r),
                      onTap: () {},
                      child: Container(
                        height: 54.h,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_giftcard_rounded,
                                color: Colors.white, size: 17.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Send gift card · ₹1000',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
    );
  }
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
                  'E-Gift Cards',
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
                  'Gift the taste of home',
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

// ─────────────────────── hero card ───────────────────────

class _GiftHero extends StatelessWidget {
  const _GiftHero({required this.amount});
  final int amount;
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF5630), Color(0xFFFF8A65)],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .35),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background ribbon
            Positioned(
              top: -40.h,
              right: -40.w,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .12),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.card_giftcard_rounded,
                        color: Colors.white, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Padosi Gift Card',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '₹$amount',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -1.4,
                    height: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'A taste of home, for someone you love',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: Colors.white.withValues(alpha: .85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── amount chip ────────────────────

class _AmountChip extends StatelessWidget {
  const _AmountChip({required this.amount, required this.selected});
  final int amount;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: selected ? AppColors.ink : AppColors.line,
        ),
      ),
      child: Text(
        '₹$amount',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}

// ─────────────────────── recipient + message ─────────────

class _RecipientCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
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
            child: Icon(Icons.person_rounded,
                color: AppColors.primary, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: "Friend's phone or email",
                hintStyle: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(99.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.contacts_rounded,
                    size: 13.sp, color: AppColors.ink),
                SizedBox(width: 4.w),
                Text(
                  'Pick',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
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

class _MessageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        minLines: 2,
        maxLines: 4,
        cursorColor: AppColors.primary,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          color: AppColors.ink,
          height: 1.55,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Happy birthday! Enjoy a meal on me 🎂',
          hintStyle: GoogleFonts.inter(
            fontSize: 13.sp,
            color: AppColors.muted,
            height: 1.55,
          ),
        ),
      ),
    );
  }
}
