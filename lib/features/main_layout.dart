import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/closet_l10n.dart';
import '../core/widgets/closet_bottom_nav.dart';
import '../core/widgets/closet_shell_transition.dart';
import '../core/widgets/spotlight_showcase.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final etapes = etapesVisiteCliente(l10n);

    ref.listen(spotlightTourProvider, (precedent, suivant) {
      if (!suivant.isActive) return;
      if (suivant.currentStep < 0 || suivant.currentStep >= etapes.length) {
        return;
      }
      final dest = etapes[suivant.currentStep].route;
      if (dest != null && GoRouterState.of(context).uri.path != dest) {
        context.go(dest);
      }
    });

    final tour = ref.watch(spotlightTourProvider);
    final faite = ref.watch(visiteGuideeFaiteProvider);
    if (!tour.isActive && faite.value == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (ref.read(spotlightTourProvider).isActive) return;
        if (ref.read(visiteGuideeFaiteProvider).value != false) return;
        ref.read(spotlightTourProvider.notifier).startTour();
      });
    }

    return SpotlightShowcase(
      steps: etapes,
      child: Scaffold(
        body: ClosetShellTransition(
          index: navigationShell.currentIndex,
          child: navigationShell,
        ),
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
