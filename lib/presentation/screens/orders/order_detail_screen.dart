import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';

/// Mockup 29 — Order detail (past) — premium redesign.
///
///   1. Custom hero header (back · "Order #ID · 3 items" · Get help pill).
///   2. Big delivered hero card (green check tile + "Arrived in 8 mins").
///   3. Items in order — thumbnail + name + price + struck old price.
///   4. Bill summary (with FREE delivery / handling).
///   5. Order details card (Order ID copy, receiver, address, timestamps).
///   6. Need-help card (kicker + arrow).
///   7. Sticky footer with Rate Order (ghost) + Order Again (tangerine).
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, this.orderId = '#PD4790'});
  final String orderId;

  // Demo items
  static const _items = <_Item>[
    _Item(
      name: 'Andhra Veg Thali',
      sub: '1 plate · 480 g',
      price: 140,
      oldPrice: 160,
      image:
          'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=240&q=80&auto=format&fit=crop',
    ),
    _Item(
      name: 'Gongura Pickle',
      sub: '1 jar · 100 g',
      price: 60,
      image:
          'https://images.unsplash.com/photo-1599909533730-d56f9c5f7c6b?w=240&q=80&auto=format&fit=crop',
    ),
    _Item(
      name: 'Sweet Lassi',
      sub: '1 glass · 200 ml',
      price: 40,
      oldPrice: 50,
      image:
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=240&q=80&auto=format&fit=crop',
    ),
  ];

  int get _subtotal => _items.fold(0, (a, b) => a + b.price);
  int get _subtotalOld => _items.fold(
      0, (a, b) => a + (b.oldPrice ?? b.price));

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
                _Header(orderId: orderId, itemCount: _items.length),
                Divider(height: 1, color: AppColors.line),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 130.h),
                    children: [
                      // ── Delivered status hero ──
                      _DeliveredHero(eta: '8 mins'),

                      SizedBox(height: 16.h),

                      // ── Items in order ──
                      _Kicker('${_items.length} ITEMS IN ORDER'),
                      SizedBox(height: 10.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < _items.length; i++) ...[
                              _ItemRow(item: _items[i]),
                              if (i < _items.length - 1)
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

                      SizedBox(height: 16.h),

                      // ── Bill summary ──
                      _Kicker('BILL SUMMARY'),
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
                            _billRow(
                              'Item total',
                              value: '₹$_subtotal',
                              old: _subtotalOld > _subtotal
                                  ? '₹$_subtotalOld'
                                  : null,
                            ),
                            SizedBox(height: 10.h),
                            _billRow(
                              'Delivery fee',
                              value: 'FREE',
                              old: '₹30',
                              positive: true,
                            ),
                            SizedBox(height: 10.h),
                            _billRow(
                              'Handling fee',
                              value: 'FREE',
                              old: '₹10',
                              positive: true,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Divider(
                                  height: 1, color: AppColors.line),
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total bill',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '₹${_subtotalOld + 40}',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.muted,
                                        decoration:
                                            TextDecoration.lineThrough,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '₹$_subtotal',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: -.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            // Invoice link
                            Material(
                              color: AppColors.secondarySoft,
                              borderRadius: BorderRadius.circular(99.r),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(99.r),
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.receipt_long_rounded,
                                        size: 15.sp,
                                        color: AppColors.secondary,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Download invoice',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ── Order details ──
                      _Kicker('ORDER DETAILS'),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              label: 'Order ID',
                              value: orderId,
                              copyable: true,
                            ),
                            SizedBox(height: 14.h),
                            _DetailRow(
                              label: 'Receiver',
                              value: 'Hemanth · +91 93915 81008',
                            ),
                            SizedBox(height: 14.h),
                            _DetailRow(
                              label: 'Delivery address',
                              value:
                                  'Flat 402, Brigade Towers, Koramangala 5th Block, Bangalore 560095',
                            ),
                            SizedBox(height: 14.h),
                            _DetailRow(
                              label: 'Placed at',
                              value: '3 Jun 2026, 2:14 PM',
                            ),
                            SizedBox(height: 14.h),
                            _DetailRow(
                              label: 'Arrived at',
                              value: '3 Jun 2026, 2:23 PM',
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ── Need help card ──
                      Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20.r),
                          onTap: () =>
                              Navigator.pushNamed(context, RouteNames.help),
                          child: Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: AppColors.line),
                            ),
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
                                  child: Icon(
                                    Icons.support_agent_rounded,
                                    color: AppColors.primary,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Need help with this order?',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                          letterSpacing: -.2,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Find your issue or chat with support',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5.sp,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.muted,
                                  size: 22.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky footer ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FooterBar(
              onRate: () =>
                  Navigator.pushNamed(context, RouteNames.rate),
              onReorder: () =>
                  Navigator.pushNamed(context, RouteNames.cookDetail),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(
    String label, {
    required String value,
    String? old,
    bool positive = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5.sp,
            color: AppColors.inkSoft,
          ),
        ),
        Row(
          children: [
            if (old != null) ...[
              Text(
                old,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: positive ? AppColors.success : AppColors.ink,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────── data ───────────────────────

class _Item {
  const _Item({
    required this.name,
    required this.sub,
    required this.price,
    required this.image,
    this.oldPrice,
  });
  final String name;
  final String sub;
  final int price;
  final int? oldPrice;
  final String image;
}

// ─────────────────────── header ───────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.orderId, required this.itemCount});
  final String orderId;
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 12.w, 8.h),
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
                  'Order $orderId',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.3,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '$itemCount items',
                  style: GoogleFonts.inter(
                    fontSize: 11.5.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          // Get help pill
          Material(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(99.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(99.r),
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 7.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      size: 14.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Get help',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── delivered hero ───────────────────

class _DeliveredHero extends StatelessWidget {
  const _DeliveredHero({required this.eta});
  final String eta;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivered',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Hot and on time — hope you enjoyed it',
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
          SizedBox(width: 8.w),
          // ETA pill
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(99.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 13.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 3.w),
                Text(
                  eta,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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

// ─────────────────────── item row ───────────────────────

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final _Item item;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              width: 54.w,
              height: 54.w,
              child: CachedNetworkImage(
                imageUrl: item.image,
                fit: BoxFit.cover,
                placeholder: (_, _) => Shimmer.fromColors(
                  baseColor: AppColors.line,
                  highlightColor: Colors.white,
                  child: Container(color: AppColors.line),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.cream,
                  alignment: Alignment.center,
                  child: Icon(Icons.restaurant_rounded,
                      color: AppColors.muted, size: 22.sp),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.2,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.sub,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${item.price}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              if (item.oldPrice != null) ...[
                SizedBox(height: 1.h),
                Text(
                  '₹${item.oldPrice}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── detail row ───────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });
  final String label;
  final String value;
  final bool copyable;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: AppColors.muted,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1.35,
                  letterSpacing: -.1,
                ),
              ),
            ),
            if (copyable)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Order ID copied'),
                      backgroundColor: AppColors.ink,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 15.sp,
                    color: AppColors.muted,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────── footer ───────────────────────

class _FooterBar extends StatelessWidget {
  const _FooterBar({required this.onRate, required this.onReorder});
  final VoidCallback onRate;
  final VoidCallback onReorder;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
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
        child: Row(
          children: [
            // Rate Order (ghost)
            Expanded(
              child: Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: onRate,
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Text(
                      'Rate order',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            // Order Again (primary)
            Expanded(
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: onReorder,
                  child: Container(
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Order again',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ],
                    ),
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

// ─────────────────────── kicker ───────────────────────

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
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
}
