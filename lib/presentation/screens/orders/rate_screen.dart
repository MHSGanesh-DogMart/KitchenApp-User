import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '../discover/_discover_widgets.dart';

/// Mockup 25 — Rate & review.
class RateScreen extends StatefulWidget {
  const RateScreen({
    super.key,
    this.cookName = 'Sunita Aunty',
    this.dish = 'Veg Thali',
    this.orderId = '#PD4821',
  });
  final String cookName;
  final String dish;
  final String orderId;

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int _stars = 4;
  final Set<String> _tags = {'Tasty', 'Homely'};
  final _review = TextEditingController();

  static const _chips = ['Tasty', 'On time', 'Well packed', 'Homely'];

  @override
  void dispose() {
    _review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.cookName
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const PlainAppBar(title: 'Rate order'),
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 120.h),
                    children: [
                      Center(
                        child: Column(
                          children: [
                            SizedBox(height: 8.h),
                            Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'How was ${widget.cookName}?',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                letterSpacing: -.3,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${widget.dish} · ${widget.orderId}',
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                color: AppColors.muted,
                              ),
                            ),
                            SizedBox(height: 18.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final filled = i < _stars;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _stars = i + 1),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 36.sp,
                                      color: filled
                                          ? const Color(0xFFF5A623)
                                          : AppColors.line,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'What was great?',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _chips
                            .map((c) => FilterChip2(
                                  label: c,
                                  selected: _tags.contains(c),
                                  onTap: () => setState(() {
                                    _tags.contains(c)
                                        ? _tags.remove(c)
                                        : _tags.add(c);
                                  }),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        'Review (optional)',
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
                          controller: _review,
                          maxLines: 4,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: AppColors.ink,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Loved the dal…',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: AppColors.muted,
                            ),
                            border: InputBorder.none,
                            isDense: true,
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
                label: 'Submit',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
