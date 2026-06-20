import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '_discover_widgets.dart';

/// Mockup 15 — Schedule / pre-order.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _when = 'Today, lunch';
  String _slot = '1:00';

  static const _slots = ['12:30', '1:00', '1:30', '2:00'];

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
                const PlainAppBar(title: 'When?'),
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 110.h),
                    children: [
                      Text(
                        'Sunita cooks fresh to order. Pick when you want it.',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.inkSoft,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      CardGroup(children: [
                        RadioListRow(
                          title: 'Today, lunch',
                          subtitle: 'Order by 11 AM · eat ~1 PM',
                          selected: _when == 'Today, lunch',
                          onTap: () =>
                              setState(() => _when = 'Today, lunch'),
                        ),
                        RadioListRow(
                          title: 'Today, dinner',
                          subtitle: 'Order by 5 PM · eat ~8 PM',
                          selected: _when == 'Today, dinner',
                          onTap: () =>
                              setState(() => _when = 'Today, dinner'),
                        ),
                        RadioListRow(
                          title: 'Tomorrow',
                          subtitle: 'Pick a slot',
                          selected: _when == 'Tomorrow',
                          onTap: () =>
                              setState(() => _when = 'Tomorrow'),
                        ),
                      ]),
                      SizedBox(height: 18.h),
                      Text(
                        'Lunch slots',
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
                        children: _slots
                            .map((s) => FilterChip2(
                                  label: s,
                                  selected: _slot == s,
                                  onTap: () => setState(() => _slot = s),
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
            left: 0, right: 0, bottom: 0,
            child: StickyBar(
              child: AuthButton(
                label: 'Confirm  ·  $_when, $_slot',
                onPressed: () => Navigator.pop(context, {
                  'when': _when,
                  'slot': _slot,
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
