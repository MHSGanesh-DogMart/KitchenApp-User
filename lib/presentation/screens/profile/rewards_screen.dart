import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Rewards screen — points balance, tier ladder, and "earn more" ideas.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
                  // ── Hero balance card ──
                  const _BalanceCard(points: 1240, nextTier: 'Gold'),

                  SizedBox(height: 18.h),

                  _Kicker('YOUR TIER'),
                  SizedBox(height: 10.h),
                  // ── Tier ladder ──
                  const _TierRow(
                    label: 'Silver',
                    sub: 'Free delivery on every order',
                    icon: '🥈',
                    achieved: true,
                  ),
                  SizedBox(height: 10.h),
                  const _TierRow(
                    label: 'Gold',
                    sub: 'Priority kitchens + 5% wallet cashback',
                    icon: '🥇',
                    progress: .62,
                    pointsToGo: 760,
                  ),
                  SizedBox(height: 10.h),
                  const _TierRow(
                    label: 'Platinum',
                    sub: 'Padosi Concierge + early access',
                    icon: '💎',
                  ),

                  SizedBox(height: 22.h),

                  _Kicker('EARN MORE POINTS'),
                  SizedBox(height: 10.h),
                  const _EarnRow(
                    icon: Icons.local_dining_rounded,
                    title: 'Order a meal',
                    points: '+10 pts',
                    tint: AppColors.primary,
                  ),
                  SizedBox(height: 10.h),
                  const _EarnRow(
                    icon: Icons.rate_review_rounded,
                    title: 'Rate your cook',
                    points: '+20 pts',
                    tint: AppColors.secondary,
                  ),
                  SizedBox(height: 10.h),
                  const _EarnRow(
                    icon: Icons.share_rounded,
                    title: 'Invite a neighbour',
                    points: '+50 pts',
                    tint: AppColors.success,
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
                  'Rewards',
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
                  'Eat. Earn. Repeat.',
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

// ─────────────────────── balance hero ──────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.points, required this.nextTier});
  final int points;
  final String nextTier;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: .22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your points',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: .65),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .25),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  '🔥 7-day streak',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$points',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -1.4,
                  height: 1,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'pts',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: .55),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            '760 pts to $nextTier tier',
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              color: Colors.white.withValues(alpha: .75),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: LinearProgressIndicator(
              value: .62,
              minHeight: 7.h,
              backgroundColor: Colors.white.withValues(alpha: .12),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── tier row ───────────────────────

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.label,
    required this.sub,
    required this.icon,
    this.achieved = false,
    this.progress,
    this.pointsToGo,
  });
  final String label;
  final String sub;
  final String icon;
  final bool achieved;
  final double? progress;
  final int? pointsToGo;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: progress != null ? AppColors.primary : AppColors.line,
          width: progress != null ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(13.r),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: TextStyle(fontSize: 22.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -.2,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    if (achieved)
                      Icon(Icons.check_circle_rounded,
                          size: 14.sp, color: AppColors.success),
                    if (progress != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(99.r),
                        ),
                        child: Text(
                          'Current',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  sub,
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
                if (progress != null) ...[
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99.r),
                    child: LinearProgressIndicator(
                      value: progress!,
                      minHeight: 5.h,
                      backgroundColor: AppColors.line,
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary),
                    ),
                  ),
                  if (pointsToGo != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      '$pointsToGo pts to unlock',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── earn row ───────────────────────

class _EarnRow extends StatelessWidget {
  const _EarnRow({
    required this.icon,
    required this.title,
    required this.points,
    required this.tint,
  });
  final IconData icon;
  final String title;
  final String points;
  final Color tint;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.line),
          ),
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: tint, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.2,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  points,
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
