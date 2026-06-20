import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../discover/_discover_widgets.dart';
import '_profile_widgets.dart';

/// Mockup 40 — Help & support.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _topQs = [
    'How do refunds work?',
    'My order is late',
    'How is the cook verified?',
    'Change my address',
    'Why was my order cancelled?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PlainAppBar(title: 'Help'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                children: [
                  // Search
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(13.r),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            size: 18.sp, color: AppColors.muted),
                        SizedBox(width: 8.w),
                        Text(
                          'Search help',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const ProfileKicker('Top questions'),
                  CardGroup(
                    children: _topQs
                        .map((q) => MenuRow(title: q, onTap: () {}))
                        .toList(),
                  ),

                  SizedBox(height: 16.h),

                  // Chat with support card
                  Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: const BorderSide(color: AppColors.line),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14.r),
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.all(13.w),
                        child: Row(
                          children: [
                            Container(
                              width: 38.w,
                              height: 38.w,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: AppColors.primary,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chat with support',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Replies in minutes',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: AppColors.muted, size: 18.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Center(
                    child: Text(
                      'Or email us at hello@padosi.app',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
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
