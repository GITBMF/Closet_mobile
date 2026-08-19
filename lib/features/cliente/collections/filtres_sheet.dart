import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../data/repositories/catalog_repository.dart';
import 'collections_screen.dart';

/// Bornes de la fourchette de prix, en FCFA — transmises au backend via
/// `min_price` / `max_price` de `GET /pieces`.
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
    final maison = ref.watch<String?>(filterBrandProvider);
    final maisons = ref.watch(maisonsProvider);
    final prixMax = ref.watch<double?>(filterPriceProvider) ?? prixMaximum;
    final nombrePieces = ref.watch(filteredArticlesProvider).value?.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(56)),
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
              lien: 'Tout réinitialiser',
              onLien: () {
                ref.read(filterBrandProvider.notifier).setBrand(null);
                ref.read(filterPriceProvider.notifier).setPrice(null);
                ref
                    .read<UniverseNotifier>(selectedUniverseProvider.notifier)
                    .setUniverse('');
              },
            ),
            const SizedBox(height: AppSpacing.p24),
            if (universCatalogue(ref).isNotEmpty) ...[
              const ClosetSurtitre('Explorer par univers'),
              const SizedBox(height: AppSpacing.p16),
              Wrap(
                spacing: AppSpacing.p12,
                runSpacing: AppSpacing.p12,
                children: [
                  for (final u in universCatalogue(ref))
                    ClosetChip(
                      label: u,
                      isActive: u == univers,
                      onTap: () => ref
                          .read<UniverseNotifier>(
                              selectedUniverseProvider.notifier)
                          .setUniverse(u == univers ? '' : u),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.p24),
            ],
            if (maisons.value?.isNotEmpty ?? false) ...[
              const ClosetSurtitre('Maison'),
              const SizedBox(height: AppSpacing.p16),
              Wrap(
                spacing: AppSpacing.p12,
                runSpacing: AppSpacing.p12,
                children: [
                  for (final m in maisons.value!)
                    ClosetChip(
                      label: m,
                      isActive: m == maison,
                      onTap: () => ref
                          .read(filterBrandProvider.notifier)
                          .setBrand(m == maison ? null : m),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.p24),
            ],
            const ClosetSurtitre('Budget'),
            const SizedBox(height: AppSpacing.p8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatPrixFcfa(prixMinimum),
                  style: ClosetTextStyles.prix.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
                Text(
                  formatPrixFcfa(prixMax),
                  style: ClosetTextStyles.prix.copyWith(
                    color: ClosetColors.vert,
                  ),
                ),
              ],
            ),
            Slider(
              value: prixMax.clamp(prixMinimum, prixMaximum),
              min: prixMinimum,
              max: prixMaximum,
              divisions: 35,
              activeColor: ClosetColors.vert,
              inactiveColor: ClosetColors.ligne,
              label: formatPrixFcfa(prixMax),
              onChanged: (v) =>
                  ref.read(filterPriceProvider.notifier).setPrice(v),
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
                      // La maquette porte le compte sur le CTA (« Voir 18
                      // pièces »). Il n'est affiché qu'une fois connu, pour ne
                      // pas annoncer un nombre puis le corriger.
                      nombrePieces == null
                          ? 'Voir les pièces'
                          : nombrePieces == 1
                              ? 'Voir 1 pièce'
                              : 'Voir $nombrePieces pièces',
                      style: ClosetTextStyles.bouton.copyWith(
                        color: ClosetColors.blanc,
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
