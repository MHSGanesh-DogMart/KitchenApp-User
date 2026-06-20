import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../widgets/inputs/app_text_field.dart';
import '_auth_widgets.dart';

/// Mockup 08 — Saved addresses + add new.
///
/// Premium polish — same hero header DNA + uppercase kickers as the
/// rest of the app. Sections:
///   1. Search pill → opens the map picker.
///   2. Use-current-location card (tangerine-soft border).
///   3. SAVED kicker + saved address rows.
///   4. ADD NEW kicker + 4-field card.
///   5. Sticky tangerine "Save address" CTA.
class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});
  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final _house = TextEditingController(text: '402');
  final _building = TextEditingController(text: 'Brigade Towers');
  final _label = TextEditingController(text: 'Home');
  final _pincode = TextEditingController(text: '560095');

  static const _saved = <_AddressItem>[
    _AddressItem(
      icon: Icons.cottage_rounded,
      label: 'Home',
      detail: 'Flat 402, Brigade Towers · Koramangala 5th Block',
      isDefault: true,
    ),
    _AddressItem(
      icon: Icons.work_outline_rounded,
      label: 'Work',
      detail: 'WeWork, 5th Block · Koramangala',
    ),
  ];

  @override
  void dispose() {
    _house.dispose();
    _building.dispose();
    _label.dispose();
    _pincode.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pushReplacementNamed(context, RouteNames.home);
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
                    padding:
                        EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 110.h),
                    children: [
                      // ── Search pill ──
                      _SearchPill(
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouteNames.selectLocation,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // ── Use current location ──
                      _CurrentLocationCard(
                        onUse: () => Navigator.pushNamed(
                          context,
                          RouteNames.selectLocation,
                        ),
                      ),

                      SizedBox(height: 22.h),

                      // ── Saved ──
                      _Kicker('SAVED'),
                      SizedBox(height: 10.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < _saved.length; i++) ...[
                              _SavedRow(item: _saved[i]),
                              if (i < _saved.length - 1)
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 14.w),
                                  child: Divider(
                                      height: 1, color: AppColors.line),
                                ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 22.h),

                      // ── Add new ──
                      _Kicker('ADD NEW ADDRESS'),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          children: [
                            _LabeledField(
                              label: 'HOUSE / FLAT NO.',
                              controller: _house,
                              isHouse: true,
                              focused: true,
                            ),
                            SizedBox(height: 10.h),
                            _LabeledField(
                              label: 'BUILDING / STREET',
                              controller: _building,
                              isApartment: true,
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _LabeledField(
                                    label: 'LABEL',
                                    controller: _label,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _LabeledField(
                                    label: 'PINCODE',
                                    controller: _pincode,
                                    isPincode: true,
                                  ),
                                ),
                              ],
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

          // ── Sticky CTA ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border(top: BorderSide(color: AppColors.line, width: 1)),
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
                        'Save address',
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
                  'Delivery address',
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
                  'Where shall we deliver?',
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

// ─────────────────────── search pill ───────────────────

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  size: 19.sp, color: AppColors.inkSoft),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Search area, street, landmark',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  'Map',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── current location ──────────────

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.onUse});
  final VoidCallback onUse;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onUse,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: .35)),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.my_location_rounded,
                    color: AppColors.primary, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use current location',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Koramangala, Bengaluru',
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 11.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  'Use',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── saved row ───────────────────────

class _AddressItem {
  const _AddressItem({
    required this.icon,
    required this.label,
    required this.detail,
    this.isDefault = false,
  });
  final IconData icon;
  final String label;
  final String detail;
  final bool isDefault;
}

class _SavedRow extends StatelessWidget {
  const _SavedRow({required this.item});
  final _AddressItem item;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pushReplacementNamed(
          context,
          RouteNames.home,
        ),
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
                child: Icon(item.icon,
                    color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.label,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -.2,
                          ),
                        ),
                        if (item.isDefault) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(99.r),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkSoft,
                                letterSpacing: .8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      item.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.muted, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── labeled field ──────────────────

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.focused = false,
    this.isHouse = false,
    this.isApartment = false,
    this.isPincode = false,
  });
  final String label;
  final TextEditingController controller;
  final bool focused;
  final bool isHouse;
  final bool isApartment;
  final bool isPincode;

  @override
  Widget build(BuildContext context) {
    final borderColor = focused ? AppColors.primary : AppColors.line;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: borderColor, width: focused ? 1.5 : 1),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .12),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 1.1,
            ),
          ),
          AppTextField(
            controller: controller,
            isHouseNumber: isHouse,
            isApartment: isApartment,
            isPincode: isPincode,
          ),
        ],
      ),
    );
  }
}
