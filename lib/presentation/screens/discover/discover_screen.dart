import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../padosi/mock/mock_data.dart';
import '_discover_widgets.dart';
import 'filters_sheet.dart';

/// Discover tab — browsable list of nearby home kitchens.
///
/// Premium polish:
///   · Title + count subtitle ("23 kitchens near you").
///   · Two 42×42 icon buttons (search + filter) with cream surfaces.
///   · Quick filter chip rail under the header.
///   · CookRowCard list with generous 14h spacing.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _f = 0;

  List<FoodCategory> get _cats => MockData.specialties;
  List<Cook> get _visible => MockData.cooks; // (real filter wires up later)

  @override
  Widget build(BuildContext context) {
    final list = _visible;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Hero header ──
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kitchens',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.6,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${MockData.cooks.length} home chefs near you',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _IconBtn(
                    icon: Icons.search_rounded,
                    onTap: () => Navigator.pushNamed(
                      context,
                      RouteNames.discoverSearch,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _IconBtn(
                    icon: Icons.tune_rounded,
                    onTap: () => showFiltersSheet(context),
                    showDot: true,
                  ),
                ],
              ),
            ),

            // ── Category pills (same recipe as Home) ──
            SizedBox(
              height: 50.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _cats.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (_, i) => _CategoryPill(
                  category: _cats[i],
                  selected: _f == i,
                  onTap: () => setState(() => _f = i),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ── List / empty ──
            Expanded(
              child: list.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 110.h),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                      itemBuilder: (_, i) {
                        final c = list[i];
                        return CookRowCard(
                          cook: c,
                          isNew: c.isNew,
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteNames.cookDetail,
                            arguments: c,
                          ),
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

/// 42×42 cream icon button with optional tangerine dot in the corner
/// (used on the filter icon to hint at active filters).
class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 19.sp, color: AppColors.ink),
              if (showDot)
                Positioned(
                  top: 9.h,
                  right: 9.w,
                  child: Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular food image + label stadium pill — same recipe as Home.
class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.category,
    required this.selected,
    required this.onTap,
  });
  final FoodCategory category;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99.r),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.line,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(99.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 4.h, 14.w, 4.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 38.w,
                  height: 38.w,
                  child: CachedNetworkImage(
                    imageUrl: category.image,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Shimmer.fromColors(
                      baseColor: AppColors.line,
                      highlightColor: Colors.white,
                      child: Container(color: AppColors.line),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: AppColors.cream,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.muted,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                category.label,
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft empty state — circular cream avatar + copy.
class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('🍽', style: TextStyle(fontSize: 32.sp)),
            ),
            SizedBox(height: 16.h),
            Text(
              'No kitchens match this filter',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -.3,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Try a different filter or tier to\nsee more home chefs nearby.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
