import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';

/// Mockup 30 — Notifications (grouped New / Earlier).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar with Clear
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
              child: Row(
                children: [
                  const AuthBackButton(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Clear',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 110.h),
                children: [
                  _Kicker('New'),
                  SizedBox(height: 10.h),
                  _NotifRow(
                    icon: Icons.check_rounded,
                    bg: AppColors.secondarySoft,
                    fg: AppColors.secondary,
                    title: 'Order delivered',
                    sub: 'Rate Sunita Aunty · 5m',
                    onTap: () {},
                  ),
                  SizedBox(height: 8.h),
                  _NotifRow(
                    icon: Icons.local_offer_rounded,
                    bg: AppColors.primarySoft,
                    fg: AppColors.primary,
                    title: '50% off — FRESH50',
                    sub: 'First order · 1h',
                    onTap: () {},
                  ),
                  SizedBox(height: 18.h),
                  _Kicker('Earlier'),
                  SizedBox(height: 10.h),
                  _NotifRow(
                    icon: Icons.cottage_rounded,
                    bg: const Color(0xFFEDE6FA),
                    fg: AppColors.tier1,
                    title: 'New cook nearby',
                    sub: 'Jain Rasoi is live · 2d',
                    onTap: () {},
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

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.3,
          color: AppColors.muted,
        ),
      );
}

class _NotifRow extends StatelessWidget {
  const _NotifRow({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.title,
    required this.sub,
    required this.onTap,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String sub;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: fg, size: 17.sp),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sub,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
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
}
