import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/storage/prefs_storage.dart';
import '../../../controllers/address_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/address.dart';
import '../../../models/home_feed.dart';
import '../../widgets/padosi/add_to_cart.dart';
import '../../widgets/padosi/wishlist_heart.dart';
import '../padosi/location/location_result.dart';
import '../padosi/mock/mock_data.dart';

/// Mockup 09 — Home tab.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// null = still loading (show shimmer)
  String? _locLabel;
  int _categoryIndex = 0;
  final PageController _cookCtrl = PageController(viewportFraction: .88);

  // ── Home feed ──
  double _lat = 17.4451; // fallback until GPS resolves
  double _lng = 78.3502;
  bool _loadingHome = true;
  HomeFeed? _feed;
  String? _selectedCuisineId;

  // Pastel card tints, cycled across the menu grid.
  static const _tints = [
    Color(0xFFFFE7D6),
    Color(0xFFFBEAC6),
    Color(0xFFD6EEDF),
    Color(0xFFFFE0E0),
    Color(0xFFE7E0FF),
    Color(0xFFD9F0FF),
  ];

  @override
  void initState() {
    super.initState();
    // Reflect the selected/changed delivery address on the home feed.
    AddressController.instance.addListener(_onAddressesChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
    // Load the server cart so the floating cart bar reflects saved items.
    CartController.instance.refresh();
  }

  /// Pick the feed location: the customer's default saved address if they have
  /// one, otherwise the device GPS.
  Future<void> _initLocation() async {
    await AddressController.instance.fetch();
    final def = AddressController.instance.defaultAddress;
    if (def != null) {
      _useAddress(def);
    } else {
      _fetchLocation();
    }
  }

  /// When the customer adds / selects / changes their default address, switch
  /// the home feed to that location and reload (calls /user/home with new lat/lng).
  // Set once the user manually picks a location on the map, so the default-
  // address listener doesn't clobber their explicit choice.
  bool _manualPick = false;

  void _onAddressesChanged() {
    if (!mounted || _manualPick) return;
    final def = AddressController.instance.defaultAddress;
    if (def != null && (def.lat != _lat || def.lng != _lng)) {
      _useAddress(def);
    }
  }

  void _useAddress(Address a) {
    _lat = a.lat;
    _lng = a.lng;
    final label = (a.area?.isNotEmpty ?? false) ? a.area! : a.label;
    if (mounted) setState(() => _locLabel = label);
    _loadHome(); // re-fetch the feed for the selected address location
  }

  // ── Home feed loading ──
  Future<void> _loadHome() async {
    if (mounted) setState(() => _loadingHome = true);
    // Keep the cart's delivery location in sync for fee + radius checks.
    CartController.instance.setLocation(_lat, _lng);
    final feed = await HomeController.instance.getHome(
      lat: _lat,
      lng: _lng,
      cuisineId: _selectedCuisineId,
    );
    if (!mounted) return;
    setState(() {
      _feed = feed;
      _loadingHome = false;
    });
  }

  /// Tapping a category chip → filter the feed (index 0 = All).
  void _onCategory(int i) {
    setState(() => _categoryIndex = i);
    _selectedCuisineId = i == 0 ? null : _feed?.cuisines[i - 1].id;
    _loadHome();
  }

  /// Category chips = "All" + cuisines from the feed.
  List<FoodCategory> get _categories => [
    const FoodCategory(label: 'All', image: ''),
    ...?_feed?.cuisines.map(
      (c) => FoodCategory(label: c.name, image: c.imageUrl ?? ''),
    ),
  ];

  /// API cooks → existing Cook view model (widgets unchanged).
  List<Cook> get _cookCards => (_feed?.cooks ?? [])
      .map(
        (c) => Cook(
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
        ),
      )
      .toList();

  /// API dishes → existing MenuItem view model.
  List<MenuItem> get _dishCards {
    final dishes = _feed?.dishes ?? [];
    return [
      for (var i = 0; i < dishes.length; i++)
        MenuItem(
          id: dishes[i].id,
          name: dishes[i].name,
          cookName: dishes[i].cookName ?? '',
          priceInr: dishes[i].price.round(),
          kcal: 0, // calories not tracked by the backend
          image: dishes[i].imageUrl ?? '',
          tint: _tints[i % _tints.length],
        ),
    ];
  }

  @override
  void dispose() {
    AddressController.instance.removeListener(_onAddressesChanged);
    _cookCtrl.dispose();
    super.dispose();
  }

  // ─────────────────── Location ───────────────────

  Future<void> _fetchLocation() async {
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        _setLabel('Set delivery location');
        _loadHome(); // fall back to default coords
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _setLabel('Set delivery location');
        _loadHome(); // fall back to default coords
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      _lat = pos.latitude;
      _lng = pos.longitude;
      final label = await _reverseGeocode(pos.latitude, pos.longitude);
      // Persist so the cart defaults to the home screen's lat/lng.
      await PrefsStorage.instance.saveHomeLocation(
        pos.latitude,
        pos.longitude,
        label: label,
      );
      _setLabel(label);
      _loadHome();
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Home] Location error: $e');
      }
      _setLabel('Set delivery location');
      _loadHome(); // fall back to default coords
    }
  }

  void _setLabel(String s) {
    if (!mounted) return;
    setState(() => _locLabel = s);
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
        'addressdetails': '1',
        'zoom': '17',
      });
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'PadosiApp/1.0', 'Accept-Language': 'en-IN'},
      );
      if (resp.statusCode != 200) return 'Pinned location';
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final addr = (body['address'] as Map?)?.cast<String, dynamic>() ?? {};
      final locality =
          (addr['suburb'] ??
                  addr['neighbourhood'] ??
                  addr['village'] ??
                  addr['town'])
              as String?;
      final city = (addr['city'] ?? addr['town'] ?? addr['village']) as String?;
      if (locality != null && city != null && locality != city) {
        return '$locality, $city';
      }
      return (locality ?? city ?? 'Pinned location').toString();
    } catch (_) {
      return 'Pinned location';
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.pushNamed(
      context,
      RouteNames.selectLocation,
    );
    if (!mounted || result is! LocationResult) return;
    _manualPick = true;
    setState(() => _locLabel = result.label);
    _lat = result.point.latitude;
    _lng = result.point.longitude;
    // Persist + sync the cart so the picked location sticks everywhere.
    PrefsStorage.instance.saveHomeLocation(_lat, _lng, label: result.label);
    CartController.instance.setLocation(_lat, _lng);
    _loadHome(); // reload feed for the newly picked location → calls /user/home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Greeting + location chip ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LocationChip(label: _locLabel, onTap: _pickLocation),
                          SizedBox(height: 8.h),
                          Text(
                            'Hi, ${_feed?.userName ?? 'there'} 👋',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -.5,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _IconBtn(
                      icon: Icons.notifications_none_rounded,
                      hasDot: true,
                    ),
                  ],
                ),
              ),
            ),

            // // ── Search bar ──
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 16.w),
            //     child: AppSearchField(
            //       hint: 'Search dish, cook or cuisine',
            //       onSearch: (_) {},
            //     ),
            //   ),
            // ),

            // ── Category header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Text(
                    //   'Select by category',
                    //   style: GoogleFonts.spaceGrotesk(
                    //     fontSize: 18.sp,
                    //     fontWeight: FontWeight.w700,
                    //     letterSpacing: -.4,
                    //     color: AppColors.ink,
                    //   ),
                    // ),
                    // Text(
                    //   '${_feed?.cuisines.length ?? 0} options',
                    //   style: GoogleFonts.inter(
                    //     fontSize: 11.sp,
                    //     color: AppColors.muted,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // ── Category pills (food photo + label) ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 54.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final cat = _categories[i];
                    return _CategoryPill(
                      category: cat,
                      selected: i == _categoryIndex,
                      onTap: () => _onCategory(i),
                    );
                  },
                ),
              ),
            ),

            // ── "Cooks near you" header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fastest near you',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.4,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${_cookCards.length} verified cooks',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.discover),
                      child: Text(
                        'See all',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tall portrait cook carousel ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 320.h,
                child: _loadingHome
                    ? const _CookCarouselShimmer()
                    : _cookCards.isEmpty
                    ? const _EmptySection(
                        icon: Icons.storefront_outlined,
                        text: 'No kitchens near you yet',
                      )
                    : PageView.builder(
                        controller: _cookCtrl,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _cookCards.length.clamp(0, 4),
                        itemBuilder: (_, i) {
                          final cook = _cookCards[i];
                          final hc = _feed!.cooks[i];
                          return _CookHeroCard(
                            cook: cook,
                            wishlistId: hc.id,
                            wishlisted: hc.isWishlisted,
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.cookDetail,
                              arguments: cook,
                            ),
                          );
                        },
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
                    Text(
                      "Today's menu",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'See All',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 2-col menu grid ──
            // childAspectRatio scales with device width automatically —
            // each cell width = (screenW - sidePadding*2 - crossAxisSpacing)/2,
            // height = width / aspectRatio. No hardcoded pixel heights.
            if (_loadingHome)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 110.h),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: .64,
                  children: List.generate(4, (_) => const _MenuCellShimmer()),
                ),
              )
            else if (_dishCards.isEmpty)
              const SliverToBoxAdapter(
                child: _EmptySection(
                  icon: Icons.restaurant_menu_outlined,
                  text: "No dishes on today's menu",
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 110.h),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: .64,
                  children: _dishCards.map((m) {
                    final dish = Dish(
                      id: m.id,
                      name: m.name,
                      price: m.priceInr,
                      emoji: '🍽',
                      heroGradient: [m.tint, m.tint],
                      image: m.image,
                      kcal: m.kcal,
                    );
                    final cart = context.watch<CartController>();
                    final count = cart.qtyOf(m.id);
                    return _MenuGridCard(
                      item: m,
                      count: count,
                      onInc: () => count == 0
                          ? addToCart(context, m.id, silentSuccess: true)
                          : CartController.instance.increment(m.id),
                      onDec: () => CartController.instance.decrement(m.id),
                      onTap: () => Navigator.pushNamed(
                        context,
                        RouteNames.dishDetail,
                        arguments: {
                          'dish': dish,
                          'cookName': m.cookName,
                          'dishId': m.id,
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════ Sub-widgets ══════════════════════════

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.label, required this.onTap});
  final String? label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    if (label == null) {
      // Shimmer placeholder while location is being fetched
      return Shimmer.fromColors(
        baseColor: AppColors.line,
        highlightColor: Colors.white,
        period: const Duration(milliseconds: 1100),
        child: Container(
          width: 160.w,
          height: 30.h,
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(99.r),
          ),
        ),
      );
    }
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(99.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(99.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99.r),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18.w,
                height: 18.w,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.place_rounded,
                  size: 11.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 6.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 180.w),
                child: Text(
                  label!,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14.sp,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, this.hasDot = false});
  final IconData icon;
  final bool hasDot;
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: const BorderSide(color: AppColors.line),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () {},
            child: SizedBox(
              width: 38.w,
              height: 38.w,
              child: Icon(icon, size: 18.sp, color: AppColors.ink),
            ),
          ),
        ),
        if (hasDot)
          Positioned(
            top: 7,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

/// Category pill — circular food image + label inside a stadium pill.
/// Selected = coral filled with white text.
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
        side: BorderSide(color: selected ? AppColors.primary : AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(99.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(4.w, 4.h, 14.w, 4.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular food image
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

/// Tall portrait cook card — full-bleed food photo, rating chip + heart,
/// bottom gradient overlay with name + tier + chips.
class _CookHeroCard extends StatelessWidget {
  const _CookHeroCard({
    required this.cook,
    this.onTap,
    this.wishlistId,
    this.wishlisted = false,
  });
  final Cook cook;
  final VoidCallback? onTap;
  final String? wishlistId;
  final bool wishlisted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Material(
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.r),
          side: const BorderSide(color: AppColors.line),
        ),
        child: InkWell(
          onTap: onTap,
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
                      size: 48.sp,
                    ),
                  ),
                ),
              ),
              // Bottom gradient for legibility
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC000000)],
                      stops: [0.45, 1],
                    ),
                  ),
                ),
              ),
              // Top-left rating chip (only when a rating exists)
              if (cook.rating > 0)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 5.h,
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
                ),
              // Top-right wishlist heart (live)
              if (wishlistId != null && wishlistId!.isNotEmpty)
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: WishlistHeart(
                    type: 'kitchen',
                    targetId: wishlistId!,
                    initial: wishlisted,
                  ),
                ),
              // Bottom content
              Positioned(
                left: 14.w,
                right: 14.w,
                bottom: 14.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cook.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      cook.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: Colors.white.withValues(alpha: .85),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: cook.tier == 1
                                ? AppColors.tier1Soft
                                : AppColors.tier2Soft,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Text(
                            cook.tier == 1 ? '🏠 Tier 1' : '✓ Tier 2',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w700,
                              color: cook.tier == 1
                                  ? AppColors.tier1
                                  : AppColors.tier2,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                          child: Text(
                            cook.tier == 1
                                ? '✓ FSSAI Basic'
                                : '✓ FSSAI Licensed',
                            style: GoogleFonts.inter(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
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
      ),
    );
  }
}

/// Compact dish card sized for the 2-col SliverGrid.
class _MenuGridCard extends StatelessWidget {
  const _MenuGridCard({
    required this.item,
    required this.count,
    required this.onInc,
    required this.onDec,
    this.onTap,
  });
  final MenuItem item;
  final int count;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.tint,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero image (slightly wider than tall — saves a few px)
              AspectRatio(
                aspectRatio: 1.08,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: SizedBox.expand(
                        child: CachedNetworkImage(
                          imageUrl: item.image,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: .35),
                            highlightColor: Colors.white,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: Colors.black.withValues(alpha: .04),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: AppColors.muted,
                              size: 30.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (item.badge != null)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Text(
                            item.badge!,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    if (item.kcal > 0)
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
                            '${item.kcal} kcal',
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
                          item.name,
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
                          item.cookName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.ink.withValues(alpha: .65),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '₹${item.priceInr}',
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
                              ? _AddButton(
                                  key: const ValueKey('add'),
                                  onTap: onInc,
                                )
                              : _QtyStepper(
                                  key: const ValueKey('stepper'),
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
}

/// Initial add button — dark ink 28×28 circle with "+" icon.
class _AddButton extends StatelessWidget {
  const _AddButton({super.key, required this.onTap});
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

/// Quantity stepper — dark ink pill with − N + inline.
/// Same 28w height as [_AddButton] so the card layout doesn't reflow
/// when transitioning between the two states.
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
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
          _StepperBtn(icon: Icons.remove_rounded, onTap: onDec),
          // Animated number swap on change
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
          _StepperBtn(icon: Icons.add_rounded, onTap: onInc),
        ],
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 26.w,
        height: 28.w,
        child: Icon(icon, color: Colors.white, size: 15.sp),
      ),
    );
  }
}

// ══════════════════════════ Loading / empty ══════════════════════════

/// Shimmer placeholder shaped like the cook hero card.
class _CookCarouselShimmer extends StatelessWidget {
  const _CookCarouselShimmer();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      child: Shimmer.fromColors(
        baseColor: AppColors.line,
        highlightColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.line,
            borderRadius: BorderRadius.circular(22.r),
          ),
        ),
      ),
    );
  }
}

/// Shimmer cell shaped like a menu grid card.
class _MenuCellShimmer extends StatelessWidget {
  const _MenuCellShimmer();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.line,
      highlightColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.line,
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}

/// Neutral empty state for a home section.
class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40.sp, color: AppColors.muted),
          SizedBox(height: 12.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
