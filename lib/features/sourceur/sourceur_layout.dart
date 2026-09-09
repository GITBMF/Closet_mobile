import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/closet_l10n.dart';
import '../../core/widgets/closet_bottom_nav.dart';

/// Indices des onglets sourceur, dans l'ordre de [ClosetBottomNav.itemsSourceur].
abstract final class OngletSourceur {
  static const depots = 0;
  static const confier = 1;
  static const gains = 2;
  static const espace = 3;
}

/// Change d'onglet via le shell, sans recréer une page (évite les GlobalKey
/// dupliquées de `context.go` entre branches déjà montées).
void allerOngletSourceur(BuildContext context, int index) {
  final shell = StatefulNavigationShell.maybeOf(context);
  if (shell != null) {
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
    return;
  }
  context.go(switch (index) {
    OngletSourceur.depots => '/sourceur/pieces',
    OngletSourceur.confier => '/sourceur/nouvelle',
    OngletSourceur.gains => '/sourceur/revenus',
    _ => '/sourceur/espace',
  });
}

/// Shell de l'espace sourceur.
///
/// La maquette ne décrit pas de barre de navigation propre à cet espace : elle
/// réutilise donc [ClosetBottomNav], relevé sur `13:1182`, avec les entrées du
/// parcours vendeur. Cela évite d'entretenir deux barres divergentes, ce qui
/// était le cas jusqu'ici.
class SourceurLayout extends ConsumerWidget {
  const SourceurLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      extendBody: false,
      bottomNavigationBar: ClosetBottomNav(
        items: ClosetBottomNav.itemsSourceurPour(ClosetL10n.of(context)),
        indexActif: navigationShell.currentIndex,
        onTap: (index) => allerOngletSourceur(context, index),
      ),
    );
  }
}
