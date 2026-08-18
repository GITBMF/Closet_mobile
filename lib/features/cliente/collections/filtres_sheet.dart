import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_sections.dart';
import 'collections_screen.dart';

/// Tailles proposées par la maquette `14:1514`.
const List<String> taillesDisponibles = ['XS', 'S', 'M', 'L', 'XL'];

/// États proposés par la maquette `14:1514`.
const List<String> etatsDisponibles = [
  'Neuf',
  'Excellent',
  'Très bon état',
  'Bon état',
];

/// Bornes de la fourchette de prix, en FCFA.
const double prixMinimum = 10000;
const double prixMaximum = 45000;

/// Ouvre le panneau de filtres — transcription de la maquette `14:1514`.
///
/// Feuille remontante à coins supérieurs très arrondis (56), posée sur les
/// collections. Elle écrit directement dans les providers de filtrage, donc
/// la grille se met à jour derrière elle.
Future<void> afficherFiltres(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _FiltresSheet(),
  );
}

class _FiltresSheet extends ConsumerWidget {
  const _FiltresSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final univers = ref.watch<String>(selectedUniverseProvider);
    final taille = ref.watch<String?>(filterSizeProvider);
    final etat = ref.watch<String?>(filterConditionProvider);
    final fourchette = ref.watch<RangeValues?>(filterPriceRangeProvider) ??
        const RangeValues(prixMinimum, prixMaximum);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => DecoratedBox(
        decoration: const BoxDecoration(
          color: ClosetColors.beige,
          borderRadius: BorderRadius.vertical(top: Radius.circular(56)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(23, AppSpacing.p20, 23, 0),
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: ClosetColors.fond300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.p20),
            ClosetEnTeteSection(
              titre: 'Affiner ma recherche',
              lien: 'tout réinitialiser',
              onLien: () {
                ref.read(filterBrandProvider.notifier).setBrand(null);
                ref.read(filterSizeProvider.notifier).setSize(null);
                ref.read(filterConditionProvider.notifier).setCondition(null);
                ref.read(filterPriceRangeProvider.notifier).setRange(null);
                ref
                    .read<UniverseNotifier>(selectedUniverseProvider.notifier)
                    .setUniverse(CollectionsScreen.universes.first);
              },
            ),
            const SizedBox(height: AppSpacing.p24),
            const ClosetSurtitre('explorer par univers'),
            const SizedBox(height: AppSpacing.p16),
            Wrap(
              spacing: AppSpacing.p12,
              runSpacing: AppSpacing.p12,
              children: [
                for (final u in CollectionsScreen.universes)
                  ClosetChip(
                    label: u,
                    isActive: u == univers,
                    onTap: () => ref
                        .read<UniverseNotifier>(
                            selectedUniverseProvider.notifier)
                        .setUniverse(u),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.p24),
            const ClosetSurtitre('taille'),
            const SizedBox(height: AppSpacing.p16),
            Wrap(
              spacing: AppSpacing.p12,
              runSpacing: AppSpacing.p12,
              children: [
                for (final t in taillesDisponibles)
                  ClosetChip(
                    label: t,
                    isActive: t == taille,
                    // Retaper la taille active la retire : c'est le seul
                    // moyen de revenir à « toutes tailles » sans passer par
                    // la réinitialisation globale.
                    onTap: () => ref
                        .read(filterSizeProvider.notifier)
                        .setSize(t == taille ? null : t),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.p24),
            const ClosetSurtitre('état de la pièce'),
            const SizedBox(height: AppSpacing.p16),
            Wrap(
              spacing: AppSpacing.p12,
              runSpacing: AppSpacing.p12,
              children: [
                for (final e in etatsDisponibles)
                  ClosetChip(
                    label: e,
                    isActive: e == etat,
                    onTap: () => ref
                        .read(filterConditionProvider.notifier)
                        .setCondition(e == etat ? null : e),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.p24),
            const ClosetSurtitre('budget'),
            const SizedBox(height: AppSpacing.p8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatPrixFcfa(fourchette.start),
                  style: ClosetTextStyles.prix.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
                Text(
                  formatPrixFcfa(fourchette.end),
                  style: ClosetTextStyles.prix.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: RangeValues(
                fourchette.start.clamp(prixMinimum, prixMaximum),
                fourchette.end.clamp(prixMinimum, prixMaximum),
              ),
              min: prixMinimum,
              max: prixMaximum,
              divisions: 35,
              activeColor: ClosetColors.vert,
              inactiveColor: ClosetColors.ligne,
              labels: RangeLabels(
                formatPrixFcfa(fourchette.start),
                formatPrixFcfa(fourchette.end),
              ),
              onChanged: (v) =>
                  ref.read(filterPriceRangeProvider.notifier).setRange(v),
            ),
            const SizedBox(height: AppSpacing.p20),
            SizedBox(
              height: 44,
              child: Material(
                color: ClosetColors.vert,
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  onTap: () => Navigator.of(context).pop(),
                  child: Center(
                    child: Text(
                      'Voir les pièces',
                      style: ClosetTextStyles.bouton.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.p24 + MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}
