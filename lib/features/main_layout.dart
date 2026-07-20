import 'package:flutter/material.dart';

import '../core/widgets/closet_bottom_nav.dart';
import 'cliente/collections/collections_screen.dart';
import 'cliente/dressing/dressing_screen.dart';
import 'cliente/espace/espace_screen.dart';
import 'cliente/selection/selection_screen.dart';
import 'cliente/wishlist/wishlist_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DressingScreen(),
    CollectionsScreen(),
    WishlistScreen(),
    SelectionScreen(),
    EspaceScreen(),
  ];

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
