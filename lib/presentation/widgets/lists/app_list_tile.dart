import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.xs,
      ),
      leading: leading,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle != null
          ? Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis)
          : null,
      onTap: onTap,
    );
  }
}
