import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';

/// Edit Profile — premium polish.
///
///   1. Standard hero header (white-circle back button + title +
///      subtitle).
///   2. Avatar block — tappable circle with floating tangerine camera
///      badge to change picture. Local image_picker for camera /
///      gallery.
///   3. Form: NAME · MOBILE NUMBER · EMAIL · BIRTHDAY (date picker).
///   4. Sticky tangerine "Save changes" CTA.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController(text: 'Hemanth Reddy');
  final _phone = TextEditingController(text: '93915 81008');
  final _email = TextEditingController(text: 'hemanth@mtouchlabs.com');
  DateTime? _dob = DateTime(1998, 7, 14);
  String? _avatarPath;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(),
    );
    if (source == null) return;
    try {
      final x = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (x != null && mounted) {
        setState(() => _avatarPath = x.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not load image'),
            backgroundColor: AppColors.ink,
          ),
        );
      }
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            onSurface: AppColors.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  String get _dobText {
    final d = _dob;
    if (d == null) return 'Select your birthday';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _save() {
    Navigator.maybePop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated'),
        backgroundColor: AppColors.ink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 110.h),
                    children: [
                      // ── Avatar block ──
                      Center(
                        child: _AvatarPicker(
                          avatarPath: _avatarPath,
                          initials: _initials(_name.text),
                          onTap: _pickAvatar,
                        ),
                      ),
                      SizedBox(height: 22.h),

                      // ── Fields ──
                      _Kicker('FULL NAME'),
                      SizedBox(height: 8.h),
                      _Field(
                        controller: _name,
                        hint: 'Your full name',
                        capitalize: true,
                      ),

                      SizedBox(height: 16.h),

                      _Kicker('MOBILE NUMBER'),
                      SizedBox(height: 8.h),
                      _Field(
                        controller: _phone,
                        hint: '98xxxxxxxx',
                        prefix: '+91',
                        isMobile: true,
                        enabled: false,
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: AppColors.success,
                                size: 12.sp,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Verified',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      _Kicker('EMAIL'),
                      SizedBox(height: 8.h),
                      _Field(
                        controller: _email,
                        hint: 'you@example.com',
                        isEmail: true,
                      ),

                      SizedBox(height: 16.h),

                      _Kicker('BIRTHDAY'),
                      SizedBox(height: 8.h),
                      _DateField(
                        valueText: _dobText,
                        empty: _dob == null,
                        onTap: _pickDob,
                      ),

                      SizedBox(height: 18.h),

                      // Little perk hint
                      _BirthdayHint(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky CTA ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.line, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: .06),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
              child: SafeArea(
                top: false,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: _save,
                    child: Container(
                      height: 50.h,
                      alignment: Alignment.center,
                      child: Text(
                        'Save changes',
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
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
      .join();
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
                  'Edit profile',
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
                  'Your details, your way',
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

// ─────────────────────── kicker ───────────────────────

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

// ─────────────────────── avatar picker ──────────────────

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.avatarPath,
    required this.initials,
    required this.onTap,
  });
  final String? avatarPath;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 108.w,
          height: 108.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: avatarPath == null
              ? Text(
                  initials.isEmpty ? 'P' : initials,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.5,
                  ),
                )
              : ClipOval(
                  child: Image.file(
                    File(avatarPath!),
                    width: 108.w,
                    height: 108.w,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: AppColors.ink,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────── field ───────────────────────

/// Cream pill field — same recipe as the login screen mobile number
/// row. No border, just cream fill, 52h, 16w internal padding. Used
/// everywhere a single-line input is needed.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.prefix,
    this.trailing,
    this.isMobile = false,
    this.isEmail = false,
    this.capitalize = false,
    this.enabled = true,
  });
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final Widget? trailing;
  final bool isMobile;
  final bool isEmail;
  final bool capitalize;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          if (prefix != null) ...[
            Text(
              prefix!,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            SizedBox(width: 10.w),
            Container(width: 1, height: 22.h, color: AppColors.line),
            SizedBox(width: 10.w),
          ],
          Expanded(
            // child: AppTextField(
            //   controller: controller,
            //   hintText: hint,
            //   isEditable: enabled,
            //   isMobile: isMobile,
            //   isEmail: isEmail,
            //   textCapitalization:
            //       capitalize ? TextCapitalization.words : null,
            // ),
            child: TextFormField(
              controller: controller,
              // focusNode: focusNode,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.primary,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: .3,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  // color: AppColors.muted,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ─────────────────────── date field ─────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.valueText,
    required this.empty,
    required this.onTap,
  });
  final String valueText;
  final bool empty;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          alignment: Alignment.center,
          child: Row(
            children: [
              Icon(Icons.cake_rounded, color: AppColors.ink, size: 18.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  valueText,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: empty ? AppColors.muted : AppColors.ink,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.muted,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── birthday hint ──────────────────

class _BirthdayHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('🎂', style: TextStyle(fontSize: 18.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Tell us your birthday and we will send a free '
              'meal coupon every year — on us.',
              style: GoogleFonts.inter(
                fontSize: 11.5.sp,
                color: AppColors.primary,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── picker sheet ───────────────────

class _PickerSheet extends StatelessWidget {
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
                'Update photo',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -.3,
                ),
              ),
              SizedBox(height: 14.h),
              _PickRow(
                icon: Icons.photo_camera_rounded,
                label: 'Take a photo',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              SizedBox(height: 8.h),
              _PickRow(
                icon: Icons.photo_library_rounded,
                label: 'Choose from gallery',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary, size: 19.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
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
