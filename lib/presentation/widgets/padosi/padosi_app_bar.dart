import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/padosi_design.dart';
import 'padosi_button.dart';

/// Standard app bar for all stacked Padosi screens.
/// - Consistent 56dp height
/// - Optional eyebrow above title (e.g. "Step 1 of 4")
/// - Optional trailing icon button(s)
/// - Optional bottom hairline divider for screens with scrollable bodies
class PadosiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PadosiAppBar({
    super.key,
    this.title,
    this.eyebrow,
    this.showBack = true,
    this.onBack,
    this.actions = const [],
    this.divider = false,
    this.background,
  });

  final String? title;
  final String? eyebrow;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool divider;
  final Color? background;

  @override
  Size get preferredSize => Size.fromHeight(
        PadosiHeight.appBar + (divider ? 1 : 0),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: PadosiHeight.appBar,
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  if (showBack)
                    PadosiIconBtn(
                      icon: Icons.arrow_back,
                      onTap: onBack ?? () => Navigator.maybePop(context),
                    )
                  else
                    SizedBox(width: PadosiHeight.iconBtn),
                  SizedBox(width: 12.w),
                  Expanded(child: _Title(title: title, eyebrow: eyebrow)),
                  ...actions.map((a) => Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: a,
                      )),
                  SizedBox(width: 6.w),
                ],
              ),
            ),
          ),
          if (divider)
            Divider(height: 1, color: AppColors.line),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({this.title, this.eyebrow});
  final String? title;
  final String? eyebrow;
  @override
  Widget build(BuildContext context) {
    if (title == null && eyebrow == null) return const SizedBox.shrink();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null)
          Text(
            eyebrow!,
            style: AppTextStyles.tiny.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        if (title != null)
          Text(
            title!,
            style: AppTextStyles.h3,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
