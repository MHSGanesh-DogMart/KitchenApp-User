import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../controllers/address_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/order_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/services/toast_service.dart';
import '../../../models/address.dart';
import '../../../models/cart.dart';

/// Mockups 16 + 18 merged — Your cart **and** checkout in ONE screen.
///
/// Backed by the server-side [CartController]: items, the delivery/pickup
/// toggle, the coupon, and the whole bill all come from the backend. Address
/// and payment are selectable UI for now (wired fully with the Orders API).
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _note = '';
  late final Razorpay _razorpay;
  String? _pendingOrderId; // our backend order id awaiting payment verification
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _init();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  /// Step 1: validate cart + create Razorpay order, then open the sheet.
  Future<void> _placeOrder() async {
    if (_placing) return;
    setState(() => _placing = true);
    final cart = CartController.instance;
    final addr = cart.selectedAddress;
    final fulfillment = cart.fulfillment;

    final result = await OrderController.instance.checkout(
      fulfillment: fulfillment,
      addressId: fulfillment == 'delivery' ? addr?.id : null,
      note: _note,
      lat: addr?.lat,
      lng: addr?.lng,
    );
    if (!mounted) return;
    setState(() => _placing = false);
    if (result == null) return; // checkout toasts the reason (e.g. out of range)

    _pendingOrderId = result.orderId;
    _razorpay.open({
      'key': result.keyId,
      'order_id': result.razorpayOrderId,
      'amount': result.amount,
      'currency': result.currency,
      'name': 'Padosi',
      'description': 'Order payment',
      'timeout': 300,
    });
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse r) async {
    final orderId = _pendingOrderId;
    if (orderId == null) return;
    final order = await OrderController.instance.verify(
      orderId: orderId,
      razorpayPaymentId: r.paymentId ?? '',
      razorpayOrderId: r.orderId ?? '',
      razorpaySignature: r.signature ?? '',
    );
    if (!mounted) return;
    if (order != null) {
      await CartController.instance.refresh(); // cart is cleared server-side
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        RouteNames.orderPlaced,
        arguments: {'order': order},
      );
    }
  }

  void _onPaymentError(PaymentFailureResponse r) {
    ToastService.error(r.message ?? 'Payment failed or cancelled');
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    ToastService.info('Selected ${r.walletName ?? 'wallet'}');
  }

  Future<void> _init() async {
    // Default the cart location to the saved home GPS, then load the cart.
    CartController.instance.loadHomeLocationIfNeeded();
    await CartController.instance.refresh();
    // Load saved addresses; auto-select the default one (overrides home GPS).
    await AddressController.instance.fetch();
    final def = AddressController.instance.defaultAddress;
    if (def != null && CartController.instance.selectedAddress == null) {
      await CartController.instance.setSelectedAddress(def);
    }
  }

  bool _outOfRangeHandled = false;

  Future<void> _setMode(String mode) =>
      CartController.instance.setFulfillment(mode);

  /// When delivery is out of the kitchen's radius, pop a clear dialog once
  /// offering to switch to pickup or change the address.
  void _maybeShowOutOfRange(CartData data) {
    final blocked =
        data.fulfillment != 'pickup' && !data.serviceable && !data.isEmpty;
    if (blocked && !_outOfRangeHandled) {
      _outOfRangeHandled = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showOutOfRangeDialog(data.serviceMessage),
      );
    } else if (!blocked) {
      _outOfRangeHandled = false;
    }
  }

  Future<void> _showOutOfRangeDialog(String? message) async {
    if (!mounted) return;
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(22.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_off_rounded,
                  color: AppColors.primary,
                  size: 26.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Delivery not available here',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -.3,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message ??
                    'This kitchen doesn\'t deliver to your location. Switch to pickup or choose a closer address.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => Navigator.pop(ctx, 'pickup'),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      child: Text(
                        'Switch to pickup',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, 'address'),
                  child: Text(
                    'Change address',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (choice == 'pickup') {
      await CartController.instance.setFulfillment('pickup');
    } else if (choice == 'address') {
      await _chooseAddress();
    }
  }

  /// Bottom sheet to pick a saved address or add a new one.
  Future<void> _chooseAddress() async {
    final picked = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _AddressPickerSheet(),
    );
    if (!mounted) return;
    if (picked == 'add') {
      final addr = await Navigator.pushNamed(context, RouteNames.addAddress);
      if (addr is Address) {
        await CartController.instance.setSelectedAddress(addr);
      }
    } else if (picked is Address) {
      await CartController.instance.setSelectedAddress(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CartController>();
    final data = controller.cart;
    final bill = data.bill;
    final isEmpty = data.isEmpty;
    final loading = controller.loading && isEmpty;
    final isPickup = data.fulfillment == 'pickup';
    final blockedByRadius = !isPickup && !data.serviceable && !isEmpty;
    _maybeShowOutOfRange(data);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(itemCount: data.itemCount),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : isEmpty
                      ? const _EmptyState()
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 150.h),
                          children: [
                            // ── Items ──
                            _CookGroupCard(
                              kitchenName: data.kitchen?.name ?? 'Your kitchen',
                              etaMins: data.kitchen?.etaMins ?? 28,
                              items: data.items,
                              onInc: CartController.instance.increment,
                              onDec: CartController.instance.decrement,
                            ),
                            SizedBox(height: 12.h),
                            _NoteCard(
                              value: _note,
                              onChanged: (v) => setState(() => _note = v),
                            ),

                            // ── Address ──
                            SizedBox(height: 18.h),
                            _SectionLabel(
                              isPickup ? 'PICKUP FROM' : 'DELIVER TO',
                            ),
                            SizedBox(height: 8.h),
                            if (isPickup)
                              _RowCard(
                                icon: Icons.storefront_rounded,
                                bg: AppColors.primarySoft,
                                fg: AppColors.primary,
                                title: data.kitchen?.name ?? 'Kitchen',
                                sub: 'Collect at the kitchen',
                                action: null,
                                onAction: () {},
                              )
                            else
                              _RowCard(
                                icon: Icons.place_rounded,
                                bg: AppColors.primarySoft,
                                fg: AppColors.primary,
                                title:
                                    controller.selectedAddress?.label ??
                                    'Add a delivery address',
                                sub:
                                    controller.selectedAddress?.summary ??
                                    'Tap to pick on the map',
                                action: controller.selectedAddress == null
                                    ? 'Add'
                                    : 'Change',
                                onAction: _chooseAddress,
                              ),

                            // ── Delivery / Pickup ──
                            SizedBox(height: 18.h),
                            _SectionLabel('HOW SHOULD WE GET IT TO YOU?'),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _ModeCard(
                                    selected: !isPickup,
                                    icon: Icons.delivery_dining_rounded,
                                    title: 'Delivery',
                                    sub: '${data.kitchen?.etaMins ?? 28} min',
                                    foot: !isPickup
                                        ? (bill.deliveryFee == 0
                                              ? 'FREE'
                                              : '₹${bill.deliveryFee.round()}')
                                        : 'Delivery',
                                    onTap: () => _setMode('delivery'),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _ModeCard(
                                    selected: isPickup,
                                    icon: Icons.takeout_dining_rounded,
                                    title: 'Pickup',
                                    sub: 'Ready soon',
                                    foot: 'No fee',
                                    footHighlight: true,
                                    onTap: () => _setMode('pickup'),
                                  ),
                                ),
                              ],
                            ),
                            if (blockedByRadius) ...[
                              SizedBox(height: 10.h),
                              _Warning(
                                data.serviceMessage ??
                                    'This kitchen doesn\'t deliver to your location. '
                                        'Switch to Pickup to continue.',
                              ),
                            ],

                            // ── Payment + coupon ──
                            SizedBox(height: 18.h),

                            // SizedBox(height: 10.h),
                            _RowCard(
                              icon: Icons.local_offer_rounded,
                              bg: AppColors.secondarySoft,
                              fg: AppColors.secondary,
                              title: bill.couponCode == null
                                  ? 'Apply coupon'
                                  : 'Coupon ${bill.couponCode} applied',
                              sub: bill.couponCode == null
                                  ? 'See available offers'
                                  : (bill.discount > 0
                                        ? 'You saved ₹${bill.discount.round()}'
                                        : (data.couponError ?? 'Applied')),
                              action: bill.couponCode == null
                                  ? 'Apply'
                                  : 'Remove',
                              onAction: () async {
                                if (bill.couponCode != null) {
                                  await CartController.instance.removeCoupon();
                                  return;
                                }
                                await Navigator.pushNamed(
                                  context,
                                  RouteNames.coupons,
                                );
                              },
                            ),

                            // ── Bill ──
                            SizedBox(height: 18.h),
                            _SectionLabel('BILL DETAILS'),
                            SizedBox(height: 8.h),
                            _BillCard(bill: bill),
                            SizedBox(height: 12.h),
                            _ProtectionRibbon(),
                          ],
                        ),
                ),
              ],
            ),
          ),
          if (!isEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _PayBar(
                total: bill.grandTotal.round(),
                enabled: !blockedByRadius && !_placing,
                onTap: _placeOrder,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── header ───────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.itemCount});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 16.w, 6.h),
      child: Row(
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
                      : 'Review · confirm · place your order',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        label,
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

class _Warning extends StatelessWidget {
  const _Warning(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.error.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 17.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11.5.sp,
                color: AppColors.error,
                height: 1.4,
              ),
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
              Icon(Icons.edit_note_rounded, color: AppColors.ink, size: 18.sp),
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

// ─────────────────────── cook group card ──────────────────────

class _CookGroupCard extends StatelessWidget {
  const _CookGroupCard({
    required this.kitchenName,
    required this.etaMins,
    required this.items,
    required this.onInc,
    required this.onDec,
  });
  final String kitchenName;
  final int etaMins;
  final List<CartItemDto> items;
  final void Function(String menuItemId) onInc;
  final void Function(String menuItemId) onDec;

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
                    kitchenName
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
                        kitchenName,
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
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12.sp,
                        color: AppColors.inkSoft,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$etaMins min',
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
          for (var i = 0; i < items.length; i++) ...[
            _LineTile(
              item: items[i],
              onInc: () => onInc(items[i].menuItemId),
              onDec: () => onDec(items[i].menuItemId),
            ),
            if (i < items.length - 1)
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
    required this.item,
    required this.onInc,
    required this.onDec,
  });
  final CartItemDto item;
  final VoidCallback onInc;
  final VoidCallback onDec;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              width: 60.w,
              height: 60.w,
              child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Shimmer.fromColors(
                        baseColor: AppColors.line,
                        highlightColor: Colors.white,
                        child: Container(color: AppColors.line),
                      ),
                      errorWidget: (_, _, _) => _fallback(),
                    )
                  : _fallback(),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
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
                      '₹${item.lineTotal.round()}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '(₹${item.price.round()} × ${item.qty})',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                if (!item.isAvailable) ...[
                  SizedBox(height: 3.h),
                  Text(
                    'Currently unavailable',
                    style: GoogleFonts.inter(
                      fontSize: 10.5.sp,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _LineStepper(qty: item.qty, onInc: onInc, onDec: onDec),
        ],
      ),
    );
  }

  Widget _fallback() => Container(
    color: AppColors.cream,
    alignment: Alignment.center,
    child: Icon(
      Icons.restaurant_rounded,
      color: AppColors.primary,
      size: 24.sp,
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
                qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
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
              child: Icon(Icons.add_rounded, color: Colors.white, size: 15.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── row card ───────────────────────────

class _RowCard extends StatelessWidget {
  const _RowCard({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.title,
    required this.sub,
    required this.action,
    required this.onAction,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String sub;
  final String? action;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: action == null ? null : onAction,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 19.sp, color: fg),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        letterSpacing: -.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sub,
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
              if (action != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text(
                    action!,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
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

// ─────────────────────────── mode card ───────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.sub,
    required this.foot,
    this.footHighlight = false,
    required this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String sub;
  final String foot;
  final bool footHighlight;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: selected ? AppColors.ink : AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: .12)
                      : AppColors.cream,
                  borderRadius: BorderRadius.circular(11.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 19.sp,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.ink,
                  letterSpacing: -.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                sub,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: selected
                      ? Colors.white.withValues(alpha: .7)
                      : AppColors.muted,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: footHighlight
                      ? AppColors.success.withValues(alpha: .15)
                      : (selected
                            ? Colors.white.withValues(alpha: .12)
                            : AppColors.cream),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  foot,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: footHighlight
                        ? AppColors.success
                        : (selected ? Colors.white : AppColors.ink),
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

// ─────────────────────────── bill card ───────────────────────────

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill});
  final CartBill bill;
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
          _row('Item total', '₹${bill.itemTotal.round()}'),
          if (bill.discount > 0) ...[
            SizedBox(height: 8.h),
            _row(
              'Coupon discount${bill.couponCode != null ? ' (${bill.couponCode})' : ''}',
              '− ₹${bill.discount.round()}',
              positive: true,
            ),
          ],
          SizedBox(height: 8.h),
          _row(
            'Delivery',
            bill.deliveryFee == 0 ? 'FREE' : '₹${bill.deliveryFee.round()}',
            positive: bill.deliveryFee == 0,
          ),
          SizedBox(height: 8.h),
          _row('Taxes & charges', '₹${bill.taxesCharges.round()}'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
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
                '₹${bill.grandTotal.round()}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22.sp,
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

  Widget _row(String label, String value, {bool positive = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.inkSoft),
        ),
      ),
      Text(
        value,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: positive ? AppColors.success : AppColors.ink,
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
          Icon(Icons.shield_rounded, color: AppColors.secondary, size: 18.sp),
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

// ─────────────────────── sticky pay bar ────────────────────────

class _PayBar extends StatelessWidget {
  const _PayBar({
    required this.total,
    required this.onTap,
    this.enabled = true,
  });
  final int total;
  final VoidCallback onTap;
  final bool enabled;
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
          padding: EdgeInsets.all(8.w),
          child: Material(
            color: enabled ? AppColors.primary : AppColors.line,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: enabled ? onTap : null,
              child: Container(
                height: 52.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: enabled ? Colors.white : AppColors.muted,
                      size: 17.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Place order',
                      style: GoogleFonts.spaceGrotesk(
                        color: enabled ? Colors.white : AppColors.muted,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹$total',
                      style: GoogleFonts.spaceGrotesk(
                        color: enabled ? Colors.white : AppColors.muted,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: enabled ? Colors.white : AppColors.muted,
                      size: 17.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── address picker sheet ──────────────────

class _AddressPickerSheet extends StatelessWidget {
  const _AddressPickerSheet();
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AddressController.instance,
      builder: (context, _) {
        final list = AddressController.instance.addresses;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Delivery address',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 12.h),
                ...list.map(
                  (a) => InkWell(
                    borderRadius: BorderRadius.circular(14.r),
                    onTap: () => Navigator.pop(context, a),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.place_rounded,
                            color: AppColors.primary,
                            size: 18.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      a.label,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    if (a.isDefault) ...[
                                      SizedBox(width: 6.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 1.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySoft,
                                          borderRadius: BorderRadius.circular(
                                            99.r,
                                          ),
                                        ),
                                        child: Text(
                                          'Default',
                                          style: GoogleFonts.inter(
                                            fontSize: 9.5.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  a.summary,
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
                  ),
                ),
                if (list.isNotEmpty)
                  Divider(height: 18.h, color: AppColors.line),
                InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () => Navigator.pop(context, 'add'),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Add a new address',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
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
      },
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
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
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
