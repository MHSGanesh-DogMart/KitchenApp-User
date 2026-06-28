import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controllers/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../models/order.dart';

/// Mockup 33 — Orders tab (server-backed).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _tab = 0;
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final list = await OrderController.instance.listOrders();
    if (!mounted) return;
    setState(() {
      _orders = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _orders.where((o) => o.isActive).toList();
    final past = _orders.where((o) => !o.isActive).toList();
    final list = _tab == 0 ? active : past;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
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
                    '${active.length} active · ${past.length} past',
                    style: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(16.r)),
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    _SegTab(label: 'Active', count: active.length, selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                    _SegTab(label: 'Past', count: past.length, selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                      ? _EmptyState(isActive: _tab == 0)
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 110.h),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => SizedBox(height: 14.h),
                            itemBuilder: (_, i) => _OrderCard(
                              order: list[i],
                              onTap: () => Navigator.pushNamed(context, RouteNames.orderDetail, arguments: {'orderId': list[i].id}),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── status mapping ───────────────────────

({IconData icon, String label, Color fg, Color bg}) _statusStyle(String status) {
  switch (status) {
    case 'DELIVERED':
      return (icon: Icons.check_circle_rounded, label: 'Delivered', fg: AppColors.success, bg: AppColors.success.withValues(alpha: .12));
    case 'CANCELLED':
    case 'PAYMENT_FAILED':
      return (icon: Icons.cancel_rounded, label: 'Cancelled', fg: AppColors.muted, bg: AppColors.cream);
    case 'OUT_FOR_DELIVERY':
      return (icon: Icons.delivery_dining_rounded, label: 'Out for delivery', fg: AppColors.primary, bg: AppColors.primarySoft);
    case 'READY':
      return (icon: Icons.shopping_bag_rounded, label: 'Ready', fg: AppColors.primary, bg: AppColors.primarySoft);
    case 'PREPARING':
      return (icon: Icons.soup_kitchen_rounded, label: 'Preparing', fg: AppColors.primary, bg: AppColors.primarySoft);
    case 'ACCEPTED':
      return (icon: Icons.thumb_up_rounded, label: 'Accepted', fg: AppColors.primary, bg: AppColors.primarySoft);
    default: // PLACED
      return (icon: Icons.receipt_long_rounded, label: 'Placed', fg: AppColors.secondary, bg: AppColors.secondarySoft);
  }
}

String _shortDate(String? iso) {
  if (iso == null) return '';
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '${d.day} ${months[d.month - 1]}, $h:$m $ap';
}

class _SegTab extends StatelessWidget {
  const _SegTab({required this.label, required this.count, required this.selected, required this.onTap});
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
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.line.withValues(alpha: .6),
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});
  final Order order;
  final VoidCallback onTap;

  String get _initials {
    final n = order.kitchenName ?? 'Kitchen';
    return n.split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle(order.status);
    final thumbs = order.items.where((i) => (i.imageUrl?.isNotEmpty ?? false)).map((i) => i.imageUrl!).take(5).toList();
    final isCancelled = order.status == 'CANCELLED' || order.status == 'PAYMENT_FAILED';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 12.w, 10.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(99.r)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(s.icon, size: 13.sp, color: s.fg),
                          SizedBox(width: 4.w),
                          Text(
                            s.label,
                            style: GoogleFonts.spaceGrotesk(fontSize: 11.sp, fontWeight: FontWeight.w700, color: s.fg),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (!isCancelled)
                      Text(
                        '₹${order.grandTotal.round()}',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: const BoxDecoration(color: AppColors.tier1, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        _initials,
                        style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10.sp),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.kitchenName ?? 'Kitchen',
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
                            '${order.itemCount} item${order.itemCount == 1 ? '' : 's'} · ${_shortDate(order.createdAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    if (order.isPickup)
                      Icon(Icons.storefront_rounded, size: 16.sp, color: AppColors.muted)
                    else
                      Icon(Icons.delivery_dining_rounded, size: 16.sp, color: AppColors.muted),
                  ],
                ),
              ),
              if (thumbs.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
                  child: SizedBox(
                    height: 56.w,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: thumbs.length,
                      separatorBuilder: (_, _) => SizedBox(width: 8.w),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: SizedBox(
                          width: 56.w,
                          height: 56.w,
                          child: CachedNetworkImage(
                            imageUrl: thumbs[i],
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Shimmer.fromColors(
                              baseColor: AppColors.line,
                              highlightColor: Colors.white,
                              child: Container(color: AppColors.line),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: AppColors.cream,
                              alignment: Alignment.center,
                              child: Icon(Icons.restaurant_rounded, color: AppColors.muted, size: 20.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Divider(height: 1, color: AppColors.line),
              if (order.isActive)
                _FooterBtn(
                  label: order.isPickup ? 'View pickup code' : 'Track order',
                  primary: true,
                  icon: order.isPickup ? Icons.qr_code_rounded : Icons.location_on_rounded,
                  onTap: onTap,
                )
              else
                _FooterBtn(
                  label: 'View details',
                  primary: true,
                  icon: Icons.receipt_long_rounded,
                  onTap: onTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterBtn extends StatelessWidget {
  const _FooterBtn({required this.label, required this.primary, required this.onTap, this.icon});
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
              Icon(icon, size: 16.sp, color: primary ? AppColors.primary : AppColors.ink),
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
              decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(isActive ? '🍽' : '📜', style: TextStyle(fontSize: 34.sp)),
            ),
            SizedBox(height: 16.h),
            Text(
              isActive ? 'No active orders right now' : 'No past orders yet',
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
                  ? 'Once you place an order, you can\ntrack it here.'
                  : 'When you order from a kitchen,\nit will show up here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
