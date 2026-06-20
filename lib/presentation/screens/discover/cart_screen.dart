import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../providers/cart_provider.dart';
import '../padosi/mock/mock_data.dart';

/// Mockup 16 — Your cart.
/// Premium polish: reads the global [CartProvider]; groups by cook;
/// food-photo row tiles; cream/ink stepper; sticky checkout pill.
///
/// (`cook` / `cart` constructor args kept for back-compat with the
/// router but are no longer used — the screen pulls everything from
/// the provider so any screen's add/remove stays in sync.)
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.cook, this.cart});
  final Cook? cook;
  final Map<String, int>? cart;
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _note = '';

  static const _kDelivery = 25;
  static const _kTaxes = 14;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.values.toList();

    // Group lines by cook name so the cart reads as "kitchens you've
    // ordered from", matching the Indian home-chef mental model.
    final grouped = <String, List<CartLine>>{};
    for (final l in items) {
      grouped.putIfAbsent(l.cookName, () => []).add(l);
    }

    final subtotal = cart.total;
    final toPay = subtotal == 0 ? 0 : subtotal + _kDelivery + _kTaxes;
    final isEmpty = items.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _CartHeader(itemCount: cart.itemCount),
                Expanded(
                  child: isEmpty
                      ? const _EmptyState()
                      : ListView(
                          padding: EdgeInsets.fromLTRB(
                            16.w,
                            8.h,
                            16.w,
                            150.h,
                          ),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // ── Cook groups ──
                            for (final entry in grouped.entries) ...[
                              _CookGroupCard(
                                cookName: entry.key,
                                lines: entry.value,
                                onInc: (n) {
                                  final line = cart.lines[n];
                                  if (line == null) return;
                                  cart.inc(
                                    line.dish,
                                    cookName: line.cookName,
                                  );
                                },
                                onDec: cart.dec,
                              ),
                              SizedBox(height: 12.h),
                            ],

                            // ── Cooking note ──
                            _NoteCard(
                              value: _note,
                              onChanged: (v) => setState(() => _note = v),
                            ),
                            SizedBox(height: 12.h),

                            // ── Bill summary ──
                            _BillCard(
                              subtotal: subtotal,
                              delivery: _kDelivery,
                              taxes: _kTaxes,
                              total: toPay,
                            ),
                            SizedBox(height: 12.h),

                            // ── Padosi Protection ribbon ──
                            _ProtectionRibbon(),
                          ],
                        ),
                ),
              ],
            ),
          ),
          // ── Sticky checkout bar ──
          if (!isEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _CheckoutBar(
                items: cart.itemCount,
                total: toPay,
                onTap: () => Navigator.pushNamed(
                  context,
                  RouteNames.checkout,
                  arguments: {
                    'cook': widget.cook ?? MockData.sunita,
                    'cart': {
                      for (final l in items) l.dish.name: l.qty,
                    },
                    'total': subtotal,
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── header ───────────────────────────

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.itemCount});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 16.w, 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.ink,
            iconSize: 22.sp,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your cart',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.5,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  itemCount == 0
                      ? 'No items yet'
                      : '$itemCount item${itemCount == 1 ? '' : 's'} · review and checkout',
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

// ─────────────────────── cook group card ──────────────────────

class _CookGroupCard extends StatelessWidget {
  const _CookGroupCard({
    required this.cookName,
    required this.lines,
    required this.onInc,
    required this.onDec,
  });
  final String cookName;
  final List<CartLine> lines;
  final void Function(String dishName) onInc;
  final void Function(String dishName) onDec;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          // Cook header strip (cream chip-on-card)
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cookName
                        .split(' ')
                        .take(2)
                        .map((s) => s.isNotEmpty ? s[0] : '')
                        .join(),
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cookName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Home Kitchen · FSSAI Basic',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 12.sp, color: AppColors.inkSoft),
                      SizedBox(width: 4.w),
                      Text(
                        '28 min',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.line),
          // Dish lines
          for (var i = 0; i < lines.length; i++) ...[
            _LineTile(
              line: lines[i],
              onInc: () => onInc(lines[i].dish.name),
              onDec: () => onDec(lines[i].dish.name),
            ),
            if (i < lines.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Divider(height: 1, color: AppColors.line),
              ),
          ],
        ],
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({
    required this.line,
    required this.onInc,
    required this.onDec,
  });
  final CartLine line;
  final VoidCallback onInc;
  final VoidCallback onDec;

  @override
  Widget build(BuildContext context) {
    final d = line.dish;
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      child: Row(
        children: [
          // Food photo (60×60, 14r)
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              width: 60.w,
              height: 60.w,
              child: d.image != null
                  ? CachedNetworkImage(
                      imageUrl: d.image!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Shimmer.fromColors(
                        baseColor: AppColors.line,
                        highlightColor: Colors.white,
                        child: Container(color: AppColors.line),
                      ),
                      errorWidget: (_, _, _) => _fallback(d),
                    )
                  : _fallback(d),
            ),
          ),
          SizedBox(width: 12.w),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    letterSpacing: -.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${line.lineTotal}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '(₹${d.price} × ${line.qty})',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Ink stepper (same DNA as the dish card)
          _LineStepper(qty: line.qty, onInc: onInc, onDec: onDec),
        ],
      ),
    );
  }

  Widget _fallback(Dish d) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: d.heroGradient,
          ),
        ),
        child: Center(
          child: Text(d.emoji, style: TextStyle(fontSize: 26.sp)),
        ),
      );
}

class _LineStepper extends StatelessWidget {
  const _LineStepper({
    required this.qty,
    required this.onInc,
    required this.onDec,
  });
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onDec,
            child: SizedBox(
              width: 28.w,
              height: 30.h,
              child: Icon(
                qty == 1
                    ? Icons.delete_outline_rounded
                    : Icons.remove_rounded,
                color: Colors.white,
                size: 15.sp,
              ),
            ),
          ),
          SizedBox(
            width: 20.w,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (c, a) =>
                    FadeTransition(opacity: a, child: c),
                child: Text(
                  '$qty',
                  key: ValueKey(qty),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onInc,
            child: SizedBox(
              width: 28.w,
              height: 30.h,
              child: Icon(Icons.add_rounded,
                  color: Colors.white, size: 15.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── note card ───────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded,
                  color: AppColors.ink, size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                'Cooking instructions',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: GoogleFonts.inter(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TextField(
            onChanged: onChanged,
            minLines: 2,
            maxLines: 4,
            cursorColor: AppColors.primary,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppColors.ink,
              height: 1.5,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'e.g. less oil, no onion, mild spice…',
              hintStyle: GoogleFonts.inter(
                fontSize: 13.sp,
                color: AppColors.muted,
                height: 1.5,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 4.h),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── bill card ───────────────────────────

class _BillCard extends StatelessWidget {
  const _BillCard({
    required this.subtotal,
    required this.delivery,
    required this.taxes,
    required this.total,
  });
  final int subtotal;
  final int delivery;
  final int taxes;
  final int total;
  @override
  Widget build(BuildContext context) {
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
              Text(
                'BILL DETAILS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _row('Item total', '₹$subtotal'),
          SizedBox(height: 8.h),
          _row('Delivery', '₹$delivery'),
          SizedBox(height: 8.h),
          _row('Taxes & charges', '₹$taxes'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 11.h),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To pay',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '₹$total',
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
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              color: AppColors.inkSoft,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      );
}

// ─────────────────────── protection ribbon ──────────────────────

class _ProtectionRibbon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_rounded,
              color: AppColors.secondary, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 11.5.sp,
                  color: AppColors.secondary,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                    text: 'Padosi Protection. ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: "Full refund if it doesn't arrive or isn't right.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── sticky checkout bar ────────────────────

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.items,
    required this.total,
    required this.onTap,
  });
  final int items;
  final int total;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: .08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 6.w, 10.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'To pay',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '₹$total',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -.4,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: onTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Checkout',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 17.sp),
                      ],
                    ),
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

// ─────────────────────────── empty state ───────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84.w,
              height: 84.w,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('🛒', style: TextStyle(fontSize: 38.sp)),
            ),
            SizedBox(height: 18.h),
            Text(
              'Your cart is empty',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -.4,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Browse nearby kitchens and add\nfresh home-cooked dishes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5.sp,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(99.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(99.r),
                onTap: () => Navigator.maybePop(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 12.h),
                  child: Text(
                    'Browse kitchens',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
