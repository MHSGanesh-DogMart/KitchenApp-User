import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../states/no_internet_banner.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.showInternetBanner = true,
    this.padding,
    this.systemUiOverlayStyle,
    this.dismissKeyboardOnTap = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool showInternetBanner;
  final EdgeInsetsGeometry? padding;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final bool dismissKeyboardOnTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlay = systemUiOverlayStyle ??
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);

    Widget content = SafeArea(
      top: safeAreaTop,
      bottom: safeAreaBottom,
      child: Column(
        children: [
          if (showInternetBanner) const NoInternetBanner(),
          Expanded(
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: body,
            ),
          ),
        ],
      ),
    );

    if (dismissKeyboardOnTap) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: content,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: content,
      ),
    );
  }
}
