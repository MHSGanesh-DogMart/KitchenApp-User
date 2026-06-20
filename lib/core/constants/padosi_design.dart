import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Padosi design tokens — single source of truth for spacing, radii,
/// elevation, and motion. Reuse instead of hard-coding values in screens.
///
/// Scale rationale:
///   4 / 8 / 12 / 16 / 20 / 24 / 32  — Material's 4pt grid, but trimmed
///   to the rhythms used in the mockups. All sizes width-scaled via .w/.h
///   through flutter_screenutil so they respect the 375×812 canvas.
class PadosiSpace {
  PadosiSpace._();

  // Horizontal padding inside scrollable content
  static double get screenH => 16.w;

  // Compact / standard / generous vertical gaps
  static double get xs => 4.h;
  static double get sm => 8.h;
  static double get md => 12.h;
  static double get lg => 16.h;
  static double get xl => 20.h;
  static double get xxl => 24.h;
  static double get xxxl => 32.h;

  // Standard rhythm BETWEEN sections (header + content + header + content)
  static double get sectionTop => 22.h;
  static double get sectionBottom => 12.h;

  // Bottom padding for screens that have a sticky bar
  static double get bottomBarSpacer => 110.h;
}

class PadosiRadius {
  PadosiRadius._();
  static double get xs => 6.r;
  static double get sm => 10.r;
  static double get md => 14.r;   // chips on filled rows / search field
  static double get lg => 16.r;   // buttons + sticky bars
  static double get xl => 18.r;   // cards
  static double get xxl => 22.r;  // hero shapes
  static double get pill => 999.r;
}

/// Pre-built BoxShadow tiers for cards/sheets/bars.
class PadosiElevation {
  PadosiElevation._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: const Color(0xFF16181D).withValues(alpha: .04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: const Color(0xFF16181D).withValues(alpha: .05),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: const Color(0xFF16181D).withValues(alpha: .08),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// Used above the sticky bottom bar (shadow points up).
  static List<BoxShadow> get bottomBar => [
        BoxShadow(
          color: const Color(0xFF16181D).withValues(alpha: .05),
          blurRadius: 18,
          offset: const Offset(0, -6),
        ),
      ];
}

class PadosiMotion {
  PadosiMotion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Curve curve = Curves.easeOutCubic;
}

/// Pre-styled gradient palettes used for cook/dish hero tiles.
class PadosiGradients {
  PadosiGradients._();
  static const coral = [Color(0xFFFFE3D2), Color(0xFFFFD0B8)];
  static const gold = [Color(0xFFFBEFD9), Color(0xFFF0E4C2)];
  static const teal = [Color(0xFFE2F0ED), Color(0xFFCFE8E2)];
  static const green = [Color(0xFFE6F2E9), Color(0xFFCFE8D6)];
  static const violet = [Color(0xFFFCE7E1), Color(0xFFDED5F0)];

  /// Dark hero gradient used on Cook Detail header + Onboarding.
  static const darkHero = [Color(0xFF23262F), Color(0xFF18211B)];
}

/// Pre-sized icon scale (use these instead of raw .sp values inside
/// icon buttons / status rows for visual consistency).
class PadosiIcon {
  PadosiIcon._();
  static double get xs => 14.sp;
  static double get sm => 16.sp;
  static double get md => 18.sp;
  static double get lg => 22.sp;
  static double get xl => 28.sp;
}

/// Standard component heights.
class PadosiHeight {
  PadosiHeight._();
  static double get button => 52.h;
  static double get field => 52.h;
  static double get appBar => 56.h;
  static double get bottomNav => 64.h;
  static double get iconBtn => 38.w;
  static double get filterChipRow => 38.h;
}

/// Brand-themed border helper for selected/idle states.
ShapeBorder padosiCardShape({Color? color, double width = 1}) =>
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PadosiRadius.xl),
      side: BorderSide(color: color ?? AppColors.line, width: width),
    );
