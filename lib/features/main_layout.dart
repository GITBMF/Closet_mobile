import 'package:flutter/material.dart';

import '../core/widgets/closet_bottom_nav.dart';
import 'cliente/collections/collections_screen.dart';
import 'cliente/dressing/dressing_screen.dart';
import 'cliente/espace/espace_screen.dart';
import 'cliente/selection/selection_screen.dart';
import 'cliente/wishlist/wishlist_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  final String? initialCategory;

  const MainLayout({
    super.key,
    this.initialIndex = 0,
    this.initialCategory,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    _screens = [
      Navigator(
        key: GlobalKey<NavigatorState>(),
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const DressingScreen(),
          );
        },
      ),
      CollectionsScreen(initialCategory: widget.initialCategory),
      const WishlistScreen(),
      const SelectionScreen(),
      const EspaceScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClosetBottomNav(
        indexActif: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
