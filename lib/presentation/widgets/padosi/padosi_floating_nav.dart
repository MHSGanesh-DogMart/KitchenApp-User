import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Floating dark-pill bottom navigation per "Bold & Fresh" mockups.
/// - 58dp pill, 14dp side margin
/// - Background: ink (#16150F)
/// - Inactive labels: 50% white
/// - Active label: white; active icon: primary tangerine
/// Position this on top of screen content with [Stack] (don't use Scaffold's
/// bottomNavigationBar — it sits flush, mockup wants it floating).
class PadosiFloatingNav extends StatelessWidget {
  const PadosiFloatingNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const _items = <(IconData, IconData, String)>[
    (Icons.cottage_outlined, Icons.cottage_rounded, 'Home'),
    (Icons.travel_explore_outlined, Icons.travel_explore_rounded, 'Discover'),
    (Icons.forum_outlined, Icons.forum_rounded, 'Community'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Orders'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: .3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Row(
            children: List.generate(_items.length, (i) {
              final (iconOff, iconOn, label) = _items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: () => onSelect(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (c, a) =>
                              ScaleTransition(scale: a, child: c),
                          child: Icon(
                            selected ? iconOn : iconOff,
                            key: ValueKey('$i-$selected'),
                            color: selected
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: .5),
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          label,
                          style: GoogleFonts.spaceGrotesk(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: .5),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

