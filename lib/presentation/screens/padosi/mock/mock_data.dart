import 'package:flutter/material.dart';

/// Mock data for the Padosi UI demo.
///
/// Images are stable Unsplash photos — they download via
/// `cached_network_image` and are cached after first load.
class Cook {
  const Cook({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.distanceKm,
    required this.etaMin,
    required this.rating,
    required this.tier,
    required this.heroEmoji,
    required this.heroGradient,
    required this.image,
    this.isNew = false,
    this.shipping = false,
    this.fssaiNo,
    this.tenureYears = 1,
    this.onTimePct = 96,
    this.menu = const [],
  });

  final String id;
  final String name;
  final String cuisine;
  final double distanceKm;
  final int etaMin;
  final double rating;
  final int tier; // 1 or 2
  final String heroEmoji;
  final List<Color> heroGradient;
  final String image;          // network food/cook photo
  final bool isNew;
  final bool shipping;
  final String? fssaiNo;
  final int tenureYears;
  final int onTimePct;
  final List<Dish> menu;

  String get subtitle =>
      shipping
          ? '$cuisine · ships in 2 days'
          : '$cuisine · ${distanceKm.toStringAsFixed(1)} km · $etaMin min';
}

class Dish {
  const Dish({
    required this.name,
    required this.price,
    required this.emoji,
    required this.heroGradient,
    this.image,
    this.kcal,
  });

  final String name;
  final int price;
  final String emoji;
  final List<Color> heroGradient;
  final String? image;
  final int? kcal;
}

/// Featured items for the "Today's menu" horizontal rail on Home.
class MenuItem {
  const MenuItem({
    required this.name,
    required this.cookName,
    required this.priceInr,
    required this.kcal,
    required this.image,
    required this.tint,
    this.badge,
    this.weightLabel,
  });

  final String name;
  final String cookName;
  final int priceInr;
  final int kcal;
  final String image;
  final Color tint; // pastel card surface
  final String? badge; // "Popular" / "Limited" / "New"
  final String? weightLabel; // e.g. "320 g"
}

class MockData {
  MockData._();

  // Pastel gradients (kept for back-compat with dish tiles)
  static const _coral = [Color(0xFFFFE3D2), Color(0xFFFFD0B8)];
  static const _gold = [Color(0xFFFBEFD9), Color(0xFFF0E4C2)];
  static const _teal = [Color(0xFFE2F0ED), Color(0xFFCFE8E2)];
  static const _green = [Color(0xFFE6F2E9), Color(0xFFCFE8D6)];
  static const _violet = [Color(0xFFFCE7E1), Color(0xFFDED5F0)];

  // Pastel tile colors for premium MenuItem cards
  static const Color _tintPeach = Color(0xFFFFE7D6);
  static const Color _tintMint = Color(0xFFE3F1E9);
  static const Color _tintLilac = Color(0xFFEBE3F4);
  static const Color _tintButter = Color(0xFFFBEAC1);
  static const Color _tintBlush = Color(0xFFFCDDE0);

  // ─── Unsplash food photos (stable IDs, sized for thumbnails) ───
  static const _imgThali =
      'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=720&q=80&auto=format&fit=crop';
  static const _imgCurry =
      'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=720&q=80&auto=format&fit=crop';
  static const _imgDal =
      'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=720&q=80&auto=format&fit=crop';
  static const _imgBiryani =
      'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=720&q=80&auto=format&fit=crop';
  static const _imgPaneer =
      'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=720&q=80&auto=format&fit=crop';
  static const _imgBowl =
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=720&q=80&auto=format&fit=crop';
  static const _imgVeggies =
      'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=720&q=80&auto=format&fit=crop';
  static const _imgPickles =
      'https://images.unsplash.com/photo-1599909533730-d56f9c5f7c6b?w=720&q=80&auto=format&fit=crop';
  static const _imgFish =
      'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=720&q=80&auto=format&fit=crop';
  static const _imgDosa =
      'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=720&q=80&auto=format&fit=crop';
  static const _imgParatha =
      'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=720&q=80&auto=format&fit=crop';

  // ─────────────── Cooks ───────────────

  static const sunita = Cook(
    id: 'sunita',
    name: 'Sunita Aunty',
    cuisine: 'North Indian thali',
    distanceKm: 0.4,
    etaMin: 28,
    rating: 4.9,
    tier: 1,
    heroEmoji: '🍛',
    heroGradient: _coral,
    image: _imgThali,
    fssaiNo: '1224 5678 1234 81',
    tenureYears: 2,
    onTimePct: 98,
    menu: [
      Dish(
        name: 'Rajma Chawal',
        price: 90,
        emoji: '🍛',
        heroGradient: _coral,
        image: _imgCurry,
        kcal: 420,
      ),
      Dish(
        name: 'Full Veg Thali',
        price: 120,
        emoji: '🍱',
        heroGradient: _gold,
        image: _imgThali,
        kcal: 680,
      ),
      Dish(
        name: 'Paneer Butter Masala',
        price: 140,
        emoji: '🥘',
        heroGradient: _coral,
        image: _imgPaneer,
        kcal: 520,
      ),
      Dish(
        name: 'Aloo Paratha (2 pc)',
        price: 70,
        emoji: '🥟',
        heroGradient: _gold,
        image: _imgParatha,
        kcal: 380,
      ),
    ],
  );

  static const cooks = <Cook>[
    sunita,
    Cook(
      id: 'healthy_bowl',
      name: 'Healthy Bowl Kitchen',
      cuisine: 'Diabetic-friendly',
      distanceKm: 1.1,
      etaMin: 30,
      rating: 4.7,
      tier: 2,
      heroEmoji: '🥗',
      heroGradient: _teal,
      image: _imgBowl,
      fssaiNo: '1019 4567 0000 22',
      tenureYears: 3,
      onTimePct: 96,
    ),
    Cook(
      id: 'lakshmi',
      name: 'Lakshmi Amma',
      cuisine: 'Andhra meals',
      distanceKm: 0.8,
      etaMin: 25,
      rating: 4.8,
      tier: 1,
      heroEmoji: '🍲',
      heroGradient: _gold,
      image: _imgBiryani,
    ),
    Cook(
      id: 'jain_rasoi',
      name: 'Jain Rasoi',
      cuisine: 'Pure Jain',
      distanceKm: 1.2,
      etaMin: 35,
      rating: 5.0,
      tier: 1,
      heroEmoji: '🌿',
      heroGradient: _violet,
      image: _imgVeggies,
      isNew: true,
    ),
    Cook(
      id: 'ratna',
      name: 'Ratna’s Pickles',
      cuisine: 'Homemade pickles',
      distanceKm: 0,
      etaMin: 0,
      rating: 4.9,
      tier: 1,
      heroEmoji: '🫙',
      heroGradient: _coral,
      image: _imgPickles,
      shipping: true,
    ),
    Cook(
      id: 'bengali',
      name: 'Maa’s Bengali Kitchen',
      cuisine: 'Bengali fish curry',
      distanceKm: 1.6,
      etaMin: 35,
      rating: 4.7,
      tier: 1,
      heroEmoji: '🐟',
      heroGradient: _green,
      image: _imgFish,
    ),
  ];

  // ─────────────── Today's menu (premium rail) ───────────────

  static const menuItems = <MenuItem>[
    MenuItem(
      name: 'Andhra Veg Thali',
      cookName: 'Lakshmi Amma',
      priceInr: 140,
      kcal: 680,
      image: _imgThali,
      tint: _tintButter,
      badge: 'Popular',
      weightLabel: '480 g',
    ),
    MenuItem(
      name: 'Paneer Butter Masala',
      cookName: 'Sunita Aunty',
      priceInr: 160,
      kcal: 520,
      image: _imgPaneer,
      tint: _tintPeach,
      badge: 'Limited',
      weightLabel: '300 g',
    ),
    MenuItem(
      name: 'Hyderabadi Biryani',
      cookName: 'Chefs’ Den',
      priceInr: 220,
      kcal: 740,
      image: _imgBiryani,
      tint: _tintBlush,
      badge: 'Chef’s pick',
      weightLabel: '420 g',
    ),
    MenuItem(
      name: 'Quinoa Power Bowl',
      cookName: 'Healthy Bowl Kitchen',
      priceInr: 180,
      kcal: 380,
      image: _imgBowl,
      tint: _tintMint,
      badge: 'Diabetic-friendly',
      weightLabel: '350 g',
    ),
    MenuItem(
      name: 'Masala Dosa',
      cookName: 'Lakshmi Amma',
      priceInr: 90,
      kcal: 410,
      image: _imgDosa,
      tint: _tintLilac,
      weightLabel: '260 g',
    ),
    MenuItem(
      name: 'Dal Tadka & Roti',
      cookName: 'Sunita Aunty',
      priceInr: 110,
      kcal: 450,
      image: _imgDal,
      tint: _tintMint,
      weightLabel: '380 g',
    ),
  ];

  // ─────────────── Specialty tiles (unchanged) ───────────────

  static const _imgSweets =
      'https://images.unsplash.com/photo-1606471191009-63994c53433b?w=400&q=80&auto=format&fit=crop';
  static const _imgDrinks =
      'https://images.unsplash.com/photo-1497534547324-0ebb3f052e88?w=400&q=80&auto=format&fit=crop';

  static const specialties = <FoodCategory>[
    FoodCategory(label: 'All', image: _imgBowl),
    FoodCategory(label: 'Breakfast', image: _imgDosa),
    FoodCategory(label: 'Lunch', image: _imgThali),
    FoodCategory(label: 'Dinner', image: _imgCurry),
    FoodCategory(label: 'Snacks', image: _imgParatha),
    FoodCategory(label: 'Drinks', image: _imgDrinks),
    FoodCategory(label: 'Sweets', image: _imgSweets),
    FoodCategory(label: 'Jain', image: _imgVeggies),
    FoodCategory(label: 'Diabetic', image: _imgBowl),
    FoodCategory(label: 'Postpartum', image: _imgDal),
  ];
}

class FoodCategory {
  const FoodCategory({required this.label, required this.image});
  final String label;
  final String image;
}
