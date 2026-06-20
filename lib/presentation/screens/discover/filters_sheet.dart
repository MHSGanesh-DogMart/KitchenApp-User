import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '_discover_widgets.dart';

/// Mockup 11 — Filters bottom sheet.
///
/// Premium polish:
///   · Rounded 28r top corners, soft drop shadow.
///   · Pill grabber (44×4).
///   · Uppercase section kickers (matches checkout/cart).
///   · Pastel ink-and-cream filter chips (FilterChip2).
///   · RadioListRow grouped in a CardGroup.
///   · Sticky tangerine "Show X kitchens" CTA with cream divider.
Future<void> showFiltersSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FiltersSheet(),
  );
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet();
  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  String _tier = 'All';
  String _diet = 'Jain';
  String _sort = 'Nearest';

  // Approximate result count — moves slightly as filters change so
  // the CTA feels responsive.
  int get _count {
    var n = 24;
    if (_tier != 'All') n -= 6;
    if (_diet != 'Jain') n += 2;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * .82;
    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Grabber ──
            Padding(
              padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(99.r),
                ),
              ),
            ),

            // ── Header ──
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 12.w, 6.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filters',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -.5,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Refine to the kitchens you want',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _tier = 'All';
                      _diet = 'Jain';
                      _sort = 'Nearest';
                    }),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                    ),
                    child: Text(
                      'Clear all',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──
            Flexible(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                shrinkWrap: true,
                children: [
                  _Kicker('Trust tier'),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: ['All', '🏠 Home Chef', '✓ Licensed']
                        .map((t) => FilterChip2(
                              label: t,
                              selected: _tier == t,
                              onTap: () => setState(() => _tier = t),
                            ))
                        .toList(),
                  ),

                  SizedBox(height: 20.h),
                  _Kicker('Diet'),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: ['Veg', 'Jain', 'Diabetic', 'Eggless']
                        .map((d) => FilterChip2(
                              label: d,
                              selected: _diet == d,
                              onTap: () => setState(() => _diet = d),
                            ))
                        .toList(),
                  ),

                  SizedBox(height: 20.h),
                  _Kicker('Sort by'),
                  SizedBox(height: 10.h),
                  CardGroup(
                    children: const ['Nearest', 'Top rated', 'Fastest']
                        .map((s) => RadioListRow(
                              title: s,
                              selected: _sort == s,
                              onTap: () => setState(() => _sort = s),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // ── Sticky CTA bar ──
            Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.line, width: 1),
                ),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 52.h,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Show $_count kitchens',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uppercase section kicker (matches checkout / cart screens).
class _Kicker extends StatelessWidget {
  const _Kicker(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
