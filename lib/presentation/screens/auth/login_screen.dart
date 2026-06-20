import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';

/// Sign in — hero food photo + sliding white sheet (mockup-style).
///
/// Top half = warm food hero (cached network image). Bottom = white
/// rounded sheet with grabber, phone input, Send OTP / Verify CTA,
/// and a single "Continue with Google" pill. After Send OTP the
/// phone row is replaced by 4 OTP boxes + Resend.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.returningName, this.returningPhone});
  final String? returningName;
  final String? returningPhone;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _otpLength = 4;
  static const _resendSeconds = 24;

  /// Warm Indian home-food hero (Unsplash — stable ID).
  static const _heroImage =
      'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=900&q=85&auto=format&fit=crop';

  final _phoneCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  final _otpCtrl = TextEditingController();
  final _otpFocus = FocusNode();

  bool _otpSent = false;
  bool _sending = false;
  bool _verifying = false;
  bool _otpError = false;
  int _triesLeft = 3;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  bool get _returning => widget.returningName != null;
  String get _otpCode => _otpCtrl.text;

  @override
  void initState() {
    super.initState();
    if (_returning && widget.returningPhone != null) {
      _phoneCtrl.text = widget.returningPhone!.replaceFirst('+91 ', '');
    }
    // Auto-dismiss the keyboard the moment a valid 10-digit number
    // is typed — saves the user a tap before hitting "Send OTP".
    _phoneCtrl.addListener(_maybeDismissKeyboard);
  }

  void _maybeDismissKeyboard() {
    if (_phoneCtrl.text.length == 10 && _phoneFocus.hasFocus) {
      _phoneFocus.unfocus();
    }
  }

  @override
  void dispose() {
    _phoneCtrl
      ..removeListener(_maybeDismissKeyboard)
      ..dispose();
    _phoneFocus.dispose();
    _otpCtrl.dispose();
    _otpFocus.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneCtrl.text.length != 10 && !_returning) {
      _toast('Enter a valid 10-digit number');
      return;
    }
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _otpSent = true;
    });
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _otpFocus.requestFocus(),
    );
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  void _onOtpChanged(String _) {
    if (_otpError) setState(() => _otpError = false);
  }

  void _onOtpCompleted(String _) {
    // pinput already called onChanged with the full code — dismiss
    // keyboard and run verification.
    _otpFocus.unfocus();
    FocusScope.of(context).unfocus();
    _verifyOtp();
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length < _otpLength) return;
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (_otpCode == '1234') {
      Navigator.pushReplacementNamed(context, RouteNames.locationPermission);
    } else {
      setState(() {
        _otpError = true;
        _verifying = false;
        _triesLeft--;
      });
      _otpCtrl.clear();
      _otpFocus.requestFocus();
    }
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    _startResendTimer();
    _toast('New OTP sent');
  }

  void _toast(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.ink));

  String get _maskedPhone {
    if (_phoneCtrl.text.length < 4) return '+91 …';
    final last4 = _phoneCtrl.text.substring(_phoneCtrl.text.length - 4);
    return '+91 ${'x' * (_phoneCtrl.text.length - 4)} $last4';
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final imageH = screenH * 0.70; // Kitchen hero — 70% of screen
    final sheetH = screenH * 0.43; // White sheet — 43% of screen (overlap)

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Kitchen hero photo — fills top 70%, full-bleed ──
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SizedBox(
              height: imageH,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _heroImage,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.primary),
                  ),
                  // Subtle bottom gradient so the sheet edge reads
                  // cleanly over busy kitchen scenes.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.ink.withValues(alpha: .25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── White sliding sheet — bottom 43% (overlaps the hero) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              constraints: BoxConstraints(minHeight: sheetH),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: .12),
                    blurRadius: 28,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(22.w, 14.h, 22.w, 22.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Grabber
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
                      SizedBox(height: 18.h),

                      // ── Headline ──
                      Center(
                        child: Text(
                          _otpSent
                              ? 'We sent you a 4-digit code'
                              : "Let's start with your phone number",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkSoft,
                          ),
                        ),
                      ),
                      if (_otpSent) ...[
                        SizedBox(height: 4.h),
                        Center(
                          child: Text(
                            _maskedPhone,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.ink,
                              decorationThickness: 1.5,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 18.h),

                      // ── Phone row OR OTP boxes ──
                      AnimatedSize(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: _otpSent
                            ? _OtpStack(
                                controller: _otpCtrl,
                                focus: _otpFocus,
                                error: _otpError,
                                onChanged: _onOtpChanged,
                                onCompleted: _onOtpCompleted,
                                triesLeft: _triesLeft,
                                secondsLeft: _secondsLeft,
                                onResend: _resend,
                              )
                            : _PhoneRow(
                                controller: _phoneCtrl,
                                focusNode: _phoneFocus,
                              ),
                      ),

                      SizedBox(height: 16.h),

                      // ── Primary CTA ──
                      _PrimaryButton(
                        label: _otpSent ? 'Continue' : 'Send OTP',
                        loading: _otpSent ? _verifying : _sending,
                        onTap: () {
                          if (_otpSent) {
                            if (!_verifying) _verifyOtp();
                          } else {
                            if (!_sending) _sendOtp();
                          }
                        },
                      ),

                      SizedBox(height: 22.h),

                      // ── or with divider ──
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColors.line, height: 1),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              'or with',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppColors.line, height: 1),
                          ),
                        ],
                      ),

                      SizedBox(height: 14.h),

                      // ── Google pill ──
                      _SocialPill(label: 'Continue with Google', onTap: () {}),
                    ],
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

// ─────────────────────── phone row ───────────────────────

/// +91 cream pill + clean rounded phone TextFormField. Matches the
/// reference: two pills sitting on the same line.
class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.controller, required this.focusNode});
  final TextEditingController controller;
  final FocusNode focusNode;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // +91 pill
        Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.line, width: .8),
          ),
          child: Text(
            '+91',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        // Phone TextField pill
        Expanded(
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.line, width: .8),
            ),
            alignment: Alignment.center,
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.primary,
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
                hintText: 'Enter phone number',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  // color: AppColors.muted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────── OTP stack ───────────────────────

class _OtpStack extends StatelessWidget {
  const _OtpStack({
    required this.controller,
    required this.focus,
    required this.error,
    required this.onCompleted,
    required this.onChanged,
    required this.triesLeft,
    required this.secondsLeft,
    required this.onResend,
  });
  final TextEditingController controller;
  final FocusNode focus;
  final bool error;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String> onChanged;
  final int triesLeft;
  final int secondsLeft;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft <= 0;

    final defaultPinTheme = PinTheme(
      width: 52.w,
      height: 52.w,
      textStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20.sp,
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      color: Colors.white,
      border: Border.all(color: AppColors.primary, width: 1.6),
      borderRadius: BorderRadius.circular(12.r),
    );
    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: Colors.white,
      border: Border.all(color: AppColors.ink, width: 1.6),
      borderRadius: BorderRadius.circular(12.r),
    );
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      color: Colors.white,
      border: Border.all(color: AppColors.error, width: 1.6),
      borderRadius: BorderRadius.circular(12.r),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Pinput(
            controller: controller,
            focusNode: focus,
            length: 4,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            errorPinTheme: errorPinTheme,
            forceErrorState: error,
            cursor: Container(width: 2, height: 22.h, color: AppColors.primary),
            separatorBuilder: (_) => SizedBox(width: 10.w),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            onCompleted: onCompleted,
          ),
        ),
        SizedBox(height: 10.h),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: canResend ? onResend : null,
            borderRadius: BorderRadius.circular(99.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Text(
                canResend
                    ? 'Resend OTP'
                    : 'Resend in 0:${secondsLeft.toString().padLeft(2, '0')}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: canResend ? AppColors.primary : AppColors.muted,
                ),
              ),
            ),
          ),
        ),
        if (error) ...[
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 14.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Wrong code. $triesLeft tries left.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// (_OtpBox removed — replaced by Pinput inside _OtpStack.)

// ─────────────────────── primary button ───────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  final String label;
  final bool loading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(99.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(99.r),
        onTap: loading ? null : onTap,
        child: Container(
          height: 54.h,
          alignment: Alignment.center,
          child: loading
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────── social pill ───────────────────────

class _SocialPill extends StatelessWidget {
  const _SocialPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(99.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(99.r),
        onTap: onTap,
        child: Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(99.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google "G" mark
              Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'G',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4285F4),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
