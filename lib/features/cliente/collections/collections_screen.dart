import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_layout.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/piece_card.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';
import 'filtres_sheet.dart';

// Notifiers for type-safety under strict-inference
class UniverseNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setUniverse(String val) => state = val;
}

class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounce;

  @override
  String build() {
    ref.onDispose(() => _debounce?.cancel());
    return '';
  }

  /// Saisie : le backend n'est interrogé qu'après une pause.
  void setQuery(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = val.trim();
    });
  }

  /// Validation clavier (Rechercher) : envoi immédiat.
  void appliquerMaintenant(String val) {
    _debounce?.cancel();
    state = val.trim();
  }

  void clear() {
    _debounce?.cancel();
    state = '';
  }
}

class BrandFilterNotifier extends Notifier<Maison?> {
  @override
  Maison? build() => null;
  void setMaison(Maison? val) => state = val;
}

class PrixMinFilterNotifier extends Notifier<double?> {
  @override
  double? build() => null;
  void setPrice(double? val) => state = val;
}

class PrixMaxFilterNotifier extends Notifier<double?> {
  @override
  double? build() => null;
  void setPrice(double? val) => state = val;
}

class TailleFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setTaille(String? val) => state = val;
}

class EtatFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setEtat(String? val) => state = val;
}

final selectedUniverseProvider =
    NotifierProvider<UniverseNotifier, String>(UniverseNotifier.new);
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final filterBrandProvider =
    NotifierProvider<BrandFilterNotifier, Maison?>(BrandFilterNotifier.new);
final filterPrixMinProvider =
    NotifierProvider<PrixMinFilterNotifier, double?>(PrixMinFilterNotifier.new);
final filterPriceProvider =
    NotifierProvider<PrixMaxFilterNotifier, double?>(PrixMaxFilterNotifier.new);
final filterTailleProvider =
    NotifierProvider<TailleFilterNotifier, String?>(TailleFilterNotifier.new);
final filterEtatProvider =
    NotifierProvider<EtatFilterNotifier, String?>(EtatFilterNotifier.new);

/// `GET /pieces` (q, house_id, universe_id, min/max_price) puis filtres
/// locaux sur `size_label` et `condition` — absents de la query API.
final filteredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final universe = ref.watch<String>(selectedUniverseProvider);
  final query = ref.watch<String>(searchQueryProvider);
  final maison = ref.watch<Maison?>(filterBrandProvider);
  final prixMin = ref.watch<double?>(filterPrixMinProvider);
  final prixMax = ref.watch<double?>(filterPriceProvider);
  final taille = ref.watch<String?>(filterTailleProvider);
  final etat = ref.watch<String?>(filterEtatProvider);

  final retenus =
      await ref.watch<CatalogRepository>(catalogRepositoryProvider).getCatalog(
            universe: universe.isEmpty ? null : universe,
            filtres: FiltresCatalogue(
              maisonId: estIdentifiantApi(maison?.id) ? maison!.id : null,
              recherche: query.isEmpty ? null : query,
              prixMin: prixMin,
              prixMax: prixMax,
            ),
          );

  return [
    for (final a in retenus)
      if ((universe.isEmpty || a.correspondUnivers(universe)) &&
          (maison == null || a.correspondMaison(maison.nom)) &&
          (taille == null || a.correspondTaille(taille)) &&
          (etat == null || a.correspondEtat(etat)))
        a,
  ];
});

/// Collections — transcription des maquettes `14:1281` et `16:2260`.
///
/// Titre « Toutes les pièces », bouton de filtres et pilule de tri, barre de
/// recherche en pilule, puces d'univers, puis grille de deux colonnes.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

List<String> universCatalogue(WidgetRef ref) {
  final async = ref.watch(universFiltresProvider);
  return async.maybeWhen(
    data: (liste) => liste,
    orElse: () => const <String>[],
  );
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  late final TextEditingController _recherche;

  @override
  void initState() {
    super.initState();
    _recherche = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  bool get _filtresActifs =>
      ref.watch<String>(searchQueryProvider).isNotEmpty ||
      ref.watch<String>(selectedUniverseProvider).isNotEmpty ||
      ref.watch<Maison?>(filterBrandProvider) != null ||
      ref.watch<double?>(filterPrixMinProvider) != null ||
      ref.watch<double?>(filterPriceProvider) != null ||
      ref.watch<String?>(filterTailleProvider) != null ||
      ref.watch<String?>(filterEtatProvider) != null;

  void _effacerRecherche() {
    _recherche.clear();
    ref.read(searchQueryProvider.notifier).clear();
    setState(() {});
  }

  void _reinitialiserFiltres() {
    _effacerRecherche();
    ref.read(filterBrandProvider.notifier).setMaison(null);
    ref.read(filterPrixMinProvider.notifier).setPrice(null);
    ref.read(filterPriceProvider.notifier).setPrice(null);
    ref.read(filterTailleProvider.notifier).setTaille(null);
    ref.read(filterEtatProvider.notifier).setEtat(null);
    ref.read(selectedUniverseProvider.notifier).setUniverse('');
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = ref.watch(filteredArticlesProvider);
    final marge = ClosetLayout.of(context).gouttiere;
    final universActif = ref.watch(selectedUniverseProvider);
    final categories = universCatalogue(ref);
    final l10n = ClosetL10n.of(context);

    ref.listen<String>(searchQueryProvider, (precedent, suivant) {
      if (_recherche.text != suivant) {
        _recherche.text = suivant;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.p32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.p12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: marge),
                child: _BarreRecherche(
                  controller: _recherche,
                  filtresActifs: _filtresActifs ||
                      _recherche.text.trim().isNotEmpty,
                  onChanged: (v) {
                    setState(() {});
                  },
                  onSubmitted: (v) => ref
                      .read(searchQueryProvider.notifier)
                      .appliquerMaintenant(v),
                  onEffacer: _effacerRecherche,
                  onFiltres: () => _ouvrirFiltres(context),
                ),
              ),
              if (categories.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.p16),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: marge),
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.p8),
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return ClosetChip(
                          label: l10n.toutes,
                          isActive: universActif.isEmpty,
                          onTap: () => ref
                              .read(selectedUniverseProvider.notifier)
                              .setUniverse(''),
                        );
                      }
                      final nom = categories[i - 1];
                      return ClosetChip(
                        label: nom,
                        isActive: nom == universActif,
                        onTap: () => ref
                            .read(selectedUniverseProvider.notifier)
                            .setUniverse(nom == universActif ? '' : nom),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.p16),
              catalogue.when(
                skipLoadingOnReload: true,
                data: (articles) => _Resultats(
                  articles: articles,
                  onReinitialiser: _filtresActifs ? _reinitialiserFiltres : null,
                ),
                loading: () => const SizedBox(
                  height: 280,
                  child: EtatEcran.chargement(),
                ),
                error: (e, _) => SizedBox(
                  height: 280,
                  child: EtatEcran.erreur(
                    erreur: e,
                    onRetry: () => ref.invalidate(filteredArticlesProvider),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.p24),
            ],
          ),
        ),
      ),
    );
  }

  void _ouvrirFiltres(BuildContext context) => afficherFiltres(context);
}

class _Resultats extends StatelessWidget {
  const _Resultats({
    required this.articles,
    this.onReinitialiser,
  });

  final List<Article> articles;
  final VoidCallback? onReinitialiser;

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return ClosetListeVide(
        message: ClosetL10n.of(context).aucunePieceRecherche,
        action: onReinitialiser,
        libelleAction:
            onReinitialiser == null ? null : ClosetL10n.of(context).effacerRecherche,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ClosetLayout.of(context).gouttiere,
          ),
          child: ClosetSurtitre(
            ClosetL10n.of(context).nbPieces(articles.length),
          ),
        ),
        const SizedBox(height: AppSpacing.p16),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ClosetLayout.of(context).gouttiere,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.p12,
              mainAxisSpacing: AppSpacing.p12,
              childAspectRatio: PieceCard.ratioCarteGrille,
            ),
            itemBuilder: (context, i) => ArticleCard(
              article: articles[i],
              onTap: () => context.push('/product/${articles[i].id}'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Barre de recherche : 350 × 45, pilule blanche bordée `#E6E6E6`.
class _BarreRecherche extends StatelessWidget {
  const _BarreRecherche({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onEffacer,
    required this.onFiltres,
    required this.filtresActifs,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onEffacer;
  final VoidCallback onFiltres;
  final bool filtresActifs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        maxLength: 120,
        buildCounter: (
          context, {
          required currentLength,
          required isFocused,
          maxLength,
        }) =>
            null,
        style: ClosetTextStyles.saisie.copyWith(color: context.closetEncre),
        cursorColor: ClosetColors.vert,
        decoration: InputDecoration(
          hintText: ClosetL10n.of(context).rechercherPiece,
          hintStyle: ClosetTextStyles.saisie.copyWith(
            color: ClosetColors.chipTexteInactif,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: ClosetColors.chipTexteInactif,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: ClosetColors.chipTexteInactif,
                  onPressed: onEffacer,
                ),
              IconButton(
                tooltip: 'Filtrer',
                icon: Icon(
                  Icons.tune,
                  size: 18,
                  color: filtresActifs
                      ? ClosetColors.vert
                      : ClosetColors.chipTexteInactif,
                ),
                onPressed: onFiltres,
              ),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          counterText: '',
          filled: true,
          fillColor: context.closetChamp,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p12,
          ),
          border: _bordure(ClosetColors.carteBordure),
          enabledBorder: _bordure(ClosetColors.carteBordure),
          focusedBorder: _bordure(ClosetColors.fond300),
        ),
      ),
    );
  }

  static OutlineInputBorder _bordure(Color couleur) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.bouton),
        borderSide: BorderSide(color: couleur, width: AppStroke.fin),
      );
}
