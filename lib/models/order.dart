// Order DTOs — mirror the backend Order model.

class OrderItemDto {
  const OrderItemDto({required this.name, required this.price, required this.qty, required this.lineTotal, this.imageUrl});
  final String name;
  final num price;
  final int qty;
  final num lineTotal;
  final String? imageUrl;

  factory OrderItemDto.fromJson(Map<String, dynamic> j) => OrderItemDto(
        name: j['name']?.toString() ?? '',
        price: (j['price'] as num?) ?? 0,
        qty: (j['qty'] as num?)?.toInt() ?? 0,
        lineTotal: (j['lineTotal'] as num?) ?? 0,
        imageUrl: j['imageUrl']?.toString(),
      );
}

class Order {
  const Order({
    required this.id,
    required this.status,
    required this.paymentStatus,
    required this.fulfillment,
    required this.grandTotal,
    required this.items,
    this.kitchenName,
    this.itemTotal = 0,
    this.discount = 0,
    this.deliveryFee = 0,
    this.taxesCharges = 0,
    this.couponCode,
    this.handoffCode,
    this.addressLine1,
    this.addressArea,
    this.receiverName,
    this.receiverPhone,
    this.createdAt,
  });

  final String id;
  final String status; // PLACED, ACCEPTED, PREPARING, READY, OUT_FOR_DELIVERY, DELIVERED, CANCELLED
  final String paymentStatus;
  final String fulfillment;
  final num grandTotal;
  final num itemTotal;
  final num discount;
  final num deliveryFee;
  final num taxesCharges;
  final String? couponCode;
  final String? handoffCode;
  final String? addressLine1;
  final String? addressArea;
  final String? receiverName;
  final String? receiverPhone;
  final String? createdAt;
  final String? kitchenName;
  final List<OrderItemDto> items;

  bool get isPickup => fulfillment == 'pickup';
  int get itemCount => items.fold(0, (a, b) => a + b.qty);

  /// Active orders are still in progress; past = delivered/cancelled.
  bool get isActive => !{'DELIVERED', 'CANCELLED', 'PAYMENT_FAILED'}.contains(status);

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id']?.toString() ?? '',
        status: j['status']?.toString() ?? 'PLACED',
        paymentStatus: j['paymentStatus']?.toString() ?? 'PAID',
        fulfillment: j['fulfillment']?.toString() ?? 'delivery',
        grandTotal: (j['grandTotal'] as num?) ?? 0,
        itemTotal: (j['itemTotal'] as num?) ?? 0,
        discount: (j['discount'] as num?) ?? 0,
        deliveryFee: (j['deliveryFee'] as num?) ?? 0,
        taxesCharges: (j['taxesCharges'] as num?) ?? 0,
        couponCode: j['couponCode']?.toString(),
        handoffCode: j['handoffCode']?.toString(),
        addressLine1: j['addressLine1']?.toString(),
        addressArea: j['addressArea']?.toString(),
        receiverName: j['receiverName']?.toString(),
        receiverPhone: j['receiverPhone']?.toString(),
        createdAt: j['createdAt']?.toString(),
        kitchenName: j['kitchenName']?.toString(),
        items: (j['items'] as List?)
                ?.map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// Returned by the checkout step — the params the app feeds to Razorpay.
class CheckoutResult {
  const CheckoutResult({
    required this.orderId,
    required this.keyId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
  });
  final String orderId; // our backend order id
  final String keyId; // Razorpay public key
  final String razorpayOrderId;
  final int amount; // paise
  final String currency;

  factory CheckoutResult.fromJson(Map<String, dynamic> j) {
    final p = (j['payment'] as Map?)?.cast<String, dynamic>() ?? {};
    return CheckoutResult(
      orderId: j['orderId']?.toString() ?? '',
      keyId: p['keyId']?.toString() ?? '',
      razorpayOrderId: p['razorpayOrderId']?.toString() ?? '',
      amount: (p['amount'] as num?)?.toInt() ?? 0,
      currency: p['currency']?.toString() ?? 'INR',
    );
  }
}
