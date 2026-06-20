import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../widgets/padosi/padosi_confirm_dialog.dart';
import '../auth/_auth_widgets.dart';

/// Mockup 38 — Settings (premium polish).
///
/// Standard hero header + section kickers + 20r grouped cards. Every
/// row has a 36×36 tinted icon tile, ink title, optional sub, and a
/// chevron or trailing widget. Toggles use a custom animated pill.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _push = true;
  bool _orderUpdates = true;
  bool _offers = false;
  String _theme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                children: [
                  // ── Notifications ──
                  _Kicker('NOTIFICATIONS'),
                  SizedBox(height: 10.h),
                  _Group([
                    _ToggleRow(
                      icon: Icons.notifications_active_outlined,
                      tint: AppColors.primary,
                      title: 'Push notifications',
                      sub: 'Allow Padosi to send notifications',
                      value: _push,
                      onChanged: (v) => setState(() => _push = v),
                    ),
                    _ToggleRow(
                      icon: Icons.local_shipping_outlined,
                      tint: AppColors.secondary,
                      title: 'Order updates',
                      sub: "Cooking, ready, on the way",
                      value: _orderUpdates,
                      onChanged: (v) => setState(() => _orderUpdates = v),
                    ),
                    _ToggleRow(
                      icon: Icons.local_offer_outlined,
                      tint: AppColors.success,
                      title: 'Offers & promos',
                      sub: 'Coupons, free delivery days',
                      value: _offers,
                      onChanged: (v) => setState(() => _offers = v),
                    ),
                  ]),

                  SizedBox(height: 22.h),

                  // ── Support ──
                  _Kicker('SUPPORT & LEGAL'),
                  SizedBox(height: 10.h),
                  _Group([
                    _IconRow(
                      icon: Icons.shield_outlined,
                      tint: AppColors.secondary,
                      title: 'Privacy policy',
                      onTap: () {},
                    ),
                    _IconRow(
                      icon: Icons.description_outlined,
                      tint: AppColors.inkSoft,
                      title: 'Terms of service',
                      onTap: () {},
                    ),
                    _IconRow(
                      icon: Icons.info_outline_rounded,
                      tint: AppColors.muted,
                      title: 'About Padosi',
                      sub: 'Version 1.0.0',
                      onTap: () {},
                    ),
                    _IconRow(
                      icon: Icons.delete_outline_rounded,
                      tint: AppColors.error,
                      title: 'Delete account',
                      titleColor: AppColors.error,
                      onTap: _confirmDelete,
                    ),
                  ]),

                  SizedBox(height: 24.h),

                  // ── Footer ──
                  Center(
                    child: Column(
                      children: [
                        Text('🏠', style: TextStyle(fontSize: 22.sp)),
                        SizedBox(height: 6.h),
                        Text(
                          'Padosi · v1.0.0',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                            letterSpacing: .3,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Made with ❤ for real home food',
                          style: GoogleFonts.inter(
                            fontSize: 10.5.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTheme() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThemeSheet(selected: _theme),
    );
    if (picked != null) setState(() => _theme = picked);
  }

  Future<void> _confirmDelete() async {
    final ok = await PadosiConfirmDialog.show(
      context,
      icon: Icons.delete_forever_rounded,
      title: 'Delete your account?',
      message:
          "This is permanent. Your orders, wishlist, reviews and saved "
          "addresses will be removed. There's no undo.",
      confirmLabel: 'Yes, delete account',
      destructive: true,
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account deletion request sent'),
          backgroundColor: AppColors.ink,
        ),
      );
    }
  }
}

// ─────────────────────── header ───────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 20.w, 10.h),
      child: Row(
        children: [
          const AuthBackButton(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.5,
                    color: AppColors.ink,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tune the app to your taste',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── kicker + group ───────────────────

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: 4.w),
    child: Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group(this.rows);
  final List<Widget> rows;
  @override
  Widget build(BuildContext context) {
    final out = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      out.add(rows[i]);
      if (i < rows.length - 1) {
        out.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Divider(height: 1, color: AppColors.line),
          ),
        );
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(children: out),
    );
  }
}

// ─────────────────────── icon row ───────────────────────

class _IconRow extends StatelessWidget {
  const _IconRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.onTap,
    this.sub,
    this.trailing,
    this.titleColor,
  });
  final IconData icon;
  final Color tint;
  final String title;
  final VoidCallback onTap;
  final String? sub;
  final Widget? trailing;
  final Color? titleColor;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19.sp, color: tint),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor ?? AppColors.ink,
                        letterSpacing: -.2,
                      ),
                    ),
                    if (sub != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        sub!,
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                  size: 20.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── toggle row ─────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final Color tint;
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(11.r),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 19.sp, color: tint),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _PillSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _PillSwitch extends StatelessWidget {
  const _PillSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 46.w,
        height: 26.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.line,
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: Row(
          mainAxisAlignment: value
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── value pill ─────────────────────

class _ValuePill extends StatelessWidget {
  const _ValuePill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(99.r),
          ),
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20.sp),
      ],
    );
  }
}

// ─────────────────────── theme sheet ────────────────────

class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet({required this.selected});
  final String selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'App theme',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -.3,
                ),
              ),
              SizedBox(height: 14.h),
              _ThemeOption(
                label: 'Light',
                sub: 'Cream surfaces, ink type',
                icon: Icons.light_mode_rounded,
                value: 'Light',
                selected: selected == 'Light',
              ),
              SizedBox(height: 8.h),
              _ThemeOption(
                label: 'Dark',
                sub: 'Easier on the eyes at night',
                icon: Icons.dark_mode_rounded,
                value: 'Dark',
                selected: selected == 'Dark',
              ),
              SizedBox(height: 8.h),
              _ThemeOption(
                label: 'System',
                sub: 'Matches your phone setting',
                icon: Icons.brightness_auto_rounded,
                value: 'System',
                selected: selected == 'System',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.sub,
    required this.icon,
    required this.value,
    required this.selected,
  });
  final String label;
  final String sub;
  final IconData icon;
  final String value;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: selected ? AppColors.primary : AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => Navigator.pop(context, value),
        child: Padding(
          padding: EdgeInsets.all(13.w),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.ink,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sub,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
