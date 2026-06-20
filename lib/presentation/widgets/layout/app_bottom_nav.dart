import 'package:flutter/material.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class AppBottomNavShell extends StatefulWidget {
  const AppBottomNavShell({
    super.key,
    required this.items,
    required this.children,
    this.initialIndex = 0,
    this.onTabChanged,
  }) : assert(items.length == children.length);

  final List<AppBottomNavItem> items;
  final List<Widget> children;
  final int initialIndex;
  final ValueChanged<int>? onTabChanged;

  @override
  State<AppBottomNavShell> createState() => _AppBottomNavShellState();
}

class _AppBottomNavShellState extends State<AppBottomNavShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: widget.children),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          widget.onTabChanged?.call(i);
        },
        destinations: widget.items
            .map(
              (it) => NavigationDestination(
                icon: Icon(it.icon),
                selectedIcon: Icon(it.activeIcon),
                label: it.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
