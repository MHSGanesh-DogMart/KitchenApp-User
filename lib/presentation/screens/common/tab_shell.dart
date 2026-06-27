import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:padosi_food/presentation/screens/padosi/profile_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/padosi/cart_fab.dart';
import '../../widgets/padosi/padosi_floating_nav.dart';
import '../community/community_screen.dart';
import '../discover/discover_screen.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';

/// 5-tab shell with the floating dark pill nav from the new mockups.
/// The nav floats on top of each tab's content (NOT as Scaffold.bottomNav),
/// so screens reserve ~110.h bottom padding for the pill.
class TabShell extends StatefulWidget {
  const TabShell({super.key, this.initialIndex = 0});
  final int initialIndex;
  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  late int _index = widget.initialIndex;

  static const _tabs = <Widget>[
    HomeScreen(),
    DiscoverScreen(),
    CommunityScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _tabs),
          // Compact cart FAB — small icon + badge count, top-right of
          // the nav pill. Keeps the tab screens clean (the full
          // GlobalCartBar would clash with the floating nav).
          Positioned(right: 16.w, bottom: 90.h, child: const CartFab()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PadosiFloatingNav(
              currentIndex: _index,
              onSelect: (i) => setState(() => _index = i),
            ),
          ),
        ],
      ),
    );
  }
}
