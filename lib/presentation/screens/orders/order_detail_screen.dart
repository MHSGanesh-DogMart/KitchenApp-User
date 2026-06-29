import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controllers/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../models/order.dart';
import '../../widgets/padosi/padosi_confirm_dialog.dart';

/// Order detail — server-backed. Fetches /user/orders/:id, shows status,
/// handoff code, items, bill, and a Cancel action while it's still cancellable.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, this.orderId});
  final String? orderId;
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _loading = true;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.orderId;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    final o = await OrderController.instance.getOrder(id);
    if (!mounted) return;
    setState(() {
      _order = o;
      _loading = false;
    });
  }

  Future<void> _cancel() async {
    final id = _order?.id;
    if (id == null) return;
    final ok = await PadosiConfirmDialog.show(
      context,
      icon: Icons.cancel_outlined,
      title: 'Cancel this order?',
      message: 'The kitchen will be notified and any coupon will be released.',
      confirmLabel: 'Cancel order',
      destructive: true,
    );
    if (ok != true) return;
    setState(() => _cancelling = true);
    final updated = await OrderController.instance.cancel(id);
    if (!mounted) return;
    setState(() {
      _cancelling = false;
      if (updated != null) _order = updated;
    });
  }

  bool get _cancellable => _order != null && (_order!.status == 'PLACED' || _order!.status == 'ACCEPTED');

  ({IconData icon, String label, Color fg, Color bg}) _statusStyle(String s) {
    switch (s) {
      case 'DELIVERED':
        return (icon: Icons.check_circle_rounded, label: 'Delivered', fg: AppColors.success, bg: AppColors.success.withValues(alpha: .12));
      case 'CANCELLED':
      case 'PAYMENT_FAILED':
        return (icon: Icons.cancel_rounded, label: 'Cancelled', fg: AppColors.error, bg: AppColors.error.withValues(alpha: .1));
      case 'OUT_FOR_DELIVERY':
        return (icon: Icons.delivery_dining_rounded, label: 'Out for delivery', fg: AppColors.primary, bg: AppColors.primarySoft);
      case 'READY':
        return (icon: Icons.shopping_bag_rounded, label: 'Ready', fg: AppColors.primary, bg: AppColors.primarySoft);
      case 'PREPARING':
        return (icon: Icons.soup_kitchen_rounded, label: 'Preparing', fg: AppColors.primary, bg: AppColors.primarySoft);
      case 'ACCEPTED':
        return (icon: Icons.thumb_up_rounded, label: 'Accepted', fg: AppColors.primary, bg: AppColors.primarySoft);
      default:
        return (icon: Icons.receipt_long_rounded, label: 'Placed', fg: AppColors.secondary, bg: AppColors.secondarySoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = _order;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(o),
            Divider(height: 1, color: AppColors.line),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : o == null
                      ? Center(
                          child: Text('Order not found',
                              style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.muted)),
                        )
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 130.h),
                          children: [
                            _statusHero(o),
                            SizedBox(height: 16.h),
                            _kicker('${o.itemCount} ITEMS IN ORDER'),
                            SizedBox(height: 10.h),
                            _itemsCard(o),
                            SizedBox(height: 16.h),
                            _kicker('BILL SUMMARY'),
                            SizedBox(height: 10.h),
                            _billCard(o),
                            SizedBox(height: 16.h),
                            _kicker('ORDER DETAILS'),
                            SizedBox(height: 10.h),
                            _detailsCard(o),
                          ],
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: o == null ? null : _footer(o),
    );
  }

  Widget _header(Order? o) {
    final short = (o?.id.isNotEmpty ?? false) ? '#${o!.id.substring(0, 8).toUpperCase()}' : 'Order';
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 16.w, 8.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.ink,
            iconSize: 22.sp,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order $short',
                  style: GoogleFonts.spaceGrotesk(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -.3),
                ),
                if (o != null)
                  Text(
                    '${o.kitchenName ?? 'Kitchen'} · ${o.itemCount} item${o.itemCount == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(fontSize: 11.5.sp, color: AppColors.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusHero(Order o) {
    final s = _statusStyle(o.status);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(14.r)),
                alignment: Alignment.center,
                child: Icon(s.icon, color: s.fg, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.label,
                      style: GoogleFonts.spaceGrotesk(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -.3),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      o.isPickup ? 'Pickup order' : 'Delivery order',
                      style: GoogleFonts.inter(fontSize: 11.5.sp, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((o.handoffCode?.isNotEmpty ?? false) && o.status != 'CANCELLED') ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                children: [
                  Text(
                    o.isPickup ? 'PICKUP CODE' : 'DELIVERY OTP',
                    style: GoogleFonts.spaceGrotesk(fontSize: 10.sp, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: AppColors.primary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    o.handoffCode!,
                    style: GoogleFonts.spaceGrotesk(fontSize: 28.sp, fontWeight: FontWeight.w700, letterSpacing: 6, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itemsCard(Order o) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppColors.line)),
      child: Column(
        children: [
          for (var i = 0; i < o.items.length; i++) ...[
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: SizedBox(
                      width: 48.w,
                      height: 48.w,
                      child: (o.items[i].imageUrl?.isNotEmpty ?? false)
                          ? CachedNetworkImage(
                              imageUrl: o.items[i].imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Shimmer.fromColors(
                                baseColor: AppColors.line,
                                highlightColor: Colors.white,
                                child: Container(color: AppColors.line),
                              ),
                              errorWidget: (_, _, _) => _imgFallback(),
                            )
                          : _imgFallback(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.items[i].name,
                          style: GoogleFonts.spaceGrotesk(fontSize: 13.5.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '₹${o.items[i].price.round()} × ${o.items[i].qty}',
                          style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${o.items[i].lineTotal.round()}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            if (i < o.items.length - 1)
              Padding(padding: EdgeInsets.symmetric(horizontal: 14.w), child: Divider(height: 1, color: AppColors.line)),
          ],
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: AppColors.cream,
        alignment: Alignment.center,
        child: Icon(Icons.restaurant_rounded, color: AppColors.muted, size: 20.sp),
      );

  Widget _billCard(Order o) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppColors.line)),
      child: Column(
        children: [
          _billRow('Item total', '₹${o.itemTotal.round()}'),
          if (o.discount > 0) ...[
            SizedBox(height: 10.h),
            _billRow('Coupon discount${o.couponCode != null ? ' (${o.couponCode})' : ''}', '− ₹${o.discount.round()}', positive: true),
          ],
          SizedBox(height: 10.h),
          _billRow('Delivery', o.deliveryFee == 0 ? 'FREE' : '₹${o.deliveryFee.round()}', positive: o.deliveryFee == 0),
          SizedBox(height: 10.h),
          _billRow('Taxes & charges', '₹${o.taxesCharges.round()}'),
          Padding(padding: EdgeInsets.symmetric(vertical: 12.h), child: Divider(height: 1, color: AppColors.line)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total paid', style: GoogleFonts.spaceGrotesk(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.ink)),
              Text('₹${o.grandTotal.round()}',
                  style: GoogleFonts.spaceGrotesk(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(Order o) {
    final addr = [o.addressLine1, o.addressArea].where((s) => (s?.isNotEmpty ?? false)).join(', ');
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20.r), border: Border.all(color: AppColors.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Order ID', '#${o.id.substring(0, 8).toUpperCase()}', copyValue: o.id),
          SizedBox(height: 14.h),
          _detailRow('Type', o.isPickup ? 'Pickup' : 'Delivery'),
          if (o.receiverName?.isNotEmpty ?? false) ...[
            SizedBox(height: 14.h),
            _detailRow('Receiver', [o.receiverName, o.receiverPhone].where((s) => (s?.isNotEmpty ?? false)).join(' · ')),
          ],
          if (!o.isPickup && addr.isNotEmpty) ...[
            SizedBox(height: 14.h),
            _detailRow('Delivery address', addr),
          ],
        ],
      ),
    );
  }

  Widget? _footer(Order o) {
    if (_cancellable) {
      return _bar(
        child: Material(
          color: AppColors.error.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: _cancelling ? null : _cancel,
            child: Container(
              height: 50.h,
              alignment: Alignment.center,
              child: Text(
                _cancelling ? 'Cancelling…' : 'Cancel order',
                style: GoogleFonts.spaceGrotesk(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.error),
              ),
            ),
          ),
        ),
      );
    }
    if (o.status == 'DELIVERED' || o.status == 'CANCELLED') {
      return _bar(
        child: Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: () => Navigator.pushNamed(context, RouteNames.cookDetail),
            child: Container(
              height: 50.h,
              alignment: Alignment.center,
              child: Text('Order again', style: GoogleFonts.spaceGrotesk(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),
      );
    }
    return null; // in-progress, no action
  }

  Widget _bar({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
        child: SafeArea(top: false, child: child),
      );

  Widget _kicker(String t) => Padding(
        padding: EdgeInsets.only(left: 2.w),
        child: Text(t, style: GoogleFonts.spaceGrotesk(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 1.2)),
      );

  Widget _billRow(String label, String value, {bool positive = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.inkSoft))),
          Text(value,
              style: GoogleFonts.spaceGrotesk(fontSize: 13.sp, fontWeight: FontWeight.w700, color: positive ? AppColors.success : AppColors.ink)),
        ],
      );

  Widget _detailRow(String label, String value, {String? copyValue}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.muted)),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.35)),
              ),
              if (copyValue != null)
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: copyValue));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Order ID copied'), backgroundColor: AppColors.ink, duration: const Duration(seconds: 1)),
                    );
                  },
                  child: Padding(padding: EdgeInsets.all(4.w), child: Icon(Icons.copy_rounded, size: 15.sp, color: AppColors.muted)),
                ),
            ],
          ),
        ],
      );
}
