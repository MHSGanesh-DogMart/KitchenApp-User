import 'package:latlong2/latlong.dart';

/// Returned by SelectLocationScreen.pop().
class LocationResult {
  const LocationResult({
    required this.label,
    required this.detail,
    required this.point,
    this.building,
    this.road,
    this.area,
    this.city,
    this.state,
    this.pincode,
  });

  /// Short label, e.g. "Ramky One Harmony" (building) or "Koramangala".
  final String label;

  /// Longer secondary line, e.g. "Bengaluru, Karnataka 560034".
  final String detail;

  final LatLng point;

  // Structured parts (from reverse-geocode) used to prefill address fields.
  final String? building; // POI / apartment / building name
  final String? road;
  final String? area; // suburb / neighbourhood / locality
  final String? city;
  final String? state;
  final String? pincode;
}
