import 'package:flutter/material.dart';

import 'app_cached_image.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.url,
    this.size = 44,
    this.fallbackText,
  });

  final String? url;
  final double size;
  final String? fallbackText;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
        child: Text(
          (fallbackText ?? '?').characters.first.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return AppCachedImage(
      url: url,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size),
    );
  }
}
