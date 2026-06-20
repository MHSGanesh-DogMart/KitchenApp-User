import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../auth/_auth_widgets.dart';
import '../discover/_discover_widgets.dart';

/// Mockup 26 — Report a problem.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, this.orderId = '#PD4821'});
  final String orderId;
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _reason = "Didn't arrive";
  final _desc = TextEditingController();

  static const _reasons = [
    "Didn't arrive",
    'Wrong / missing',
    'Quality / safety',
    'Arrived late',
  ];

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

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
                const PlainAppBar(title: 'Report'),
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 120.h),
                    children: [
                      Text(
                        '${widget.orderId} · refunds are handled by Padosi.',
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          color: AppColors.inkSoft,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      CardGroup(
                        children: _reasons
                            .map((r) => RadioListRow(
                                  title: r,
                                  selected: _reason == r,
                                  onTap: () => setState(() => _reason = r),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Describe',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        child: TextField(
                          controller: _desc,
                          maxLines: 3,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: AppColors.ink,
                          ),
                          decoration: InputDecoration(
                            hintText: 'A few details help us refund faster…',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: AppColors.muted,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
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
                                Icon(Icons.camera_alt_rounded,
                                    color: AppColors.inkSoft, size: 18.sp),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'Add a photo',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5.sp,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Upload',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyBar(
              child: AuthButton(
                label: 'Request refund',
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
