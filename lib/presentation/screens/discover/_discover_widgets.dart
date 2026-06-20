import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '../padosi/mock/mock_data.dart';

/// Slim cook row card used in Discover/Search/Specialty/Favourites lists.
class CookRowCard extends StatelessWidget {
  const CookRowCard({
    super.key,
    required this.cook,
    this.priceTagline,
    this.isNew = false,
    this.onTap,
    this.trailing,
  });

  final Cook cook;
  final String? priceTagline; // e.g. "Hyderabadi biryani · ₹130 · 0.4 km"
  final bool isNew;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cook photo (88×88, 16r) with "New" ribbon overlay
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      width: 88.w,
                      height: 88.w,
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
                            size: 28.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isNew)
                    Positioned(
                      top: 6.h,
                      left: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
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
                      ),
                    ),
                ],
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name + rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            cook.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.3,
                              color: AppColors.ink,
                              height: 1.15,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Rating pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
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
                                size: 12.sp,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                cook.rating.toStringAsFixed(1),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Cuisine / tagline — ellipsis if it overflows.
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        priceTagline ?? cook.cuisine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    // Meta chips — Wrap so they break cleanly on tight
                    // widths instead of overflowing the row.
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 5.h,
                      children: [
                        FlatChip(
                          label: cook.tier == 1
                              ? '✓ FSSAI Basic'
                              : '✓ FSSAI Licensed',
                          bg: AppColors.secondarySoft,
                          fg: AppColors.secondary,
                        ),
                        if (cook.shipping)
                          const FlatChip(
                            label: 'Ships 2 days',
                            bg: AppColors.primarySoft,
                            fg: AppColors.primaryDark,
                          )
                        else ...[
                          FlatChip(
                            label: '${cook.distanceKm.toStringAsFixed(1)} km',
                            bg: AppColors.cream,
                            fg: AppColors.inkSoft,
                          ),
                          // FlatChip(
                          //   label: '${cook.etaMin} min',
                          //   bg: AppColors.cream,
                          //   fg: AppColors.inkSoft,
                          // ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[SizedBox(width: 6.w), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class TierTag extends StatelessWidget {
  const TierTag({super.key, required this.tier});
  final int tier;
  @override
  Widget build(BuildContext context) {
    final t1 = tier == 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: t1 ? AppColors.tier1Soft : AppColors.tier2Soft,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        t1 ? '🏠 T1' : '✓ T2',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w700,
          color: t1 ? AppColors.tier1 : AppColors.tier2,
        ),
      ),
    );
  }
}

class FlatChip extends StatelessWidget {
  const FlatChip({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.border = false,
  });
  final String label;
  final Color bg;
  final Color fg;
  final bool border;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99.r),
        border: border ? Border.all(color: AppColors.line) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

/// Generic filter chip that can be selected/idle.
class FilterChip2 extends StatelessWidget {
  const FilterChip2({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99.r),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(99.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple app bar row (back + title + optional trailing).
class PlainAppBar extends StatelessWidget {
  const PlainAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.trailing,
    this.onBack,
  });
  final String title;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
      child: Row(
        children: [
          if (showBack) ...[
            AuthBackButton(onTap: onBack),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Radio row used in Filters/Schedule/Cancel/Payment lists.
class RadioListRow extends StatelessWidget {
  const RadioListRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.leading,
  });
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
        child: Row(
          children: [
            ?leading,
            if (leading != null) SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.line,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card-style group container used to wrap radio lists / menu rows.
class CardGroup extends StatelessWidget {
  const CardGroup({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i < children.length - 1) {
        out.add(
          Divider(
            height: 1,
            indent: 15.w,
            endIndent: 15.w,
            color: AppColors.line,
          ),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(children: out),
    );
  }
}

/// Two-up grid dish tile used inside CookDetail.
class DishTile extends StatelessWidget {
  const DishTile({
    super.key,
    required this.dish,
    required this.count,
    required this.onAdd,
  });
  final Dish dish;
  final int count;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.4,
              child: dish.image != null
                  ? CachedNetworkImage(
                      imageUrl: dish.image!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _gradientFallback(),
                    )
                  : _gradientFallback(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 9.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${dish.price}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.r),
                          onTap: onAdd,
                          child: SizedBox(
                            width: 28.w,
                            height: 28.w,
                            child: count == 0
                                ? const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : Center(
                                    child: Text(
                                      '$count',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientFallback() => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dish.heroGradient,
      ),
    ),
    child: Center(
      child: Text(dish.emoji, style: TextStyle(fontSize: 28.sp)),
    ),
  );
}

/// Sticky bottom bar used across order flow screens.
class StickyBar extends StatelessWidget {
  const StickyBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
          child: child,
        ),
      ),
    );
  }
}
