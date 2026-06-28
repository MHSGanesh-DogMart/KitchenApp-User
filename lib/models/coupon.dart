// Coupon shown in the Offers screen — mirrors the backend Coupon model.
class Coupon {
  const Coupon({
    required this.code,
    required this.description,
    required this.type,
    required this.value,
  });

  final String code;
  final String description;
  final String type; // "flat" | "percent" | "free_delivery"
  final num value;

  /// Short benefit line, e.g. "₹50 off" / "20% off" / "Free delivery".
  String get benefit {
    switch (type) {
      case 'flat':
        return '₹${value.round()} off';
      case 'percent':
        return '${value.round()}% off';
      case 'free_delivery':
        return 'Free delivery';
      default:
        return description;
    }
  }

  factory Coupon.fromJson(Map<String, dynamic> j) => Coupon(
        code: j['code']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        type: j['type']?.toString() ?? 'flat',
        value: (j['value'] as num?) ?? 0,
      );
}
