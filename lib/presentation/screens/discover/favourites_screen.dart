import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../auth/_auth_widgets.dart';
import '../padosi/mock/mock_data.dart';
import '_discover_widgets.dart';

/// Mockup 36 — Your wishlist (favourite kitchens).
///
/// Uses the same `CookRowCard` the Discover / Search / Specialty lists
/// use — single source of truth for "a kitchen card". Premium hero
/// header + soft empty state to match the rest of the app.
class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});
  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  /// Demo seed — first 3 cooks as wishlisted.
  late final List<Cook> _wishlist =
      MockData.cooks.take(3).toList(growable: true);

  void _remove(Cook c) {
    setState(() => _wishlist.removeWhere((x) => x.id == c.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${c.name} from your wishlist'),
        backgroundColor: AppColors.ink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Hero header ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 20.w, 14.h),
              child: Row(
                children: [
                  const AuthBackButton(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your wishlist',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.5,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _wishlist.isEmpty
                              ? 'Saved kitchens will appear here'
                              : '${_wishlist.length} home '
                                  "${_wishlist.length == 1 ? 'kitchen' : 'kitchens'} you love",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── List / empty ──
            Expanded(
              child: _wishlist.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      itemCount: _wishlist.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (_, i) {
                        final c = _wishlist[i];
                        return CookRowCard(
                          cook: c,
                          isNew: c.isNew,
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteNames.cookDetail,
                            arguments: c,
                          ),
                          trailing: Material(
                            color: AppColors.primarySoft,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _remove(c),
                              child: SizedBox(
                                width: 34.w,
                                height: 34.w,
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.primary,
                                  size: 16.sp,
                                ),
                              ),
                            ),
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
              width: 84.w,
              height: 84.w,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.favorite_rounded,
                color: AppColors.primary,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Nothing saved yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Tap the ❤ on any kitchen and it\nshows up right here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(99.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(99.r),
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteNames.discover,
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Text(
                    'Browse kitchens',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
