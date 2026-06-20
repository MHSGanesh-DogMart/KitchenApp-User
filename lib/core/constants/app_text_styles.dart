import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Padosi typography — "Bold & Fresh".
///   Display = Space Grotesk (geometric, bold)
///   Body    = Inter (clean, neutral)
/// Loaded via google_fonts so no .ttf bundling needed.
class AppTextStyles {
  AppTextStyles._();

  static const String displayFamily = 'Space Grotesk';
  static const String bodyFamily = 'Inter';
  static const String fontFamily = bodyFamily; // back-compat

  // ── Display (Space Grotesk) ──
  static TextStyle get display => GoogleFonts.spaceGrotesk(
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.6,
        height: 1.0,
        color: AppColors.ink,
      );

  static TextStyle get h1 => GoogleFonts.spaceGrotesk(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -.8,
        height: 1.05,
        color: AppColors.ink,
      );

  static TextStyle get h2 => GoogleFonts.spaceGrotesk(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -.5,
        color: AppColors.ink,
      );

  static TextStyle get h3 => GoogleFonts.spaceGrotesk(
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -.3,
        color: AppColors.ink,
      );

  // ── Body (Inter) ──
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: 1.5,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: 1.5,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.inkSoft,
        height: 1.45,
      );

  static TextStyle get tiny => GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        height: 1.4,
      );

  static TextStyle get button => GoogleFonts.spaceGrotesk(
        fontSize: 14.5.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0,
      );

  static TextStyle get label => GoogleFonts.spaceGrotesk(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
        letterSpacing: 1.3,
      );

  static TextStyle get hint => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
      );

  static TextStyle get price => GoogleFonts.spaceGrotesk(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  static TextStyle get errorText => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      );
}
