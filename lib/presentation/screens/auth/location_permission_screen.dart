import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '_auth_widgets.dart';

/// Mockup 07 — Location permission prompt (premium redesign).
///
/// Distinct from the login flow's image-and-sheet pattern. Instead:
///   · Soft cream → peach gradient backdrop.
///   · Animated radar — 3 concentric tangerine rings pulsing outward
///     from a centered location pin, evoking "scanning for cooks
///     nearby".
///   · Big editorial heading + short subtitle.
///   · 3 cream "trust" chips (🔒 private · ⚡ faster · 🏠 local).
///   · Tangerine Allow CTA + ghost "Enter manually" link.
class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});
  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _allow() async {
    setState(() => _loading = true);
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        _toast('Turn on Location in your device settings.');
        setState(() => _loading = false);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _toast(
          perm == LocationPermission.deniedForever
              ? 'Enable location for Padosi in app settings.'
              : 'Location permission denied.',
        );
        setState(() => _loading = false);
        return;
      }
      if (!mounted) return;
      _goHome();
    } catch (_) {
      _toast('Could not request location. Try again.');
      setState(() => _loading = false);
    }
  }

  void _manual() => _goHome();

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (_) => false);
  }

  void _toast(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(s), backgroundColor: AppColors.ink));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background gradient ──
          const _BackgroundDecor(),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 8.h, 0, 0),
                    child: Row(children: const [AuthBackButton()]),
                  ),

                  const Spacer(flex: 2),

                  // ── Radar / pin hero ──
                  _RadarPin(animation: _pulse),

                  SizedBox(height: 36.h),

                  // ── Headline ──
                  Text(
                    'Where shall we\ndeliver?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      height: 1.05,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: 300.w,
                    child: Text(
                      'Share your location so we can find home '
                      'chefs in your block and quote real delivery times.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        height: 1.55,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // ── Trust chips ──
                  const _TrustChips(),

                  const Spacer(flex: 3),

                  // ── CTAs ──
                  AuthButton(
                    label: 'Allow location',
                    icon: Icons.my_location_rounded,
                    loading: _loading,
                    onPressed: _loading ? null : _allow,
                  ),
                  SizedBox(height: 10.h),
                  // TextButton(
                  //   onPressed: _loading ? null : _manual,
                  //   style: TextButton.styleFrom(
                  //     foregroundColor: AppColors.ink,
                  //     padding: EdgeInsets.symmetric(vertical: 14.h),
                  //   ),
                  //   child: Text(
                  //     'Enter location manually',
                  //     style: GoogleFonts.spaceGrotesk(
                  //       fontSize: 13.sp,
                  //       fontWeight: FontWeight.w700,
                  //       color: AppColors.inkSoft,
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── background ─────────────────────────

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFFFEEDD), AppColors.background],
            stops: const [0, .6],
          ),
        ),
        child: Stack(
          children: [
            // Tangerine glow — top-right
            Positioned(
              top: -80.h,
              right: -60.w,
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: .18),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            // Mint glow — bottom-left
            Positioned(
              bottom: -100.h,
              left: -80.w,
              child: Container(
                width: 240.w,
                height: 240.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD8F0E0).withValues(alpha: .55),
                      const Color(0xFFD8F0E0).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── radar pin ─────────────────────────

/// Centered location pin with 3 concentric tangerine rings expanding
/// outward in a continuous pulse — visualizes "scanning for cooks
/// near you". Performant: just opacity + scale tweens, no canvas.
class _RadarPin extends StatelessWidget {
  const _RadarPin({required this.animation});
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220.w,
      height: 220.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Three rings staggered at 0 / .33 / .66 of the cycle.
          for (final delay in [0.0, .33, .66])
            _PulseRing(animation: animation, delay: delay),

          // Center white pin tile with map-pin glyph.
          Container(
            width: 84.w,
            height: 84.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .28),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 44.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.animation, required this.delay});
  final Animation<double> animation;
  final double delay;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        // Shift the cycle by `delay`, clamp into 0-1.
        final t = (animation.value + delay) % 1.0;
        final size = 84.w + (220.w - 84.w) * t;
        final opacity = (1 - t).clamp(0.0, 1.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: .08 * opacity),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: .35 * opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────── trust chips ─────────────────────────

class _TrustChips extends StatelessWidget {
  const _TrustChips();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _Chip(emoji: '🔒', label: 'Private'),
        _Gap(),
        _Chip(emoji: '⚡', label: 'Faster'),
        _Gap(),
        _Chip(emoji: '🏠', label: 'Local'),
      ],
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap();
  @override
  Widget build(BuildContext context) => SizedBox(width: 8.w);
}

class _Chip extends StatelessWidget {
  const _Chip({required this.emoji, required this.label});
  final String emoji;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 13.sp)),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
