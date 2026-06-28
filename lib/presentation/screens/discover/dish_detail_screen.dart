import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controllers/catalog_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/home_feed.dart';
import '../../widgets/padosi/add_to_cart.dart';
import '../../widgets/padosi/dish_grid_card.dart';
import '../../widgets/padosi/global_cart_bar.dart';
import '../padosi/mock/mock_data.dart';

/// Mockup 14 — Dish detail.
/// Matches the visual language of Home + Cook Detail:
///  - white card surfaces with thin line borders (20r)
///  - cream secondary surfaces for grouped meta
///  - tangerine accents for price + CTAs
///  - Space Grotesk for display, Inter for body
class DishDetailScreen extends StatefulWidget {
  const DishDetailScreen({
    super.key,
    required this.dish,
    this.cookName,
    this.dishId,
  });
  final Dish dish;
  final String? cookName;
  final String? dishId;
  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  final int _qty = 1;
  String _spice = 'Medium';

  /// Recommended products from the API (dish detail). Empty → fall back
  /// to the static cross-sell add-ons.
  List<HomeDish> _recommended = [];

  @override
  void initState() {
    super.initState();
    _loadRecommended();
  }

  Future<void> _loadRecommended() async {
    if (widget.dishId == null || widget.dishId!.isEmpty) return;
    final detail = await CatalogController.instance.getDish(widget.dishId!);
    if (!mounted || detail == null) return;
    setState(() => _recommended = detail.recommended);
  }

  Dish _toDish(HomeDish h) => Dish(
        name: h.name,
        price: h.price.round(),
        emoji: '🍽',
        heroGradient: const [AppColors.primary, AppColors.primary],
        image: h.imageUrl ?? '',
        kcal: 0,
      );

  /// addon.name → count.
  final Map<String, int> _addonQty = {};

  // Rotating pastel palette — same as cook_detail_screen menu grid.
  static const _addonTints = <Color>[
    Color(0xFFFFE7D6), // peach
    Color(0xFFE3F1E9), // mint
    Color(0xFFEBE3F4), // lilac
    Color(0xFFFBEAC1), // butter
    Color(0xFFFCDDE0), // blush
  ];

  static const _spiceLevels = ['Mild', 'Medium', 'Spicy'];

  // Cross-sell add-ons — modeled as Dish so we can reuse DishGridCard.
  // Gradients become the emoji-fallback bg when no image is set.
  static const _addons = <Dish>[
    Dish(
      name: 'Sweet Lassi',
      price: 40,
      emoji: '🥛',
      heroGradient: [Color(0xFFFFE7D6), Color(0xFFFFD0B8)],
      kcal: 180,
    ),
    Dish(
      name: 'Masala Chai',
      price: 25,
      emoji: '🍵',
      heroGradient: [Color(0xFFFBEAC1), Color(0xFFF2DCA6)],
      kcal: 70,
    ),
    Dish(
      name: 'Gulab Jamun',
      price: 50,
      emoji: '🍮',
      heroGradient: [Color(0xFFFCDDE0), Color(0xFFEDC4D0)],
      kcal: 220,
    ),
    Dish(
      name: 'Extra Roti',
      price: 15,
      emoji: '🫓',
      heroGradient: [Color(0xFFE3F1E9), Color(0xFFCFE8DA)],
      kcal: 110,
    ),
  ];

  void _incAddon(String name) =>
      setState(() => _addonQty[name] = (_addonQty[name] ?? 0) + 1);
  void _decAddon(String name) => setState(() {
    final c = (_addonQty[name] ?? 0) - 1;
    if (c <= 0) {
      _addonQty.remove(name);
    } else {
      _addonQty[name] = c;
    }
  });

  // Totals are computed by the cart screen — no need to track them here.

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    final cookName = widget.cookName ?? 'Home chef';
    final heroTint = dish.heroGradient.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero (pastel bg + floating circular food image) ──
              SliverToBoxAdapter(
                child: _Hero(dish: dish, tint: heroTint),
              ),

              // ── Content sheet (sits cleanly below the hero) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 140.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title card ──
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + kcal pill
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    dish.name,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      letterSpacing: -.5,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                if (dish.kcal != null) ...[
                                  SizedBox(width: 10.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 9.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cream,
                                      borderRadius: BorderRadius.circular(99.r),
                                    ),
                                    child: Text(
                                      '${dish.kcal} kcal',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 6.h),
                            // by cook line
                            Row(
                              children: [
                                Text(
                                  'by ',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                                Text(
                                  cookName,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            // Meta chips
                            Wrap(
                              spacing: 6.w,
                              runSpacing: 6.h,
                              children: [
                                _FlatChip(
                                  label: '🌿 Veg',
                                  bg: AppColors.secondarySoft,
                                  fg: AppColors.secondary,
                                ),
                                _FlatChip(
                                  label: '✓ FSSAI Basic',
                                  bg: AppColors.cream,
                                  fg: AppColors.inkSoft,
                                ),
                                _FlatChip(
                                  label: '🔥 Cooked fresh',
                                  bg: AppColors.cream,
                                  fg: AppColors.inkSoft,
                                ),
                              ],
                            ),
                            // Price
                            SizedBox(height: 14.h),
                            Divider(height: 1, color: AppColors.line),
                            SizedBox(height: 14.h),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '₹${dish.price}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: -.4,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: Text(
                                    '/ serving',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Small "Add to cart" pill — adds the
                                // dish to the global cart at the current
                                // quantity (defaults to 1).
                                Builder(builder: (context) {
                                  final addId = widget.dishId ?? dish.id;
                                  final count = addId.isEmpty
                                      ? 0
                                      : context
                                          .watch<CartController>()
                                          .qtyOf(addId);
                                  return _DishAddPill(
                                    count: count,
                                    onAdd: () =>
                                        addToCart(context, addId, qty: _qty),
                                    onInc: () => CartController.instance
                                        .increment(addId),
                                    onDec: () => CartController.instance
                                        .decrement(addId),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Description card ──
                      SizedBox(height: 12.h),
                      _SectionCard(
                        kicker: 'About this dish',
                        child: Text(
                          _descriptionFor(dish.name),
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: AppColors.inkSoft,
                            height: 1.6,
                          ),
                        ),
                      ),

                      // ── Spice level card ──
                      SizedBox(height: 12.h),
                      _SectionCard(
                        kicker: 'Spice level',
                        child: Row(
                          children: _spiceLevels
                              .map(
                                (s) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: s == _spiceLevels.last ? 0 : 8.w,
                                    ),
                                    child: _SpicePill(
                                      label: s,
                                      selected: _spice == s,
                                      onTap: () => setState(() => _spice = s),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                      // ── Add-ons section (cross-sell) ──
                      SizedBox(height: 22.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add to order',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                    letterSpacing: -.4,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Pair it with something nice',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cream,
                                borderRadius: BorderRadius.circular(99.r),
                              ),
                              child: Text(
                                'Optional',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.inkSoft,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: .64,
                        children: () {
                          // Prefer API recommended products; else cross-sell add-ons.
                          final items = _recommended.isNotEmpty
                              ? _recommended.map(_toDish).toList()
                              : _addons;
                          return List.generate(items.length, (i) {
                            final a = items[i];
                            return DishGridCard(
                              dish: a,
                              subtitle: 'Recommended',
                              tint: _addonTints[i % _addonTints.length],
                              count: _addonQty[a.name] ?? 0,
                              onInc: () => _incAddon(a.name),
                              onDec: () => _decAddon(a.name),
                            );
                          });
                        }(),
                      ),

                      // ── Inline "Add to order" CTA ──
                      // Replaces the old floating dish-cart bar — the
                      // GlobalCartBar already floats over every screen,
                      // so we just need an in-flow button here.
                      SizedBox(height: 100.h), // breathing room above bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Global floating cart bar — same widget used everywhere ──
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

  String _descriptionFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('thali')) {
      return 'Dal, 2 sabzi, rice, 4 fresh rotis, salad & a sweet. '
          'Cooked fresh to order — packed warm, sealed for delivery.';
    }
    if (n.contains('rajma')) {
      return 'Slow-cooked kidney beans in onion-tomato gravy with steamed '
          'basmati rice. Less oil, mild spice — home-style comfort food.';
    }
    if (n.contains('paneer')) {
      return 'Hand-pressed paneer cubes in a rich butter-tomato gravy. '
          'Mild, creamy and slightly sweet — pair with butter naan or rice.';
    }
    if (n.contains('paratha')) {
      return 'Stuffed aloo paratha (2 pcs) cooked on tawa with desi ghee. '
          'Served with butter, curd and pickle.';
    }
    return 'Fresh, home-cooked goodness — exactly the way you remember it. '
        'Made to order, packed warm.';
  }
}

// ──────────────────────── Sub-widgets ────────────────────────

/// Compact "Add to cart" pill that lives beside the price row.
/// When the dish is not in the cart → tangerine "Add" pill.
/// When it is → cream "− N +" stepper. Morphs with AnimatedSwitcher.
class _DishAddPill extends StatelessWidget {
  const _DishAddPill({
    required this.count,
    required this.onAdd,
    required this.onInc,
    required this.onDec,
  });
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onInc;
  final VoidCallback onDec;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: count == 0
          ? Material(
              key: const ValueKey('add'),
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(99.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(99.r),
                onTap: onAdd,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Add',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              key: const ValueKey('step'),
              height: 34.h,
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
                      width: 32.w,
                      height: 34.h,
                      child: Icon(
                        Icons.remove_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 22.w,
                    child: Center(
                      child: Text(
                        '$count',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onInc,
                    child: SizedBox(
                      width: 32.w,
                      height: 34.h,
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Top hero — pastel tint background, floating circular food image,
/// SafeArea-aware back + heart in the corners.
class _Hero extends StatelessWidget {
  const _Hero({required this.dish, required this.tint});
  final Dish dish;
  final Color tint;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-width photo (rectangular — no oval crop)
        SizedBox(
          width: double.infinity,
          height: 320.h,
          child: dish.image != null
              ? CachedNetworkImage(
                  imageUrl: dish.image!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Shimmer.fromColors(
                    baseColor: tint,
                    highlightColor: Colors.white,
                    child: Container(color: tint),
                  ),
                  errorWidget: (_, _, _) => _emojiFallback(dish),
                )
              : _emojiFallback(dish),
        ),
        // Bottom gradient for chip legibility
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 90.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .28),
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
                _CircleBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.maybePop(context),
                ),
                const Spacer(),
                _CircleBtn(icon: Icons.favorite_border_rounded, onTap: () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _emojiFallback(Dish d) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: d.heroGradient,
      ),
    ),
    child: Center(
      child: Text(d.emoji, style: TextStyle(fontSize: 88.sp)),
    ),
  );
}

/// White card with a small uppercase "kicker" label + body.
/// Same surface treatment used across the app.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.kicker, required this.child});
  final String kicker;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _SpicePill extends StatelessWidget {
  const _SpicePill({
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
      color: selected ? AppColors.ink : AppColors.cream,
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(13.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 13.h),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlatChip extends StatelessWidget {
  const _FlatChip({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
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
