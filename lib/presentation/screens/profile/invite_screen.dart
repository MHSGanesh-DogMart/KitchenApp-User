import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '../discover/_discover_widgets.dart';

/// Mockup 37 — Invite & earn.
class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  static const _code = 'PRIYA100';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PlainAppBar(title: 'Invite & earn'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                children: [
                  // Hero card (gradient)
                  Container(
                    padding: EdgeInsets.all(22.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF6A45), Color(0xFFE0431F)],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .35),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          alignment: Alignment.center,
                          child: Text('🎁',
                              style: TextStyle(fontSize: 30.sp)),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Give ₹100,\nget ₹100',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.6,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Friends get ₹100 off their first order. You '
                          'get ₹100 when they order.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: .85),
                            fontSize: 12.sp,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Your code',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: AppColors.line,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            _code,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: 2.2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        width: 100.w,
                        child: AuthButton(
                          label: 'Share',
                          variant: AuthBtnVariant.ink,
                          icon: Icons.ios_share_rounded,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  // Stats card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.line),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(big: '0', sub: 'Invited'),
                        _vDiv(),
                        _Stat(
                          big: '₹0',
                          sub: 'Earned',
                          color: AppColors.success,
                        ),
                        _vDiv(),
                        _Stat(big: '₹0', sub: 'Pending'),
                      ],
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

  Widget _vDiv() => Container(width: 1, height: 28, color: AppColors.line);
}

class _Stat extends StatelessWidget {
  const _Stat({required this.big, required this.sub, this.color});
  final String big;
  final String sub;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          big,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.ink,
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
    );
  }
}
