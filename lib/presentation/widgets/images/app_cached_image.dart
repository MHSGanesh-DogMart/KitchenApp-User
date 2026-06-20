import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../states/app_shimmer.dart';

class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    if (url == null || url!.isEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: _errorBox(),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) =>
            placeholder ?? ShimmerBox(width: width ?? double.infinity, height: height ?? 120, radius: 0),
        errorWidget: (_, _, _) => errorWidget ?? _errorBox(),
      ),
    );
  }

  Widget _errorBox() => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      );
}
