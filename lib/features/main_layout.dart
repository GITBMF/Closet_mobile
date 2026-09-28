import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/closet_bottom_nav.dart';
import '../core/widgets/closet_shell_transition.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClosetShellTransition(
        index: navigationShell.currentIndex,
        child: navigationShell,
      ),
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
