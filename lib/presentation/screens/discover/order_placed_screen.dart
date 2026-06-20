import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../auth/_auth_widgets.dart';
import '../padosi/mock/mock_data.dart';

/// Mockup 20 — Order placed.
class OrderPlacedScreen extends StatelessWidget {
  const OrderPlacedScreen({super.key, required this.cook, required this.total});
  final Cook cook;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
          child: Column(
            children: [
              const Spacer(),
              // Tick tile
              Container(
                width: 92.w,
                height: 92.w,
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(28.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.secondary,
                  size: 50.sp,
                ),
              ),
              SizedBox(height: 22.h),
              Text(
                'Order placed!',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -.4,
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: 260.w,
                child: Text(
                  '${cook.name} is starting your order. We\'ll send a rider the moment it\'s ready.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: AppColors.inkSoft,
                    height: 1.55,
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              // Order summary chip
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Order ',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      '#PD4821',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '   ·   ',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      'ETA ',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      '12:00',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AuthButton(
                label: 'Track order',
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  RouteNames.orderTracking,
                  arguments: {'cook': cook, 'total': total},
                ),
              ),
              SizedBox(height: 10.h),
              AuthButton(
                label: 'Back to home',
                variant: AuthBtnVariant.ghost,
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.home,
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
