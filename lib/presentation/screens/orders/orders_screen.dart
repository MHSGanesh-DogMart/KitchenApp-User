import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';

/// Mockup 33 — Orders tab (redesigned).
///
/// Premium polish:
///   · Editorial hero header — "Your orders" + active/past count.
///   · Cream segmented control (Active · Past).
///   · Premium order cards — status header + amount + 3-dot menu,
///     date, thumbnail strip of foods, split footer actions.
///   · Empty state with circular cream avatar.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _tab = 0;

  static const _thaliImg =
      'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=240&q=80&auto=format&fit=crop';
  static const _curryImg =
      'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=240&q=80&auto=format&fit=crop';
  static const _biryaniImg =
      'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=240&q=80&auto=format&fit=crop';
  static const _paneerImg =
      'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=240&q=80&auto=format&fit=crop';
  static const _dosaImg =
      'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=240&q=80&auto=format&fit=crop';

  static const _active = <_Order>[
    _Order(
      orderId: '#PD4821',
      cookName: 'Sunita Aunty',
      cookInitials: 'SA',
      total: 320,
      date: 'Today, 11:48 AM',
      items: 3,
      status: _OrderStatus.outForDelivery,
      thumbnails: [_thaliImg, _curryImg, _paneerImg],
    ),
  ];
  static const _past = <_Order>[
    _Order(
      orderId: '#PD4818',
      cookName: 'Lakshmi Amma',
      cookInitials: 'LA',
      total: 240,
      date: 'Placed 3 Jun, 2:14 PM',
      items: 2,
      status: _OrderStatus.delivered,
      thumbnails: [_biryaniImg, _curryImg],
    ),
    _Order(
      orderId: '#PD4805',
      cookName: 'Jain Rasoi',
      cookInitials: 'JR',
      total: 130,
      date: 'Placed 27 May, 1:02 PM',
      items: 1,
      status: _OrderStatus.delivered,
      thumbnails: [_dosaImg],
    ),
    _Order(
      orderId: '#PD4790',
      cookName: 'Sunita Aunty',
      cookInitials: 'SA',
      total: 0,
      date: 'Placed 19 Apr, 6:51 PM',
      items: 4,
      status: _OrderStatus.cancelled,
      thumbnails: [_thaliImg, _curryImg, _paneerImg, _dosaImg],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _active : _past;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Hero header ──
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your orders',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.6,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${_active.length} active · ${_past.length} past',
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Segmented (Active / Past) ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    _SegTab(
                      label: 'Active',
                      count: _active.length,
                      selected: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                    _SegTab(
                      label: 'Past',
                      count: _past.length,
                      selected: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ── List / empty ──
            Expanded(
              child: list.isEmpty
                  ? _EmptyState(isActive: _tab == 0)
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(20.w, 0, 20.w, 110.h),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                      itemBuilder: (_, i) => _OrderCard(order: list[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── data ───────────────────────

enum _OrderStatus { outForDelivery, delivered, cancelled }

class _Order {
  const _Order({
    required this.orderId,
    required this.cookName,
    required this.cookInitials,
    required this.total,
    required this.date,
    required this.items,
    required this.status,
    required this.thumbnails,
  });
  final String orderId;
  final String cookName;
  final String cookInitials;
  final int total;
  final String date;
  final int items;
  final _OrderStatus status;
  final List<String> thumbnails;

  bool get isActive => status == _OrderStatus.outForDelivery;
}

// ─────────────────────── segmented tab ────────────────────

class _SegTab extends StatelessWidget {
  const _SegTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 11.h),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.ink : AppColors.muted,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.line.withValues(alpha: .6),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── order card ───────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final _Order order;

  ({IconData icon, String label, Color fg, Color bg}) _statusFor() {
    switch (order.status) {
      case _OrderStatus.delivered:
        return (
          icon: Icons.check_circle_rounded,
          label: 'Delivered',
          fg: AppColors.success,
          bg: AppColors.success.withValues(alpha: .12),
        );
      case _OrderStatus.cancelled:
        return (
          icon: Icons.cancel_rounded,
          label: 'Cancelled',
          fg: AppColors.muted,
          bg: AppColors.cream,
        );
      case _OrderStatus.outForDelivery:
        return (
          icon: Icons.delivery_dining_rounded,
          label: 'Out for delivery',
          fg: AppColors.primary,
          bg: AppColors.primarySoft,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _statusFor();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: () =>
            Navigator.pushNamed(context, RouteNames.orderDetail),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header strip
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 10.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: s.bg,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s.icon, size: 13.sp, color: s.fg),
                          SizedBox(width: 4.w),
                          Text(
                            s.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: s.fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (order.status != _OrderStatus.cancelled)
                      Text(
                        '₹${order.total}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    IconButton(
                      onPressed: () {},
                      iconSize: 18.sp,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),

              // Cook + date row
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: const BoxDecoration(
                        color: AppColors.tier1,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        order.cookInitials,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.cookName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: -.2,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '${order.items} item${order.items == 1 ? '' : 's'} · ${order.date}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Thumbnail strip
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                child: SizedBox(
                  height: 56.w,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: order.thumbnails.length.clamp(0, 5),
                    separatorBuilder: (_, _) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: SizedBox(
                        width: 56.w,
                        height: 56.w,
                        child: CachedNetworkImage(
                          imageUrl: order.thumbnails[i],
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Shimmer.fromColors(
                            baseColor: AppColors.line,
                            highlightColor: Colors.white,
                            child: Container(color: AppColors.line),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.cream,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.restaurant_rounded,
                              color: AppColors.muted,
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Divider(height: 1, color: AppColors.line),

              // Footer actions
              if (order.isActive)
                _FooterBtn(
                  label: 'Track order',
                  primary: true,
                  icon: Icons.location_on_rounded,
                  onTap: () => Navigator.pushNamed(
                      context, RouteNames.orderTracking),
                )
              else if (order.status == _OrderStatus.cancelled)
                _FooterBtn(
                  label: 'Order again',
                  primary: true,
                  icon: Icons.refresh_rounded,
                  onTap: () =>
                      Navigator.pushNamed(context, RouteNames.cookDetail),
                )
              else
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _FooterBtn(
                          label: 'Rate order',
                          primary: false,
                          onTap: () =>
                              Navigator.pushNamed(context, RouteNames.rate),
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        color: AppColors.line,
                      ),
                      Expanded(
                        child: _FooterBtn(
                          label: 'Order again',
                          primary: true,
                          onTap: () => Navigator.pushNamed(
                              context, RouteNames.cookDetail),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterBtn extends StatelessWidget {
  const _FooterBtn({
    required this.label,
    required this.primary,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool primary;
  final VoidCallback onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48.h,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.sp,
                color: primary ? AppColors.primary : AppColors.ink,
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: primary ? AppColors.primary : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── empty state ───────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isActive});
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                isActive ? '🍽' : '📜',
                style: TextStyle(fontSize: 34.sp),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isActive
                  ? 'No active orders right now'
                  : 'No past orders yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              isActive
                  ? 'Once you place an order, you can\ntrack it here in real time.'
                  : 'When you order from a kitchen,\nit will show up here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
