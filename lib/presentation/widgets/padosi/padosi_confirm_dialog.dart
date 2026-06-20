import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Shared confirmation dialog — single source of truth for any
/// "Are you sure?" prompt. Used for Logout, Delete Account, Cancel
/// Order, Remove from wishlist, etc.
///
/// Visual recipe:
///   · 24r white card centred over a dim scrim.
///   · 56×56 tinted icon tile at top (color tracks [destructive]).
///   · Bold Space Grotesk title + Inter body.
///   · Stacked CTAs: filled primary (Confirm) + ghost (Cancel).
///   · `destructive: true` flips the Confirm pill + icon tile to
///     `AppColors.error` so destructive actions read clearly.
///
/// Returns `true` if the user confirmed, `false` / `null` otherwise.
///
/// ```dart
/// final ok = await PadosiConfirmDialog.show(
///   context,
///   icon: Icons.logout_rounded,
///   title: 'Log out?',
///   message: "You'll need to enter your OTP again to sign back in.",
///   confirmLabel: 'Log out',
/// );
/// ```
class PadosiConfirmDialog extends StatelessWidget {
  const PadosiConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.confirmLabel = 'Yes',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  /// Convenience static — shows the dialog and returns the user's
  /// choice. `true` = confirmed, `false`/`null` = cancelled / dismissed.
  static Future<bool?> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String confirmLabel = 'Yes',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .45),
      builder: (_) => PadosiConfirmDialog(
        icon: icon,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.error : AppColors.primary;
    final accentSoft = destructive
        ? AppColors.error.withValues(alpha: .12)
        : AppColors.primarySoft;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: .18),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon tile
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(18.r),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accent, size: 26.sp),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -.4,
                height: 1.2,
              ),
            ),
            SizedBox(height: 8.h),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.inkSoft,
                height: 1.5,
              ),
            ),
            SizedBox(height: 22.h),

            // Confirm
            SizedBox(
              width: double.infinity,
              child: Material(
                color: accent,
                borderRadius: BorderRadius.circular(14.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Text(
                      confirmLabel,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Cancel (ghost)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    height: 44.h,
                    alignment: Alignment.center,
                    child: Text(
                      cancelLabel,
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.inkSoft,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
