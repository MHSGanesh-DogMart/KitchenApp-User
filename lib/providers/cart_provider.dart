import 'package:flutter/foundation.dart';

import '../presentation/screens/padosi/mock/mock_data.dart';

/// Global cart used by the Padosi UI demo.
///
/// Holds a flat list of line items (one dish + qty) plus the owning
/// cook name so the cart screen can group later. Listened by
/// [GlobalCartBar] to render the floating "₹X · N items" bar on every
/// screen.
class CartLine {
  CartLine({
    required this.dish,
    required this.cookName,
    this.qty = 1,
  });
  final Dish dish;
  final String cookName;
  int qty;

  int get lineTotal => dish.price * qty;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartLine> _lines = {}; // key = dish.name

  Map<String, CartLine> get lines => _lines;
  Iterable<CartLine> get values => _lines.values;

  int get itemCount => _lines.values.fold(0, (a, b) => a + b.qty);
  int get total => _lines.values.fold(0, (a, b) => a + b.lineTotal);

  int qtyOf(String dishName) => _lines[dishName]?.qty ?? 0;

  void inc(Dish dish, {required String cookName}) {
    final l = _lines[dish.name];
    if (l == null) {
      _lines[dish.name] = CartLine(dish: dish, cookName: cookName, qty: 1);
    } else {
      l.qty += 1;
    }
    notifyListeners();
  }

  void dec(String dishName) {
    final l = _lines[dishName];
    if (l == null) return;
    l.qty -= 1;
    if (l.qty <= 0) _lines.remove(dishName);
    notifyListeners();
  }

  void addQty(Dish dish, {required String cookName, required int qty}) {
    if (qty <= 0) return;
    final l = _lines[dish.name];
    if (l == null) {
      _lines[dish.name] = CartLine(dish: dish, cookName: cookName, qty: qty);
    } else {
      l.qty += qty;
    }
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
