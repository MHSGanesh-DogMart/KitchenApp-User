import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:padosi_food/presentation/widgets/padosi/padosi_confirm_dialog.dart';
import 'package:provider/provider.dart';

import '../../../controllers/user_profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routing/route_names.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/padosi/padosi_cards.dart';

/// Screen 09 — Profile / Orders / Settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await UserProfileController.instance.getMyProfile();
    if (!mounted) return;
    setState(() => _user = u);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Header Row (Back Button & Title)
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 12.h),
              child: Row(
                children: [
                  // GestureDetector(
                  //   onTap: () => Navigator.maybePop(context),
                  //   child: Container(
                  //     width: 40.r,
                  //     height: 40.r,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       shape: BoxShape.circle,
                  //       border: Border.all(color: AppColors.line, width: 1),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withValues(alpha: 0.03),
                  //           blurRadius: 6,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     alignment: Alignment.center,
                  //     child: Icon(
                  //       Icons.chevron_left_rounded,
                  //       color: AppColors.ink,
                  //       size: 24.sp,
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(width: 16.w),
                  Text(
                    'Profile',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.6,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 110.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Block
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30.r,
                            backgroundColor: const Color(0xFFECE9FE),
                            backgroundImage:
                                (_user?.profilePicUrl?.isNotEmpty ?? false)
                                ? NetworkImage(_user!.profilePicUrl!)
                                : null,
                            child: (_user?.profilePicUrl?.isNotEmpty ?? false)
                                ? null
                                : Icon(
                                    Icons.person_rounded,
                                    color: const Color(0xFF7C3AED),
                                    size: 32.sp,
                                  ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.name ?? 'Loading…',
                                  style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  _user?.phone ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Three-Card Quick Actions Row
                    Row(
                      children: [
                        _QuickActionCard(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Your\nOrders',
                          onTap: () =>
                              Navigator.pushNamed(context, RouteNames.orders),
                        ),
                        SizedBox(width: 10.w),
                        _QuickActionCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Help &\nSupport',
                          onTap: () =>
                              Navigator.pushNamed(context, RouteNames.help),
                        ),
                        SizedBox(width: 10.w),
                        _QuickActionCard(
                          icon: Icons.favorite_border_rounded,
                          label: 'Your\nWishlist',
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteNames.favourites,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Promo Cash Card (Zepto Cash Style)
                    _PadosiCashCard(
                      onTap: () {
                        // Action
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Update Available Banner
                    _UpdateBanner(
                      onTap: () {
                        // Action
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Section Header: Your Information
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        'Your Information',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),

                    // Grouped Settings Card - Your Information
                    PadosiCard(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      borderRadius: BorderRadius.circular(16.r),
                      borderColor: Colors.white,
                      child: Column(
                        children: [
                          _MenuRow(
                            icon: Icons.currency_rupee_rounded,
                            label: 'Your Refunds',
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.refunds,
                            ),
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.favorite_border_rounded,
                            label: 'Your Wishlist',
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.favourites,
                            ),
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.card_giftcard_rounded,
                            label: 'E-Gift Cards',
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.giftCards,
                            ),
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Help & Support',
                            onTap: () =>
                                Navigator.pushNamed(context, RouteNames.help),
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.home_outlined,
                            label: 'Saved Addresses',
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.addressesList,
                            ),
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Edit Profile',
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                RouteNames.editProfile,
                              );
                              _load(); // refresh after editing
                            },
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.stars_outlined,
                            label: 'Rewards',
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.rewards,
                            ),
                          ),
                          // _Sep(),
                          // _MenuRow(
                          //   icon: Icons.payment_rounded,
                          //   label: 'Payment Management',
                          //   onTap: () => Navigator.pushNamed(
                          //     context,
                          //     RouteNames.payments,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Section Header: Other Information
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        'Other Information',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),

                    // Grouped Settings Card - Other Information
                    PadosiCard(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      borderRadius: BorderRadius.circular(16.r),
                      borderColor: Colors.white,
                      child: Column(
                        children: [
                          _MenuRow(
                            icon: Icons.language_rounded,
                            label: 'App Language',
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.language,
                            ),
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.share_rounded,
                            label: 'Invite Friends',
                            onTap: () =>
                                Navigator.pushNamed(context, RouteNames.invite),
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.notifications_none_rounded,
                            label: 'Notifications',
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.notifications,
                            ),
                          ),
                          _Sep(),
                          _MenuRow(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.settings,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Log Out Button
                    GestureDetector(
                      onTap: () => _confirmLogout(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.line),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF16181D,
                              ).withValues(alpha: .02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Version Text
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'App version 1.0.0',
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFamily,
                              fontSize: 11.sp,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  /// Static helper — uses the shared [PadosiConfirmDialog] then
  /// pushes the user back to the auth intro on confirm. Lives on the
  /// stateless [ProfileScreen] so any tap site can reuse it.
  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await PadosiConfirmDialog.show(
      context,
      icon: Icons.logout_rounded,
      title: 'Log out?',
      message:
          "You'll need to enter your OTP again to sign back in. Your saved "
          'addresses and orders stay safe.',
      confirmLabel: 'Yes, log out',
    );
    if (ok == true && context.mounted) {
      // Drops this device's FCM token server-side, clears the JWT, and
      // navigates back to login (handled inside AuthProvider.logout).
      await context.read<AuthProvider>().logout();
    }
  }
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: _DashedDivider(
        color: Colors.grey.shade100,
        dashWidth: 2.5,
        dashHeight: 1.0,
        spacing: 3.5,
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: AppColors.ink),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PadosiCard(
        background: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24.sp, color: AppColors.ink),
            SizedBox(height: 6.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PadosiCashCard extends StatelessWidget {
  const _PadosiCashCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PadosiCard(
      background: const Color(0xFFF7F5FF), // soft lavender
      borderColor: const Color(0xFFE5DEFF),
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.all(16.w),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wallet_rounded,
                color: const Color(0xFF7C3AED),
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Padosi Cash & Gift Card',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const _DashedDivider(color: Color(0xFFE5DEFF)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Available Balance  ',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  Text(
                    '₹0',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Text(
                  'Add Balance',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PadosiCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            Icons.published_with_changes_rounded,
            color: AppColors.ink,
            size: 26.sp,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Available',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Enjoy a more seamless shopping experience',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFamily,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.fresh,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              'New',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFamily,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: 18.sp,
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({
    this.color,
    this.dashWidth = 4.5,
    this.dashHeight = 1.0,
    this.spacing = 4.5,
  });
  final Color? color;
  final double dashWidth;
  final double dashHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + spacing)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color ?? AppColors.line),
              ),
            );
          }),
        );
      },
    );
  }
}
