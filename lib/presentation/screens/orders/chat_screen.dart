import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';

/// Mockup 24 — Chat.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.peerName = 'Sunita Aunty'});
  final String peerName;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final List<_Msg> _msgs = [
    const _Msg(text: 'Starting your thali now 😊', me: false),
    const _Msg(text: 'Less oil please 🙏', me: true),
    const _Msg(text: 'Sure beta!', me: false),
  ];

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text: t, me: true));
      _ctrl.clear();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.peerName
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              child: Row(
                children: [
                  const AuthBackButton(),
                  SizedBox(width: 10.w),
                  CircleAvatar(
                    radius: 15.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initials,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.peerName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'online',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _IconBtn(icon: Icons.call_rounded, onTap: () {}),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        'Messages stay in Padosi',
                        style: GoogleFonts.inter(
                          fontSize: 10.5.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                  ..._msgs.map((m) => _Bubble(m: m)),
                ],
              ),
            ),
            // Composer
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: const Border(
                    top: BorderSide(color: AppColors.line)),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.line),
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: TextField(
                          controller: _ctrl,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: AppColors.ink,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Message…',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13.sp,
                              color: AppColors.muted,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 9.w),
                    Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(13.r),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(13.r),
                        onTap: _send,
                        child: SizedBox(
                          width: 44.w,
                          height: 44.w,
                          child: Icon(Icons.send_rounded,
                              color: Colors.white, size: 18.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  const _Msg({required this.text, required this.me});
  final String text;
  final bool me;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.m});
  final _Msg m;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 220.w),
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: m.me ? AppColors.primary : AppColors.surface,
          border: m.me ? null : Border.all(color: AppColors.line),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(m.me ? 14.r : 4.r),
            bottomRight: Radius.circular(m.me ? 4.r : 14.r),
          ),
        ),
        child: Text(
          m.text,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: m.me ? Colors.white : AppColors.ink,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: SizedBox(
          width: 38.w,
          height: 38.w,
          child: Icon(icon, size: 18.sp, color: AppColors.ink),
        ),
      ),
    );
  }
}
