import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../discover/_discover_widgets.dart';
import '../padosi/mock/mock_data.dart';

/// Mockup 41 — Community feed (tab landing).
///
/// Premium polish:
///   · Hero header with title + subtitle.
///   · 42×42 cream icon buttons (search + notifications).
///   · Pill filter chip rail.
///   · Cook posts: 20r card · 56×56 photo · ink name + meta · 16:9
///     food image with rating chip overlay · ❤ / 💬 / Order pill.
///   · Review posts: 20r card · star ribbon · review body.
///   · Floating tangerine pencil FAB to compose.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _f = 0;
  static const _filters = ['For you', 'New cooks', 'Regional', 'Reviews'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pushNamed(context, RouteNames.createPost),
            child: SizedBox(
              width: 56.w,
              height: 56.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(decoration: BoxDecoration(shape: BoxShape.circle)),
                  Icon(Icons.edit_rounded, color: Colors.white, size: 22.sp),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Hero header ──
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community',
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
                          'Stories from your neighbourhood cooks',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Filter chips ──
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (_, i) => FilterChip2(
                  label: _filters[i],
                  selected: _f == i,
                  onTap: () => setState(() => _f = i),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ── Feed ──
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 130.h),
                itemCount: 4,
                separatorBuilder: (_, _) => SizedBox(height: 14.h),
                itemBuilder: (_, i) {
                  switch (i) {
                    case 0:
                      return _NewCookPost(
                        cook: MockData.cooks[3],
                        body:
                            'Pure Jain food, no onion-garlic. Lunch orders in '
                            'Block 5 starting Monday 🙏',
                        likes: 64,
                        comments: 9,
                        timeAgo: '2h',
                        onTap: () =>
                            Navigator.pushNamed(context, RouteNames.postDetail),
                      );
                    case 1:
                      return _ReviewPost(
                        reviewer: 'Priya M.',
                        cookName: 'Lakshmi Amma',
                        body:
                            "The real Andhra meals I'd been missing in Bangalore. "
                            "Hot, fresh, and just like home. 😍",
                        rating: 5.0,
                        timeAgo: '4h',
                        onTap: () =>
                            Navigator.pushNamed(context, RouteNames.postDetail),
                      );
                    case 2:
                      return _NewCookPost(
                        cook: MockData.cooks[1],
                        body:
                            'Diabetic-friendly bowls — quinoa, millet, lots of '
                            'fresh veggies. Now taking lunch orders.',
                        likes: 32,
                        comments: 4,
                        timeAgo: '8h',
                        onTap: () =>
                            Navigator.pushNamed(context, RouteNames.postDetail),
                      );
                    default:
                      return _ReviewPost(
                        reviewer: 'Ravi K.',
                        cookName: 'Sunita Aunty',
                        body:
                            'Tried the rajma chawal yesterday — exactly the '
                            'comfort food my mom used to make.',
                        rating: 4.8,
                        timeAgo: '1d',
                        onTap: () =>
                            Navigator.pushNamed(context, RouteNames.postDetail),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────── Helpers ──────────

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
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

class _NewCookPost extends StatelessWidget {
  const _NewCookPost({
    required this.cook,
    required this.body,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.onTap,
  });
  final Cook cook;
  final String body;
  final int likes;
  final int comments;
  final String timeAgo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = cook.name
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join();
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cook.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -.2,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${cook.isNew ? 'New cook' : 'Tier 1 · Home Kitchen'} · $timeAgo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (cook.isNew)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                      child: Text(
                        'NEW',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: .6,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.more_horiz_rounded,
                      color: AppColors.muted,
                      size: 20.sp,
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              // Photo with rating chip overlay
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: cook.image,
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
                              size: 36.sp,
                            ),
                          ),
                        ),
                      ),
                      // Rating chip — bottom-left
                      Positioned(
                        left: 10.w,
                        bottom: 10.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .55),
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: const Color(0xFFFFB400),
                                size: 13.sp,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                cook.rating.toStringAsFixed(1),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              Text(
                body,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: AppColors.ink,
                  height: 1.55,
                ),
              ),

              SizedBox(height: 12.h),

              // Reactions row
              Row(
                children: [
                  _ReactionPill(
                    icon: Icons.favorite_border_rounded,
                    count: likes,
                  ),
                  SizedBox(width: 8.w),
                  _ReactionPill(
                    icon: Icons.mode_comment_outlined,
                    count: comments,
                  ),
                  const Spacer(),
                  Material(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(99.r),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(99.r),
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 7.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Order',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.primary,
                              size: 14.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewPost extends StatelessWidget {
  const _ReviewPost({
    required this.reviewer,
    required this.cookName,
    required this.body,
    required this.rating,
    required this.timeAgo,
    required this.onTap,
  });
  final String reviewer;
  final String cookName;
  final String body;
  final double rating;
  final String timeAgo;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final initials = reviewer
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join();
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      color: AppColors.tier1,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 12.5.sp,
                              color: AppColors.ink,
                            ),
                            children: [
                              TextSpan(
                                text: reviewer,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              TextSpan(
                                text: '  ·  $timeAgo',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'reviewed $cookName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rating capsule
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFFB400),
                          size: 13.sp,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28.sp,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        body,
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.ink,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionPill extends StatelessWidget {
  const _ReactionPill({required this.icon, required this.count});
  final IconData icon;
  final int count;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: AppColors.ink),
          SizedBox(width: 5.w),
          Text(
            '$count',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.5.sp,
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
