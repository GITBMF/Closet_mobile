import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/closet_bottom_nav.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: false,
      bottomNavigationBar: ClosetBottomNav(
        items: ClosetBottomNav.itemsCliente,
        indexActif: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
