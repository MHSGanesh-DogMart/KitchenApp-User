import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '_auth_widgets.dart';

/// Mockup 02 — Intro carousel (3 pages).
///
/// Original design preserved (pastel gradient tile + centered emoji).
/// Only the slide copy was refreshed.
class IntroCarouselScreen extends StatefulWidget {
  const IntroCarouselScreen({super.key});
  @override
  State<IntroCarouselScreen> createState() => _IntroCarouselScreenState();
}

class _IntroCarouselScreenState extends State<IntroCarouselScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _slides = <_Slide>[
    _Slide(
      emoji: '🏠',
      gradient: [Color(0xFFFFE3D2), Color(0xFFFFC4AC)],
      title: 'From neighbours,\nwith ghee on top.',
      body:
          'Real home chefs around you — FSSAI-verified, rated by the families they cook for.',
    ),
    _Slide(
      emoji: '🥗',
      gradient: [Color(0xFFE3F1E9), Color(0xFFBFE3CC)],
      title: 'Built for how\nyou actually eat.',
      body:
          'Jain, diabetic, postpartum, regional — filters that match the way you really eat at home.',
    ),
    _Slide(
      emoji: '🛡️',
      gradient: [Color(0xFFFBEAC6), Color(0xFFF2DCA6)],
      title: 'Sealed warm,\nrefunded sweet.',
      body:
          "Padosi Protection covers every prepaid order. Doesn't arrive or isn't right? Full refund.",
    ),
  ];

  void _next() {
    if (_page == _slides.length - 1) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    } else {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
          child: Column(
            children: [
              // Header: empty space + Skip
              Row(
                children: [
                  SizedBox(width: 38.w),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      RouteNames.login,
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                ),
              ),

              // Dots
              Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      height: 6.h,
                      width: active ? 22.w : 6.w,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.line,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  }),
                ),
              ),

              AuthButton(
                label: _page == _slides.length - 1 ? 'Get started' : 'Next',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.emoji,
    required this.gradient,
    required this.title,
    required this.body,
  });
  final String emoji;
  final List<Color> gradient;
  final String title;
  final String body;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 220.w,
          height: 220.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: slide.gradient,
            ),
            borderRadius: BorderRadius.circular(32.r),
            boxShadow: [
              BoxShadow(
                color: slide.gradient.last.withValues(alpha: .35),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(slide.emoji, style: TextStyle(fontSize: 90.sp)),
        ),
        SizedBox(height: 32.h),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -.8,
            height: 1.1,
            color: AppColors.ink,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: 260.w,
          child: Text(
            slide.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5.sp,
              color: AppColors.inkSoft,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}
