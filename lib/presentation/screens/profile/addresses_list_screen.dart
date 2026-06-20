import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '../discover/_discover_widgets.dart';

/// Mockup 34 — Saved addresses (Profile entry).
class AddressesListScreen extends StatelessWidget {
  const AddressesListScreen({super.key});

  static const _items = <_Addr>[
    _Addr(
      icon: Icons.cottage_rounded,
      label: 'Home',
      detail: 'Flat 402, Brigade Towers, Koramangala',
    ),
    _Addr(
      icon: Icons.work_outline_rounded,
      label: 'Work',
      detail: 'WeWork, 5th Block',
    ),
  ];

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
                const PlainAppBar(title: 'Addresses'),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 100.h),
                    children: _items
                        .map(
                          (a) => Padding(
                            padding: EdgeInsets.only(bottom: 9.h),
                            child: _AddrRow(addr: a),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyBar(
              child: AuthButton(
                label: '+ Add address',
                variant: AuthBtnVariant.ghost,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Addr {
  const _Addr({required this.icon, required this.label, required this.detail});
  final IconData icon;
  final String label;
  final String detail;
}

class _AddrRow extends StatelessWidget {
  const _AddrRow({required this.addr});
  final _Addr addr;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(13.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(addr.icon, color: AppColors.inkSoft, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addr.label,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      addr.detail,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: AppColors.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Edit',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
