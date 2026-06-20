import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../widgets/inputs/app_text_field.dart';
import '../../../widgets/padosi/padosi_app_bar.dart';
import '../../../widgets/padosi/padosi_button.dart';
import '../../../widgets/padosi/padosi_cards.dart';
import 'location_result.dart';

/// Free-map location picker. Uses OpenStreetMap tiles (no API key) and
/// Nominatim for India-only search. Returns a [LocationResult].
class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key, this.initial});
  final LocationResult? initial;

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  // India centre — Hyderabad
  static const _defaultCenter = LatLng(17.385044, 78.486671);

  final _mapCtrl = MapController();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 450));

  late LatLng _center = widget.initial?.point ?? _defaultCenter;
  String _label = '—';
  String _detail = 'Fetching your location…';
  bool _resolving = false;
  bool _locating = false;

  List<_Suggestion> _results = [];
  bool _searching = false;
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      final hasFocus = _searchFocus.hasFocus;
      if (hasFocus != _searchActive) {
        setState(() => _searchActive = hasFocus);
      }
    });
    if (widget.initial != null) {
      _label = widget.initial!.label;
      _detail = widget.initial!.detail;
      _log('Re-opened picker with: $_label  ($_center)');
    } else {
      // Show default while we wait for GPS, then fetch.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _useCurrentLocation(),
      );
    }
  }

  void _log(String msg) {
    // ignore: avoid_print
    if (kDebugMode) print('[Location] $msg');
    developer.log(msg, name: 'Padosi.Location');
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  // ─────────────────── GPS ───────────────────

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _detail = 'Fetching your location…';
    });

    try {
      // 1. Is the OS location service even on?
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        _log('Location services are OFF on the device.');
        _showSnack('Turn on Location in your device settings.');
        setState(() {
          _locating = false;
          _detail = 'Location off — drag the map instead';
        });
        return;
      }

      // 2. Permission
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _log('Location permission denied: $perm');
        _showSnack(
          perm == LocationPermission.deniedForever
              ? 'Enable location for Padosi in app settings.'
              : 'Location permission denied.',
        );
        setState(() {
          _locating = false;
          _detail = 'Permission denied — drag the map';
        });
        return;
      }

      // 3. Actual fix
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final p = LatLng(pos.latitude, pos.longitude);
      _log(
        'GPS fix: lat=${pos.latitude}, lng=${pos.longitude}, '
        'accuracy=${pos.accuracy.toStringAsFixed(1)}m',
      );

      _center = p;
      _mapCtrl.move(p, 17);
      setState(() => _locating = false);

      // 4. Resolve to exact human address
      await _reverseGeocode(p);
    } on TimeoutException {
      _log('GPS timed out.');
      _showSnack('Couldn’t get location — try again outdoors.');
      setState(() {
        _locating = false;
        _detail = 'GPS timed out';
      });
    } catch (e) {
      _log('GPS error: $e');
      setState(() {
        _locating = false;
        _detail = 'Could not fetch location';
      });
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─────────────────── Nominatim ───────────────────

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': q,
        'format': 'json',
        'countrycodes': 'in',
        'addressdetails': '1',
        'limit': '8',
      });
      final resp = await http.get(
        uri,
        headers: {
          'User-Agent': 'PadosiApp/1.0 (contact: hello@padosi.app)',
          'Accept-Language': 'en-IN',
        },
      );
      if (resp.statusCode != 200) {
        setState(() => _searching = false);
        return;
      }
      final list = (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>();
      setState(() {
        _searching = false;
        _results = list.map(_Suggestion.fromNominatim).toList();
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  Future<void> _reverseGeocode(LatLng p) async {
    setState(() => _resolving = true);
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': p.latitude.toString(),
        'lon': p.longitude.toString(),
        'format': 'json',
        'addressdetails': '1',
        'zoom': '18', // street/building level
        'extratags': '1',
        'namedetails': '1',
      });
      final resp = await http.get(
        uri,
        headers: {
          'User-Agent': 'PadosiApp/1.0 (contact: hello@padosi.app)',
          'Accept-Language': 'en-IN',
        },
      );
      if (resp.statusCode != 200) {
        setState(() => _resolving = false);
        return;
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final addr = (body['address'] as Map?)?.cast<String, dynamic>() ?? {};

      // Build the most specific "primary" line we can.
      // Prefer: <house no> <road>, <suburb> → falls back through admin tiers.
      final houseNo = addr['house_number'] as String?;
      final road =
          (addr['road'] ??
                  addr['pedestrian'] ??
                  addr['footway'] ??
                  addr['cycleway'])
              as String?;
      final locality =
          (addr['suburb'] ??
                  addr['neighbourhood'] ??
                  addr['quarter'] ??
                  addr['residential'] ??
                  addr['hamlet'] ??
                  addr['village'] ??
                  addr['town'])
              as String?;
      final city =
          (addr['city'] ??
                  addr['town'] ??
                  addr['village'] ??
                  addr['state_district'])
              as String?;

      String label;
      if (road != null) {
        label = houseNo != null ? '$houseNo $road' : road;
        if (locality != null) label = '$label, $locality';
      } else if (locality != null) {
        label = locality;
      } else if (city != null) {
        label = city;
      } else {
        label = (body['name'] ?? 'Pinned location').toString();
      }

      final detailParts = <String>[
        if (road != null && locality != null) locality,
        if (city != null && city != locality) city,
        if (addr['state'] != null) addr['state'] as String,
        if (addr['postcode'] != null) addr['postcode'] as String,
        if (addr['country'] != null && addr['country_code'] != 'in')
          addr['country'] as String,
      ];
      final detail = detailParts.isEmpty
          ? (body['display_name'] ?? '').toString()
          : detailParts.join(', ');

      setState(() {
        _label = label;
        _detail = detail;
        _resolving = false;
      });

      _log('Reverse-geocoded ($p)');
      _log('  Label:  $label');
      _log('  Detail: $detail');
      _log('  Full:   ${body['display_name']}');
    } catch (e) {
      _log('Reverse geocode failed: $e');
      setState(() => _resolving = false);
    }
  }

  void _pickSuggestion(_Suggestion s) {
    setState(() {
      _label = s.label;
      _detail = s.detail;
      _center = s.point;
      _results = [];
      _searchCtrl.clear();
    });
    _searchFocus.unfocus();
    _mapCtrl.move(s.point, 15);
  }

  void _confirm() {
    final result = LocationResult(
      label: _label,
      detail: _detail,
      point: _center,
    );
    _log('CONFIRMED →');
    _log('  Label:  ${result.label}');
    _log('  Detail: ${result.detail}');
    _log('  Point:  ${result.point.latitude}, ${result.point.longitude}');
    Navigator.pop(context, result);
  }

  // ─────────────────── UI ───────────────────

  @override
  Widget build(BuildContext context) {
    // Suggestions are visible whenever the user is interacting with search.
    final showSuggestions =
        _searchActive ||
        _searching ||
        _results.isNotEmpty ||
        _searchCtrl.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PadosiAppBar(
        title: 'Choose delivery location',
        eyebrow: 'India only',
      ),
      body: Column(
        children: [
          // ── Search field (top) ──
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: AppTextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              hintText: 'Search area, street, landmark',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searching
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 14.r,
                        height: 14.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchCtrl.clear();
                        _searchFocus.unfocus();
                        setState(() => _results = []);
                      },
                    ),
              onChanged: (v) => _debouncer.run(() => _search(v)),
              textInputAction: TextInputAction.search,
            ),
          ),

          // ── Map + suggestion overlay ──
          Expanded(
            child: Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 14,
                    minZoom: 4,
                    maxZoom: 18,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: LatLngBounds(
                        const LatLng(6.5, 67.0),
                        const LatLng(36.0, 98.0),
                      ),
                    ),
                    onPositionChanged: (pos, hasGesture) {
                      if (hasGesture) _center = pos.center;
                    },
                    onMapEvent: (e) {
                      if (e is MapEventMoveEnd ||
                          e is MapEventFlingAnimationEnd) {
                        _debouncer.run(() => _reverseGeocode(_center));
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.padosi.app',
                      maxZoom: 19,
                    ),
                  ],
                ),
                // Centre pin
                IgnorePointer(
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -16),
                      child: Icon(
                        Icons.location_on,
                        size: 40.sp,
                        color: AppColors.primary,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Floating "current location" button
                Positioned(
                  right: 14.w,
                  bottom: 14.h,
                  child: _locating
                      ? Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.line),
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 14.r,
                            height: 14.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : PadosiIconBtn(
                          icon: Icons.my_location,
                          onTap: _useCurrentLocation,
                        ),
                ),
                // Resolved-label card
                Positioned(
                  left: 14.w,
                  right: 70.w,
                  bottom: 14.h,
                  child: PadosiCard(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _resolving ? 'Locating…' : _label,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFamily,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_detail.isNotEmpty)
                                Text(
                                  _detail,
                                  style: AppTextStyles.tiny,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Suggestion overlay (slides in when search is active)
                if (showSuggestions)
                  Positioned.fill(
                    child: GestureDetector(
                      // Tap on the dim outside to dismiss
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _searchFocus.unfocus(),
                      child: Container(
                        color: AppColors.background.withValues(alpha: .96),
                        child: _SuggestionList(
                          searching: _searching,
                          query: _searchCtrl.text,
                          results: _results,
                          onTap: _pickSuggestion,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: PadosiBottomBar(
        child: PadosiButton(
          label: 'Confirm location',
          icon: Icons.check_rounded,
          onPressed: _resolving ? null : _confirm,
        ),
      ),
    );
  }
}

// ─────────────────── helpers ───────────────────

class _Suggestion {
  const _Suggestion({
    required this.label,
    required this.detail,
    required this.point,
  });
  final String label;
  final String detail;
  final LatLng point;

  factory _Suggestion.fromNominatim(Map<String, dynamic> j) {
    final addr = (j['address'] as Map?)?.cast<String, dynamic>() ?? {};
    final label =
        addr['suburb'] ??
        addr['neighbourhood'] ??
        addr['village'] ??
        addr['town'] ??
        addr['city'] ??
        j['name'] ??
        (j['display_name'] as String).split(',').first;
    final detail = [
      addr['city'] ?? addr['town'] ?? addr['village'],
      addr['state'],
      addr['postcode'],
    ].whereType<String>().join(', ');
    return _Suggestion(
      label: label.toString(),
      detail: detail.isEmpty ? (j['display_name'] ?? '').toString() : detail,
      point: LatLng(
        double.parse(j['lat'].toString()),
        double.parse(j['lon'].toString()),
      ),
    );
  }
}

/// Suggestion list shown when the search field is active.
/// - Empty query → prompt "Start typing to search"
/// - Has query, searching → spinner
/// - Has results → tappable list of places
/// - Has query, no results → "No matches"
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.searching,
    required this.query,
    required this.results,
    required this.onTap,
  });
  final bool searching;
  final String query;
  final List<_Suggestion> results;
  final ValueChanged<_Suggestion> onTap;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return _Empty(
        icon: Icons.search_rounded,
        title: 'Start typing to search',
        body: 'Search for an area, street, or landmark in India.',
      );
    }
    if (searching && results.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 22.r,
                height: 22.r,
                child: const CircularProgressIndicator(strokeWidth: 2.2),
              ),
              SizedBox(height: 12.h),
              Text(
                'Searching India…',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      );
    }
    if (results.isEmpty) {
      return _Empty(
        icon: Icons.search_off_rounded,
        title: 'No matches',
        body: 'Try a different area or spelling.',
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final item = _LocationTile(s: results[i], onTap: onTap);
        if (i == results.length - 1) return item;
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: item,
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(20.r),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 28.sp, color: AppColors.muted),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTextStyles.displayFamily,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.tiny.copyWith(color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.s, required this.onTap});
  final _Suggestion s;
  final ValueChanged<_Suggestion> onTap;
  @override
  Widget build(BuildContext context) {
    return PadosiCard(
      padding: EdgeInsets.all(12.w),
      onTap: () => onTap(s),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(11.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.place_outlined,
              color: AppColors.primary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (s.detail.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      s.detail,
                      style: AppTextStyles.tiny,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.north_west, size: 16.sp, color: AppColors.muted),
        ],
      ),
    );
  }
}
