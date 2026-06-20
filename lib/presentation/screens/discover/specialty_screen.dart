import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../padosi/mock/mock_data.dart';
import '_discover_widgets.dart';

/// Mockup 12 — Specialty (Jain) — same component, accepts [category].
class SpecialtyScreen extends StatefulWidget {
  const SpecialtyScreen({super.key, this.category = 'Jain food'});
  final String category;
  @override
  State<SpecialtyScreen> createState() => _SpecialtyScreenState();
}

class _SpecialtyScreenState extends State<SpecialtyScreen> {
  int _f = 0;
  static const _filters = ['All', 'No onion-garlic', '★ 4.5+'];

  @override
  Widget build(BuildContext context) {
    // For demo: show all cooks (real impl would filter by category)
    final list = MockData.cooks;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PlainAppBar(title: widget.category),
            // Filter chips
            SizedBox(
              height: 38.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filters.length,
                itemBuilder: (_, i) {
                  final item = FilterChip2(
                    label: _filters[i],
                    selected: _f == i,
                    onTap: () => setState(() => _f = i),
                  );
                  if (i == _filters.length - 1) return item;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: item,
                  );
                },
              ),
            ),
            // Cook list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 110.h),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  final item = CookRowCard(
                    cook: c,
                    isNew: c.isNew,
                    onTap: () => Navigator.pushNamed(
                      context,
                      RouteNames.cookDetail,
                      arguments: c,
                    ),
                  );
                  if (i == list.length - 1) return item;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 9.h),
                    child: item,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
