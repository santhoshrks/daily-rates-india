import 'package:flutter/material.dart';

import 'home_page.dart';
import 'rates_page.dart';
import 'tools/tools_page.dart';

/// Main shell with bottom navigation — Home, Tools, Rates tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ToolsPage(),
    RatesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        indicatorColor: const Color(0xFFE65100).withValues(alpha: 0.15),
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded,
                color: Color(0xFFE65100)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded,
                color: Color(0xFFE65100)),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart_rounded,
                color: Color(0xFFE65100)),
            label: 'Rates',
          ),
        ],
      ),
    );
  }
}

