import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '../discover/_discover_widgets.dart';

/// Reusable scaffold for empty / error / waiting states.
/// Centered icon tile + title + body + 1 primary CTA + optional secondary CTA.
class StateScaffold extends StatelessWidget {
  const StateScaffold({
    super.key,
    this.title,
    required this.headline,
    required this.body,
    required this.iconChild,
    this.iconBg,
    this.iconShape = BoxShape.rectangle,
    this.iconRadius,
    this.iconColor,
    this.primaryLabel,
    this.onPrimary,
    this.primaryVariant = AuthBtnVariant.primary,
    this.secondaryLabel,
    this.onSecondary,
    this.showBack = false,
  });

  /// Optional app bar title; when null, no app bar is shown.
  final String? title;
  final String headline;
  final String body;

  /// What sits inside the centered icon tile (emoji string or Icon).
  final Widget iconChild;
  final Color? iconBg;
  final BoxShape iconShape;
  final double? iconRadius;
  final Color? iconColor;

  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final AuthBtnVariant primaryVariant;

  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (title != null)
              PlainAppBar(title: title!, showBack: showBack),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88.w,
                        height: 88.w,
                        decoration: BoxDecoration(
                          color: iconBg ?? AppColors.cream,
                          shape: iconShape,
                          borderRadius: iconShape == BoxShape.rectangle
                              ? BorderRadius.circular(iconRadius ?? 24.r)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 38.sp,
                            color: iconColor ?? AppColors.inkSoft,
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                              color: iconColor ?? AppColors.inkSoft,
                              size: 40.sp,
                            ),
                            child: iconChild,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Text(
                        headline,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -.4,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: 260.w,
                        child: Text(
                          body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: AppColors.inkSoft,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (primaryLabel != null || secondaryLabel != null)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                child: Column(
                  children: [
                    if (primaryLabel != null)
                      AuthButton(
                        label: primaryLabel!,
                        variant: primaryVariant,
                        onPressed: onPrimary,
                      ),
                    if (secondaryLabel != null) ...[
                      SizedBox(height: 10.h),
                      AuthButton(
                        label: secondaryLabel!,
                        variant: AuthBtnVariant.ghost,
                        onPressed: onSecondary,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
