// Models for the customer home feed (GET /api/user/home).

class HomeCuisine {
  const HomeCuisine({required this.id, required this.name, this.imageUrl});
  final String id;
  final String name;
  final String? imageUrl;

  factory HomeCuisine.fromJson(Map<String, dynamic> j) => HomeCuisine(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        imageUrl: j['imageUrl']?.toString(),
      );
}

class HomeCook {
  const HomeCook({
    required this.id,
    required this.name,
    this.ownerName,
    this.bannerUrl,
    this.selfieUrl,
    this.tier = 1,
    this.fssai,
    this.cuisines,
    this.isVegOnly = false,
    this.city,
    this.rating,
    this.distanceKm,
    this.etaMins,
    this.isWishlisted = false,
  });

  final String id;
  final String name;
  final String? ownerName;
  final String? bannerUrl;
  final String? selfieUrl;
  final int tier;
  final String? fssai;
  final String? cuisines;
  final bool isVegOnly;
  final String? city;
  final double? rating;
  final double? distanceKm;
  final int? etaMins;
  final bool isWishlisted;

  factory HomeCook.fromJson(Map<String, dynamic> j) => HomeCook(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        ownerName: j['ownerName']?.toString(),
        bannerUrl: j['bannerUrl']?.toString(),
        selfieUrl: j['selfieUrl']?.toString(),
        tier: (j['tier'] as num?)?.toInt() ?? 1,
        fssai: j['fssai']?.toString(),
        cuisines: j['cuisines']?.toString(),
        isVegOnly: j['isVegOnly'] as bool? ?? false,
        city: j['city']?.toString(),
        rating: (j['rating'] as num?)?.toDouble(),
        distanceKm: (j['distanceKm'] as num?)?.toDouble(),
        etaMins: (j['etaMins'] as num?)?.toInt(),
        isWishlisted: j['isWishlisted'] as bool? ?? false,
      );
}

class HomeDish {
  const HomeDish({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.cookId,
    this.cookName,
    this.diet,
    this.spice,
    this.eggless = true,
  });

  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? cookId;
  final String? cookName;
  final String? diet;
  final String? spice;
  final bool eggless;

  factory HomeDish.fromJson(Map<String, dynamic> j) => HomeDish(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        imageUrl: j['imageUrl']?.toString(),
        cookId: j['cookId']?.toString(),
        cookName: j['cookName']?.toString(),
        diet: j['diet']?.toString(),
        spice: j['spice']?.toString(),
        eggless: j['eggless'] as bool? ?? true,
      );
}

class HomeFeed {
  const HomeFeed({
    required this.cuisines,
    required this.cooks,
    required this.dishes,
    this.userName,
  });

  final List<HomeCuisine> cuisines;
  final List<HomeCook> cooks;
  final List<HomeDish> dishes;
  final String? userName;

  factory HomeFeed.fromJson(Map<String, dynamic> j) => HomeFeed(
        userName: j['userName']?.toString(),
        cuisines: ((j['cuisines'] as List?) ?? [])
            .map((e) => HomeCuisine.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        cooks: ((j['cooks'] as List?) ?? [])
            .map((e) => HomeCook.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        dishes: ((j['dishes'] as List?) ?? [])
            .map((e) => HomeDish.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  bool get isEmpty => cooks.isEmpty && dishes.isEmpty;
}
