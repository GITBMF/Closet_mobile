import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/closet_bottom_nav.dart';

/// Shell de l'espace sourceur.
///
/// La maquette ne décrit pas de barre de navigation propre à cet espace : elle
/// réutilise donc [ClosetBottomNav], relevé sur `13:1182`, avec les entrées du
/// parcours vendeur. Cela évite d'entretenir deux barres divergentes, ce qui
/// était le cas jusqu'ici.
class SourceurLayout extends StatelessWidget {
  const SourceurLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: false,
      bottomNavigationBar: ClosetBottomNav(
        items: ClosetBottomNav.itemsSourceur,
        indexActif: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
