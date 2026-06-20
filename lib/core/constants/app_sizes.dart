import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Scaled design tokens. All values are sized against the design canvas
/// declared in `ScreenUtilInit` (375 x 812). Use directly:
///   `padding: EdgeInsets.all(AppSizes.lg)`
///   `SizedBox(height: AppSizes.xxl)`
class AppSizes {
  AppSizes._();

  // Spacing — width-scaled where it's a horizontal/uniform gap,
  // height-scaled where it's clearly vertical rhythm.
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;

  // Radii
  static double get radiusSm => 6.r;
  static double get radiusMd => 10.r;
  static double get radiusLg => 14.r;
  static double get radiusXl => 20.r;
  static double get radiusPill => 999.r;

  // Icons
  static double get iconSm => 16.r;
  static double get iconMd => 20.r;
  static double get iconLg => 24.r;
  static double get iconXl => 32.r;

  // Component heights — vertical, so .h-scaled
  static double get buttonHeight => 52.h;
  static double get fieldHeight => 52.h;
  static double get appBarHeight => 56.h;
  static double get bottomNavHeight => 64.h;
}
