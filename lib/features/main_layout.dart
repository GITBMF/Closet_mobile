import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/closet_l10n.dart';
import '../core/widgets/closet_bottom_nav.dart';
import '../core/widgets/spotlight_showcase.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _routesVisite = [
    '/home',
    '/collections',
    '/wishlist',
    '/selection',
    '/espace',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    ref.listen(spotlightTourProvider, (precedent, suivant) {
      if (!suivant.isActive) return;
      if (suivant.currentStep < 0 ||
          suivant.currentStep >= _routesVisite.length) {
        return;
      }
      final dest = _routesVisite[suivant.currentStep];
      if (GoRouterState.of(context).uri.path != dest) {
        context.go(dest);
      }
    });
    return SpotlightShowcase(
      steps: etapesVisiteCliente(l10n),
      child: Scaffold(
        body: navigationShell,
        extendBody: false,
        bottomNavigationBar: ClosetBottomNav(
          items: ClosetBottomNav.itemsClientePour(l10n),
          indexActif: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
        ),
      ),
    );
  }
}
