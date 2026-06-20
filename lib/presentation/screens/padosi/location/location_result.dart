import 'package:latlong2/latlong.dart';

/// Returned by SelectLocationScreen.pop().
class LocationResult {
  const LocationResult({
    required this.label,
    required this.detail,
    required this.point,
  });

  /// Short label, e.g. "Koramangala, Block 5".
  final String label;

  /// Longer secondary line, e.g. "Bengaluru, Karnataka 560034".
  final String detail;

  final LatLng point;
}
