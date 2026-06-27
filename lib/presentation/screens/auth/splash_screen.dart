import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routing/route_names.dart';
import '_auth_widgets.dart';

/// Mockup 01 — Splash hero.
/// Tangerine→ink gradient with white bread tile, big title, single
/// "Order home food" CTA. Cook-side onboarding lives in the separate
/// Padosi Partner app.
class AuthSplashScreen extends StatelessWidget {
  const AuthSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0, 0.9),
              colors: [Color(0xFFFF6A45), Color(0xFFE0431F), Color(0xFF16150F)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 26.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // Logo tile
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .15),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text('🍱', style: TextStyle(fontSize: 28.sp)),
                  ),
                  SizedBox(height: 22.h),
                  Text(
                    'Home food,\ndone right.',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 44.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2,
                      height: .98,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: 280.w,
                    child: Text(
                      'Verified home chefs near you — Andhra meals, Jain food, diabetic tiffins & more.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        height: 1.55,
                        color: Colors.white.withValues(alpha: .82),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.h),
                  AuthButton(
                    label: 'Order home food',
                    variant: AuthBtnVariant.onDark,
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      RouteNames.login,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
