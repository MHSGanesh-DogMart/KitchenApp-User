// Customer saved delivery address — mirrors the backend Address model.
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.lat,
    required this.lng,
    this.receiverName,
    this.receiverPhone,
    this.landmark,
    this.area,
    this.city,
    this.pincode,
    this.isDefault = false,
  });

  final String id;
  final String label; // Home | Work | Other
  final String line1;
  final double lat;
  final double lng;
  final String? receiverName;
  final String? receiverPhone;
  final String? landmark;
  final String? area;
  final String? city;
  final String? pincode;
  final bool isDefault;

  /// One-line summary for the cart's address row.
  String get summary {
    final parts = [line1, if (landmark?.isNotEmpty ?? false) landmark, area, city]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id']?.toString() ?? '',
        label: j['label']?.toString() ?? 'Home',
        line1: j['line1']?.toString() ?? '',
        lat: (j['lat'] as num?)?.toDouble() ?? 0,
        lng: (j['lng'] as num?)?.toDouble() ?? 0,
        receiverName: j['receiverName']?.toString(),
        receiverPhone: j['receiverPhone']?.toString(),
        landmark: j['landmark']?.toString(),
        area: j['area']?.toString(),
        city: j['city']?.toString(),
        pincode: j['pincode']?.toString(),
        isDefault: j['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'line1': line1,
        'lat': lat,
        'lng': lng,
        if (receiverName != null) 'receiverName': receiverName,
        if (receiverPhone != null) 'receiverPhone': receiverPhone,
        if (landmark != null) 'landmark': landmark,
        if (area != null) 'area': area,
        if (city != null) 'city': city,
        if (pincode != null) 'pincode': pincode,
        'isDefault': isDefault,
      };
}
