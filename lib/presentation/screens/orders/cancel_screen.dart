import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../discover/_discover_widgets.dart';

/// Mockup 28 — Cancel order.
class CancelScreen extends StatefulWidget {
  const CancelScreen({super.key});
  @override
  State<CancelScreen> createState() => _CancelScreenState();
}

class _CancelScreenState extends State<CancelScreen> {
  String _reason = 'Ordered by mistake';
  static const _reasons = [
    'Ordered by mistake',
    'Changed my mind',
    'Taking too long',
    'Other',
  ];

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
                const PlainAppBar(title: 'Cancel order'),
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 120.h),
                    children: [
                      Container(
                        padding: EdgeInsets.all(13.w),
                        decoration: BoxDecoration(
                          color: AppColors.violetSoft,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: AppColors.error, size: 18.sp),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'Sunita has started cooking. Cancelling now means a '
                                'partial refund (₹90 of ₹120).',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.error,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Why cancelling?',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      CardGroup(
                        children: _reasons
                            .map((r) => RadioListRow(
                                  title: r,
                                  selected: _reason == r,
                                  onTap: () => setState(() => _reason = r),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyBar(
              child: _DangerButton(
                label: 'Cancel & refund ₹90',
                onPressed: () => Navigator.pushReplacementNamed(
                    context, RouteNames.refundStatus),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onPressed,
        child: Container(
          height: 52.h,
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
