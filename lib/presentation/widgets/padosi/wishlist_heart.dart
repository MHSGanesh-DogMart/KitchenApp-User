import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../controllers/wishlist_controller.dart';
import '../../../core/constants/app_colors.dart';

/// Self-contained wishlist heart. Manages its own optimistic state and
/// calls the wishlist API on tap. Drop it anywhere a favourite toggle is
/// needed for a kitchen or dish.
class WishlistHeart extends StatefulWidget {
  const WishlistHeart({
    super.key,
    required this.type, // 'kitchen' | 'dish'
    required this.targetId,
    required this.initial,
    this.diameter = 36,
    this.iconSize = 17,
  });

  final String type;
  final String targetId;
  final bool initial;
  final double diameter;
  final double iconSize;

  @override
  State<WishlistHeart> createState() => _WishlistHeartState();
}

class _WishlistHeartState extends State<WishlistHeart> {
  late bool _on = widget.initial;
  bool _busy = false;

  @override
  void didUpdateWidget(WishlistHeart old) {
    super.didUpdateWidget(old);
    if (old.targetId != widget.targetId) _on = widget.initial;
  }

  Future<void> _toggle() async {
    if (_busy || widget.targetId.isEmpty) return;
    final prev = _on;
    setState(() {
      _busy = true;
      _on = !prev; // optimistic
    });
    final result = await WishlistController.instance
        .toggle(widget.type, widget.targetId, prev);
    if (!mounted) return;
    setState(() {
      _on = result;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: widget.diameter.w,
        height: widget.diameter.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          _on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: _on ? AppColors.primary : AppColors.ink,
          size: widget.iconSize.sp,
        ),
      ),
    );
  }
}
