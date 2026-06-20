import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/padosi/dish_grid_card.dart';
import '../../widgets/padosi/global_cart_bar.dart';
import '../padosi/mock/mock_data.dart';
import '_discover_widgets.dart';

/// Mockup 13 — Cook detail.
class CookDetailScreen extends StatefulWidget {
  const CookDetailScreen({super.key, required this.cook});
  final Cook cook;
  @override
  State<CookDetailScreen> createState() => _CookDetailScreenState();
}

class _CookDetailScreenState extends State<CookDetailScreen> {
  List<Dish> get _menu =>
      widget.cook.menu.isNotEmpty ? widget.cook.menu : MockData.sunita.menu;

  /// Rotating pastel palette for menu cards — same vibe as the Home grid.
  static const _dishTints = <Color>[
    Color(0xFFFFE7D6), // peach
    Color(0xFFE3F1E9), // mint
    Color(0xFFEBE3F4), // lilac
    Color(0xFFFBEAC1), // butter
    Color(0xFFFCDDE0), // blush
    Color(0xFFD6EEDF), // green-mint
  ];

  @override
  Widget build(BuildContext context) {
    final cook = widget.cook;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero image with safe-area top bar ──
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Hero photo
                    SizedBox(
                      width: double.infinity,
                      height: 320.h,
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
                            size: 48.sp,
                          ),
                        ),
                      ),
                    ),
                    // Subtle top→bottom gradient for chip legibility
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 80.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: .25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Top bar (SafeArea aware)
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                        child: Row(
                          children: [
                            _HeroCircleBtn(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => Navigator.maybePop(context),
                            ),
                            const Spacer(),
                            _HeroCircleBtn(
                              icon: Icons.favorite_border_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tier badge floating bottom-left on hero
                    Positioned(
                      left: 16.w,
                      bottom: 14.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          cook.tier == 1
                              ? '🏠 Tier 1 · Home Kitchen'
                              : '✓ Tier 2 · Licensed Kitchen',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: cook.tier == 1
                                ? AppColors.tier1
                                : AppColors.tier2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Cook info card (clean, no overlap) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: avatar + name + rating
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22.r,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                cook.name
                                    .split(' ')
                                    .take(2)
                                    .map((s) => s.isNotEmpty ? s[0] : '')
                                    .join(),
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cook.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      letterSpacing: -.4,
                                      height: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    '${cook.cuisine} · Block 5',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Rating pill
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
                                    cook.rating.toStringAsFixed(1),
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
                        // Row 2: meta chips
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: [
                            FlatChip(
                              label: cook.tier == 1
                                  ? '✓ FSSAI Basic'
                                  : '✓ FSSAI Licensed',
                              bg: AppColors.secondarySoft,
                              fg: AppColors.secondary,
                            ),
                            if (!cook.shipping) ...[
                              FlatChip(
                                label:
                                    '📍 ${cook.distanceKm.toStringAsFixed(1)} km',
                                bg: AppColors.cream,
                                fg: AppColors.inkSoft,
                              ),
                              FlatChip(
                                label: '⏱ ${cook.etaMin} min',
                                bg: AppColors.cream,
                                fg: AppColors.inkSoft,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Trust stats strip ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(
                          big: 'FSSAI',
                          sub: cook.tier == 1 ? 'Basic' : 'Licensed',
                          color: AppColors.secondary,
                        ),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: AppColors.line,
                        ),
                        _Stat(big: '${cook.tenureYears} yrs', sub: 'On Padosi'),
                        Container(
                          width: 1,
                          height: 30.h,
                          color: AppColors.line,
                        ),
                        _Stat(
                          big: '${cook.onTimePct}%',
                          sub: 'On-time',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Today's menu header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kitchen's menu",
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: -.4,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${_menu.length} dishes today',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 9.w,
                      //     vertical: 5.h,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.primarySoft,
                      //     borderRadius: BorderRadius.circular(99.r),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(
                      //         Icons.schedule_rounded,
                      //         size: 12.sp,
                      //         color: AppColors.primaryDark,
                      //       ),
                      //       SizedBox(width: 4.w),
                      //       Text(
                      //         'Order by 11 AM',
                      //         style: GoogleFonts.inter(
                      //           fontSize: 10.5.sp,
                      //           fontWeight: FontWeight.w700,
                      //           color: AppColors.primaryDark,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),

              // Menu grid — same premium card style as Home
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 140.h),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: .64,
                  children: List.generate(_menu.length, (i) {
                    final d = _menu[i];
                    final cart = context.watch<CartProvider>();
                    return DishGridCard(
                      dish: d,
                      subtitle: cook.name,
                      tint: _dishTints[i % _dishTints.length],
                      count: cart.qtyOf(d.name),
                      onInc: () => context
                          .read<CartProvider>()
                          .inc(d, cookName: cook.name),
                      onDec: () =>
                          context.read<CartProvider>().dec(d.name),
                      onTap: () => Navigator.pushNamed(
                        context,
                        RouteNames.dishDetail,
                        arguments: {'dish': d, 'cookName': cook.name},
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          // Global floating cart bar — same widget used everywhere.
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlobalCartBar(),
          ),
        ],
      ),
    );
  }
}

// _CartBar removed — now using the shared GlobalCartBar widget.
/*
class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.items,
    required this.total,
    required this.onTap,
  });
  final int items;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: .08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 6.w, 10.h),
          child: Row(
            children: [
              // Left: price total + discount line
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Price total',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹$total',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: -.4,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '$items item${items == 1 ? '' : 's'}',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right: orange "Add to cart" pill
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 17.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Added to cart',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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

*/

/// Floating circular button used at the top of the hero image.
/// White surface + shadow so it stays legible over any food photo.
class _HeroCircleBtn extends StatelessWidget {
  const _HeroCircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 40.w,
              height: 40.w,
              child: Icon(icon, color: AppColors.ink, size: 19.sp),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.big, required this.sub, this.color});
  final String big;
  final String sub;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          big,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.ink,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          sub,
          style: GoogleFonts.inter(fontSize: 10.5.sp, color: AppColors.muted),
        ),
      ],
    );
  }
}

// _DishGridCard / _DishAddBtn / _DishStepper moved to
// widgets/padosi/dish_grid_card.dart — used by Dish Detail too.
// ───── DELETED CLASSES BELOW (kept commented during refactor) ─────
/*
class _DishGridCard_OBSOLETE extends StatelessWidget {
  const _DishGridCard_OBSOLETE({
    required this.dish,
    required this.cookName,
    required this.tint,
    required this.count,
    required this.onInc,
    required this.onDec,
    required this.onTap,
  });
  final Dish dish;
  final String cookName;
  final Color tint;
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero image (1.08:1)
              AspectRatio(
                aspectRatio: 1.08,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: SizedBox.expand(
                        child: dish.image != null
                            ? CachedNetworkImage(
                                imageUrl: dish.image!,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Shimmer.fromColors(
                                  baseColor: Colors.white.withValues(
                                    alpha: .35,
                                  ),
                                  highlightColor: Colors.white,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (_, _, _) => _emojiFallback(),
                              )
                            : _emojiFallback(),
                      ),
                    ),
                    if (dish.kcal != null)
                      Positioned(
                        bottom: 6.h,
                        right: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: .6),
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Text(
                            '${dish.kcal} kcal',
                            style: GoogleFonts.inter(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -.2,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          cookName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.ink.withValues(alpha: .65),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${dish.price}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: count == 0
                              ? _DishAddBtn(
                                  key: const ValueKey('add'),
                                  onTap: onInc,
                                )
                              : _DishStepper(
                                  key: const ValueKey('step'),
                                  count: count,
                                  onInc: onInc,
                                  onDec: onDec,
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
      ),
    );
  }

  Widget _emojiFallback() => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dish.heroGradient,
      ),
    ),
    child: Center(
      child: Text(dish.emoji, style: TextStyle(fontSize: 38.sp)),
    ),
  );
}

class _DishAddBtn extends StatelessWidget {
  const _DishAddBtn({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: Icon(Icons.add_rounded, color: Colors.white, size: 17.sp),
        ),
      ),
    );
  }
}

class _DishStepper extends StatelessWidget {
  const _DishStepper({
    super.key,
    required this.count,
    required this.onInc,
    required this.onDec,
  });
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.w,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onDec,
            child: SizedBox(
              width: 26.w,
              height: 28.w,
              child: Icon(
                Icons.remove_rounded,
                color: Colors.white,
                size: 15.sp,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: SizedBox(
              key: ValueKey(count),
              width: 18.w,
              child: Center(
                child: Text(
                  '$count',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onInc,
            child: SizedBox(
              width: 26.w,
              height: 28.w,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 15.sp),
            ),
          ),
        ],
      ),
    );
  }
}
*/
