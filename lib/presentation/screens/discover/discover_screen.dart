import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controllers/catalog_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../models/home_feed.dart';
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
  String? _cuisineId;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _page = 1;
  List<HomeCuisine> _cuisines = [];
  List<HomeCook> _kitchens = [];
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _cuisines = await CatalogController.instance.getCuisines();
    await _loadKitchens();
  }

  Future<void> _loadKitchens() async {
    if (mounted) setState(() => _loading = true);
    final res = await CatalogController.instance
        .listKitchens(cuisineId: _cuisineId, page: 1);
    if (!mounted) return;
    setState(() {
      _kitchens = res.items;
      _hasMore = res.hasMore;
      _page = 1;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    setState(() => _loadingMore = true);
    final next = _page + 1;
    final res = await CatalogController.instance
        .listKitchens(cuisineId: _cuisineId, page: next);
    if (!mounted) return;
    setState(() {
      _kitchens.addAll(res.items);
      _page = next;
      _hasMore = res.hasMore;
      _loadingMore = false;
    });
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  void _onCategory(int i) {
    setState(() => _f = i);
    _cuisineId = i == 0 ? null : _cuisines[i - 1].id;
    _loadKitchens();
  }

  /// Category chips = "All" + cuisines from the API.
  List<FoodCategory> get _cats => [
        const FoodCategory(label: 'All', image: ''),
        ..._cuisines.map(
          (c) => FoodCategory(label: c.name, image: c.imageUrl ?? ''),
        ),
      ];

  /// API kitchens → existing Cook view model (CookRowCard unchanged).
  List<Cook> get _visible => _kitchens
      .map((c) => Cook(
            id: c.id,
            name: c.name,
            cuisine: (c.cuisines == null || c.cuisines!.isEmpty)
                ? 'Home kitchen'
                : c.cuisines!,
            distanceKm: c.distanceKm ?? 0,
            etaMin: c.etaMins ?? 0,
            rating: c.rating ?? 0,
            tier: c.tier,
            heroEmoji: '🍽',
            heroGradient: const [AppColors.primary, AppColors.primary],
            image: (c.bannerUrl?.isNotEmpty ?? false)
                ? c.bannerUrl!
                : (c.selfieUrl ?? ''),
          ))
      .toList();

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
                          '${_kitchens.length} home chefs near you',
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
                  onTap: () => _onCategory(i),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // ── List / loading / empty ──
            Expanded(
              child: _loading
                  ? ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 110.h),
                      itemCount: 5,
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                      itemBuilder: (_, _) => Shimmer.fromColors(
                        baseColor: AppColors.line,
                        highlightColor: Colors.white,
                        child: Container(
                          height: 96.h,
                          decoration: BoxDecoration(
                            color: AppColors.line,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ),
                    )
                  : list.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      controller: _scroll,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 110.h),
                      itemCount: list.length + (_hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                      itemBuilder: (_, i) {
                        if (i >= list.length) {
                          // Footer loader while fetching the next page.
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            ),
                          );
                        }
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
