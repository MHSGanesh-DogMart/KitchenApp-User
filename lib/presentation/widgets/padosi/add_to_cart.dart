import 'package:flutter/material.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/services/toast_service.dart';
import 'padosi_confirm_dialog.dart';

/// Adds a menu item to the server cart, handling the single-kitchen
/// conflict (409 CART_KITCHEN_CONFLICT) by asking the user whether to
/// clear the existing cart and start fresh from the new kitchen.
///
/// Returns true if the item ended up in the cart.
Future<bool> addToCart(
  BuildContext context,
  String menuItemId, {
  int qty = 1,
  bool silentSuccess = false,
}) async {
  final res = await CartController.instance.addItem(menuItemId, qty: qty);

  if (res.ok) {
    if (!silentSuccess) ToastService.success('Added to cart');
    return true;
  }

  if (res.hasConflict && context.mounted) {
    final c = res.conflict!;
    final confirmed = await PadosiConfirmDialog.show(
      context,
      icon: Icons.remove_shopping_cart_rounded,
      title: 'Start a new cart?',
      message:
          'Your cart already has items from ${c.currentKitchen}. '
          'Clear it to add items from ${c.newKitchen}?',
      confirmLabel: 'Clear & add',
      destructive: true,
    );
    if (confirmed == true) {
      final forced =
          await CartController.instance.addItem(menuItemId, qty: qty, force: true);
      if (forced.ok) {
        if (!silentSuccess) ToastService.success('Added to cart');
        return true;
      }
    }
  }
  return false;
}
