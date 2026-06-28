// Server-side cart DTOs — mirror the backend `/api/user/cart` response.
// The client NEVER computes money; every figure here comes from the server.

class CartItemDto {
  const CartItemDto({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.qty,
    required this.lineTotal,
    required this.isAvailable,
    this.imageUrl,
  });

  final String menuItemId;
  final String name;
  final num price;
  final int qty;
  final num lineTotal;
  final bool isAvailable;
  final String? imageUrl;

  factory CartItemDto.fromJson(Map<String, dynamic> j) => CartItemDto(
        menuItemId: j['menuItemId']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        price: (j['price'] as num?) ?? 0,
        qty: (j['qty'] as num?)?.toInt() ?? 0,
        lineTotal: (j['lineTotal'] as num?) ?? 0,
        isAvailable: j['isAvailable'] as bool? ?? true,
        imageUrl: j['imageUrl']?.toString(),
      );
}

class CartKitchen {
  const CartKitchen({required this.id, required this.name, this.tier, this.etaMins});
  final String id;
  final String name;
  final int? tier;
  final int? etaMins;

  factory CartKitchen.fromJson(Map<String, dynamic> j) => CartKitchen(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        tier: (j['tier'] as num?)?.toInt(),
        etaMins: (j['etaMins'] as num?)?.toInt(),
      );
}

class CartBill {
  const CartBill({
    required this.itemTotal,
    required this.discount,
    required this.deliveryFee,
    required this.taxesCharges,
    required this.grandTotal,
    this.couponCode,
    this.couponValid = false,
  });

  final num itemTotal;
  final num discount;
  final num deliveryFee;
  final num taxesCharges;
  final num grandTotal;
  final String? couponCode;
  final bool couponValid;

  factory CartBill.fromJson(Map<String, dynamic> j) => CartBill(
        itemTotal: (j['itemTotal'] as num?) ?? 0,
        discount: (j['discount'] as num?) ?? 0,
        deliveryFee: (j['deliveryFee'] as num?) ?? 0,
        taxesCharges: (j['taxesCharges'] as num?) ?? 0,
        grandTotal: (j['grandTotal'] as num?) ?? 0,
        couponCode: j['couponCode']?.toString(),
        couponValid: j['couponValid'] as bool? ?? false,
      );

  static const empty = CartBill(
    itemTotal: 0,
    discount: 0,
    deliveryFee: 0,
    taxesCharges: 0,
    grandTotal: 0,
  );
}

class CartData {
  const CartData({
    required this.cartId,
    required this.fulfillment,
    required this.items,
    required this.itemCount,
    required this.bill,
    required this.serviceable,
    this.kitchen,
    this.distanceKm,
    this.serviceRadiusKm,
    this.couponError,
    this.serviceMessage,
  });

  final String cartId;
  final String fulfillment; // 'delivery' | 'pickup'
  final List<CartItemDto> items;
  final int itemCount;
  final CartBill bill;
  final bool serviceable;
  final CartKitchen? kitchen;
  final num? distanceKm;
  final num? serviceRadiusKm;
  final String? couponError;
  final String? serviceMessage; // why delivery isn't available (out of radius)

  bool get isEmpty => items.isEmpty;
  bool get isDelivery => fulfillment != 'pickup';

  factory CartData.fromJson(Map<String, dynamic> j) => CartData(
        cartId: j['cartId']?.toString() ?? '',
        fulfillment: j['fulfillment']?.toString() ?? 'delivery',
        items: (j['items'] as List?)
                ?.map((e) => CartItemDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        itemCount: (j['itemCount'] as num?)?.toInt() ?? 0,
        bill: j['bill'] is Map
            ? CartBill.fromJson(j['bill'] as Map<String, dynamic>)
            : CartBill.empty,
        serviceable: j['serviceable'] as bool? ?? true,
        kitchen: j['kitchen'] is Map
            ? CartKitchen.fromJson(j['kitchen'] as Map<String, dynamic>)
            : null,
        distanceKm: j['distanceKm'] as num?,
        serviceRadiusKm: j['serviceRadiusKm'] as num?,
        couponError: j['couponError']?.toString(),
        serviceMessage: j['serviceMessage']?.toString(),
      );

  static const empty = CartData(
    cartId: '',
    fulfillment: 'delivery',
    items: [],
    itemCount: 0,
    bill: CartBill.empty,
    serviceable: true,
  );
}

/// Returned by add-to-cart when the cart belongs to a different kitchen.
/// The UI uses this to show a "clear cart?" dialog.
class CartKitchenConflict {
  const CartKitchenConflict({required this.currentKitchen, required this.newKitchen, this.message});
  final String currentKitchen;
  final String newKitchen;
  final String? message;
}

/// Result of an add-to-cart attempt.
class AddToCartResult {
  const AddToCartResult({this.cart, this.conflict, this.error});
  final CartData? cart;
  final CartKitchenConflict? conflict;
  final String? error;

  bool get ok => cart != null;
  bool get hasConflict => conflict != null;
}
