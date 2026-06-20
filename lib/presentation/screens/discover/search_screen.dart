import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../auth/_auth_widgets.dart';
import '../padosi/mock/mock_data.dart';
import '_discover_widgets.dart';

/// Mockup 10 — Search (active).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController(text: 'biryani');
  final _focus = FocusNode();

  static const _recent = ['Jain food', 'Pickles', 'Postpartum', 'Ragi'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _ctrl.text.trim();
    final results = q.isEmpty
        ? <Cook>[]
        : MockData.cooks
            .where((c) =>
                c.name.toLowerCase().contains(q.toLowerCase()) ||
                c.cuisine.toLowerCase().contains(q.toLowerCase()) ||
                q.toLowerCase().contains('biryani') ||
                q.toLowerCase().contains('thali'))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
              child: Row(
                children: [
                  const AuthBackButton(),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(13.r),
                        border: Border.all(color: AppColors.line),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded,
                              size: 18.sp, color: AppColors.muted),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              focusNode: _focus,
                              onChanged: (_) => setState(() {}),
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: AppColors.ink,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search dish, cook or cuisine',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  color: AppColors.muted,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12.h),
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_ctrl.text.isNotEmpty)
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(Icons.close_rounded,
                                  size: 18.sp, color: AppColors.muted),
                              onPressed: () {
                                _ctrl.clear();
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                children: [
                  if (results.isNotEmpty) ...[
                    _Kicker('Cooks'),
                    SizedBox(height: 10.h),
                    ...results.map((c) => Padding(
                          padding: EdgeInsets.only(bottom: 9.h),
                          child: CookRowCard(
                            cook: c,
                            priceTagline:
                                '${c.cuisine} · ₹${100 + (c.id.hashCode % 100)} · ${c.distanceKm.toStringAsFixed(1)} km',
                            onTap: () => Navigator.pushNamed(
                              context, RouteNames.cookDetail,
                              arguments: c,
                            ),
                          ),
                        )),
                    SizedBox(height: 16.h),
                  ],
                  _Kicker('Recent'),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _recent
                        .map((r) => GestureDetector(
                              onTap: () => setState(() => _ctrl.text = r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(99.r),
                                  border:
                                      Border.all(color: AppColors.line),
                                ),
                                child: Text(
                                  r,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.inkSoft,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
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
