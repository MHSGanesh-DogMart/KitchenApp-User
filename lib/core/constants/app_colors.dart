import 'package:flutter/material.dart';

/// Padosi — "Bold & Fresh" palette.
/// Crisp neutral canvas, punchy tangerine primary, emerald for verified.
/// Semantics:
///   primary (tangerine) = action & accent
///   accent  (emerald)   = verified / FSSAI / fresh
///   tier1   (gold)      = Tier 1 Home Chef
///   ink (near-black)    = primary text + floating nav
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFFF5630); // tangerine
  static const Color primaryDark = Color(0xFFE0431F);
  static const Color primarySoft = Color(0xFFFFE7DF);

  // Secondary (verification / fresh)
  static const Color secondary = Color(0xFF0F7B5A); // emerald
  static const Color secondarySoft = Color(0xFFE1F2EC);

  // Tier colors
  static const Color tier1 = Color(0xFFB7791F); // amber-gold
  static const Color tier1Soft = Color(0xFFFBEFD7);
  static const Color tier2 = Color(0xFF0F7B5A); // same as secondary
  static const Color tier2Soft = Color(0xFFE1F2EC);

  // Trust signals
  static const Color fresh = Color(0xFF18A957);
  static const Color freshSoft = Color(0xFFE1F2EC);
  static const Color violet = Color(0xFFE5484D); // alert / error tone
  static const Color violetSoft = Color(0xFFFBE7E8);

  // Neutrals
  static const Color ink = Color(0xFF16150F); // primary text + nav
  static const Color inkSoft = Color(0xFF5C5C54); // secondary text
  static const Color muted = Color(0xFF9A9A90); // meta / hint
  static const Color line = Color(0xFFE4E4DD); // borders
  static const Color cream = Color(0xFFEFEFEA); // soft surface
  static const Color background = Color(0xFFF6F6F6); // app canvas
  static const Color surface = Color(0xFFFFFFFF); // cards

  // Legacy aliases (keeps existing screens compiling)
  static const Color textPrimary = ink;
  static const Color textSecondary = inkSoft;
  static const Color textHint = muted;
  static const Color border = line;
  static const Color divider = line;
  static const Color success = fresh;
  static const Color error = Color(0xFFE5484D);
  static const Color warning = Color(0xFFF5A623);
  static const Color info = secondary;

  // Dark
  static const Color darkBackground = ink;
  static const Color darkSurface = Color(0xFF23231D);
  static const Color darkTextPrimary = background;
  static const Color darkTextSecondary = Color(0xFFCBCBC0);
  static const Color darkBorder = Color(0xFF2D2D26);
}
