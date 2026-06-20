import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '_discover_widgets.dart';

/// Mockup 19 — Payment method.
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});
  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String _selected = 'UPI · PhonePe';

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
                const PlainAppBar(title: 'Payment'),
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 110.h),
                    children: [
                      _Kicker('UPI'),
                      SizedBox(height: 10.h),
                      CardGroup(children: [
                        _payRow('UPI · PhonePe', '📱'),
                        _payRow('UPI · Google Pay', '💰'),
                        _payRow('UPI · Other', '🏦'),
                      ]),
                      SizedBox(height: 18.h),
                      _Kicker('More'),
                      SizedBox(height: 10.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          children: [
                            _morePay(Icons.credit_card_rounded, 'Add card', null),
                            Divider(
                                height: 1,
                                indent: 15.w,
                                endIndent: 15.w,
                                color: AppColors.line),
                            _morePay(
                              Icons.payments_rounded,
                              'Cash on pickup only',
                              'Delivery is prepaid',
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyBar(
              child: AuthButton(
                label: 'Use ${_selected.split(' · ').last}',
                onPressed: () => Navigator.pop(context, _selected),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payRow(String name, String emoji) {
    return RadioListRow(
      title: name,
      selected: _selected == name,
      onTap: () => setState(() => _selected = name),
      leading: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: TextStyle(fontSize: 15.sp)),
      ),
    );
  }

  Widget _morePay(IconData icon, String title, String? sub) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(11.r),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18.sp, color: AppColors.inkSoft),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  if (sub != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      sub,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.muted, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 1.3,
        ),
      );
}
