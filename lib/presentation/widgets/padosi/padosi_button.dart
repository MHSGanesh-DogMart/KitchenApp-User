import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';

/// Single full-width action button used across Padosi screens.
/// Variants:
///   coral   — primary CTA (default)
///   ink     — dark CTA (used on Become Chef)
///   ghost   — neutral outlined CTA
class PadosiButton extends StatelessWidget {
  const PadosiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = PadosiButtonVariant.coral,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PadosiButtonVariant variant;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    final (bg, fg, border) = switch (variant) {
      PadosiButtonVariant.coral => (AppColors.primary, Colors.white, null),
      PadosiButtonVariant.ink => (AppColors.ink, Colors.white, null),
      PadosiButtonVariant.ghost => (
          AppColors.surface,
          AppColors.ink,
          AppColors.line,
        ),
    };

    final radius = BorderRadius.circular(AppSizes.radiusLg);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: disabled && !loading ? .55 : 1,
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: disabled ? null : onPressed,
          splashColor: Colors.white.withValues(alpha: .15),
          highlightColor: Colors.white.withValues(alpha: .08),
          child: Container(
            height: AppSizes.buttonHeight,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: border == null ? null : Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: loading
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: fg, size: 18.sp),
                        SizedBox(width: 8.w),
                      ],
                      Text(label,
                          style: AppTextStyles.button.copyWith(color: fg)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

enum PadosiButtonVariant { coral, ink, ghost }

/// Sticky bottom bar wrapper — soft top divider, safe-area aware,
/// matches the white-translucent treatment from the mockups.
class PadosiBottomBar extends StatelessWidget {
  const PadosiBottomBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16181D).withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
          child: child,
        ),
      ),
    );
  }
}

/// Small circular icon button (used in app bars + hero overlays).
class PadosiIconBtn extends StatelessWidget {
  const PadosiIconBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.hasDot = false,
    this.dark = false,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final bool hasDot;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: dark ? Colors.white.withValues(alpha: .12) : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.r),
            side: dark
                ? BorderSide.none
                : const BorderSide(color: AppColors.line),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(13.r),
            onTap: onTap,
            child: SizedBox(
              width: 38.w,
              height: 38.w,
              child: Icon(
                icon,
                color: dark ? Colors.white : AppColors.ink,
                size: 18.sp,
              ),
            ),
          ),
        ),
        if (hasDot)
          Positioned(
            top: 8,
            right: 9,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: dark ? AppColors.ink : AppColors.surface,
                  width: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Reusable section header row: title + optional trailing link.
class PadosiSectionHeader extends StatelessWidget {
  const PadosiSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
    this.padding,
  });
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(title, style: AppTextStyles.h3),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: Text(
                trailing!,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFamily,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
