import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_layout.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/bandeau_defilable.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/piece_card.dart';
import '../../../core/widgets/spotlight_showcase.dart';
import '../../../data/models/article.dart';
import '../../../data/recherche/suggestion_recherche.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/services/historique_recherche_service.dart';
import 'filtres_sheet.dart';
import 'panneau_suggestions.dart';
import 'recherche_providers.dart';

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

final selectedUniverseProvider = NotifierProvider<UniverseNotifier, String>(
  UniverseNotifier.new,
);
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);
final filterBrandProvider = NotifierProvider<BrandFilterNotifier, Maison?>(
  BrandFilterNotifier.new,
);
final filterPrixMinProvider = NotifierProvider<PrixMinFilterNotifier, double?>(
  PrixMinFilterNotifier.new,
);
final filterPriceProvider = NotifierProvider<PrixMaxFilterNotifier, double?>(
  PrixMaxFilterNotifier.new,
);
final filterTailleProvider = NotifierProvider<TailleFilterNotifier, String?>(
  TailleFilterNotifier.new,
);
final filterEtatProvider = NotifierProvider<EtatFilterNotifier, String?>(
  EtatFilterNotifier.new,
);

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

  final retenus = await ref
      .watch<CatalogRepository>(catalogRepositoryProvider)
      .getCatalog(
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
  late final FocusNode _focus;
  bool _champActif = false;

  @override
  void initState() {
    super.initState();
    _recherche = TextEditingController(text: ref.read(searchQueryProvider));
    _focus = FocusNode();
    _focus.addListener(() {
      if (!mounted) return;
      if (_focus.hasFocus) {
        setState(() => _champActif = true);
        return;
      }
      // Laisse le tap d’une puce se terminer avant de replier le panneau.
      Future<void>.delayed(const Duration(milliseconds: 140), () {
        if (mounted && !_focus.hasFocus) {
          setState(() => _champActif = false);
        }
      });
    });
  }

  @override
  void dispose() {
    _focus.dispose();
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

  Future<void> _appliquerTexte(String brut, {bool immediat = false}) async {
    final q = brut.trim();
    if (immediat) {
      ref.read(searchQueryProvider.notifier).appliquerMaintenant(q);
      if (q.length >= 2) {
        await HistoriqueRechercheService.enregistrer(q);
        ref.invalidate(historiqueRechercheProvider);
      }
      return;
    }
    ref.read(searchQueryProvider.notifier).setQuery(q);
  }

  void _inscrireChamp(String texte) {
    if (_recherche.text != texte) _recherche.text = texte;
    setState(() {});
  }

  Future<void> _choisirTexte(String texte) async {
    _inscrireChamp(texte);
    await _appliquerTexte(texte, immediat: true);
    _focus.unfocus();
  }

  Future<void> _choisirSuggestion(SuggestionRecherche s) async {
    _inscrireChamp(s.libelle);
    switch (s.categorie) {
      case CategorieSuggestion.marque:
        ref
            .read(filterBrandProvider.notifier)
            .setMaison(s.maison ?? Maison(id: s.libelle, nom: s.libelle));
        ref.read(searchQueryProvider.notifier).clear();
      case CategorieSuggestion.type:
        ref.read(selectedUniverseProvider.notifier).setUniverse(s.libelle);
        ref.read(searchQueryProvider.notifier).clear();
      case CategorieSuggestion.taille:
        ref.read(filterTailleProvider.notifier).setTaille(s.libelle);
        ref.read(searchQueryProvider.notifier).clear();
      case CategorieSuggestion.etat:
        ref.read(filterEtatProvider.notifier).setEtat(s.libelle);
        ref.read(searchQueryProvider.notifier).clear();
    }
    await HistoriqueRechercheService.enregistrer(s.libelle);
    ref.invalidate(historiqueRechercheProvider);
    _focus.unfocus();
  }

  Future<void> _choisirMarqueTendance(String nom) async {
    final index = ref
        .read(indexRechercheProvider)
        .maybeWhen(data: (i) => i, orElse: () => IndexRecherche.vide);
    Maison? maison;
    for (final m in index.maisons) {
      if (m.nom.toLowerCase() == nom.toLowerCase()) {
        maison = m;
        break;
      }
    }
    await _choisirSuggestion(
      SuggestionRecherche(
        categorie: CategorieSuggestion.marque,
        libelle: nom,
        maison: maison ?? Maison(id: nom, nom: nom),
      ),
    );
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
      if (_focus.hasFocus) return;
      if (_recherche.text != suivant) {
        _recherche.text = suivant;
      }
    });

    final index = ref
        .watch(indexRechercheProvider)
        .maybeWhen(data: (i) => i, orElse: () => IndexRecherche.vide);
    final historique = ref
        .watch(historiqueRechercheProvider)
        .maybeWhen(data: (h) => h, orElse: () => const <String>[]);
    final panneau = construirePanneau(
      requete: _recherche.text,
      index: index,
      historique: historique,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.p12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: marge),
              child: _BarreRecherche(
                controller: _recherche,
                focusNode: _focus,
                filtresActifs:
                    _filtresActifs || _recherche.text.trim().isNotEmpty,
                onChanged: (v) {
                  setState(() {});
                  _appliquerTexte(v);
                },
                onSubmitted: (v) => _appliquerTexte(v, immediat: true),
                onEffacer: _effacerRecherche,
                onFiltres: () => _ouvrirFiltres(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: AppSpacing.p32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_champActif)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: marge),
                        child: PanneauSuggestionsRecherche(
                          panneau: panneau,
                          onPopulaire: _choisirTexte,
                          onMarqueTendance: _choisirMarqueTendance,
                          onSuggestion: _choisirSuggestion,
                        ),
                      )
                    else ...[
                      if (categories.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.p16),
                        BandeauDefilable(
                          key: ClosetTourKeys.universKey,
                          padding: EdgeInsets.symmetric(horizontal: marge),
                          enfants: [
                            ClosetChip(
                              label: l10n.toutes,
                              isActive: universActif.isEmpty,
                              onTap: () => ref
                                  .read(selectedUniverseProvider.notifier)
                                  .setUniverse(''),
                            ),
                            for (final nom in categories)
                              ClosetChip(
                                label: nom,
                                isActive: nom == universActif,
                                onTap: () => ref
                                    .read(selectedUniverseProvider.notifier)
                                    .setUniverse(
                                      nom == universActif ? '' : nom,
                                    ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.p16),
                      catalogue.when(
                        skipLoadingOnReload: true,
                        data: (articles) => _Resultats(
                          articles: articles,
                          onAccueil: () {
                            _reinitialiserFiltres();
                            context.go('/home');
                          },
                        ),
                        loading: () => const SizedBox(
                          height: 280,
                          child: EtatEcran.chargement(),
                        ),
                        error: (e, _) => SizedBox(
                          height: 280,
                          child: EtatEcran.erreur(
                            erreur: e,
                            onRetry: () =>
                                ref.invalidate(filteredArticlesProvider),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ouvrirFiltres(BuildContext context) => afficherFiltres(context);
}

class _Resultats extends StatelessWidget {
  const _Resultats({required this.articles, required this.onAccueil});

  final List<Article> articles;
  final VoidCallback onAccueil;

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return ClosetListeVide(
        message: ClosetL10n.of(context).aucunePieceRecherche,
        action: onAccueil,
        libelleAction: ClosetL10n.of(context).revenirAccueil,
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
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onEffacer,
    required this.onFiltres,
    required this.filtresActifs,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onEffacer;
  final VoidCallback onFiltres;
  final bool filtresActifs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ClosetTourKeys.rechercheKey,
      height: 45,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        maxLength: 120,
        buildCounter:
            (
              context, {
              required currentLength,
              required isFocused,
              maxLength,
            }) => null,
        style: ClosetTextStyles.saisie.copyWith(color: context.closetEncre),
        cursorColor: context.closetVert,
        decoration: InputDecoration(
          hintText: ClosetL10n.of(context).rechercherPiece,
          hintStyle: ClosetTextStyles.saisie.copyWith(
            color: context.closetSecondaire,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 16,
            color: context.closetSecondaire,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: context.closetSecondaire,
                  onPressed: onEffacer,
                ),
              IconButton(
                key: ClosetTourKeys.filtresKey,
                tooltip: ClosetL10n.of(context).filtrer,
                icon: Icon(
                  Icons.tune,
                  size: 18,
                  color: filtresActifs
                      ? context.closetVert
                      : context.closetSecondaire,
                ),
                onPressed: onFiltres,
              ),
            ],
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          counterText: '',
          filled: true,
          fillColor: context.closetChamp,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16,
            vertical: AppSpacing.p12,
          ),
          border: _bordure(context.closetBordure),
          enabledBorder: _bordure(context.closetBordure),
          focusedBorder: _bordure(context.closetVert),
        ),
      ),
    );
  }

  static OutlineInputBorder _bordure(Color couleur) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.bouton),
    borderSide: BorderSide(color: couleur, width: AppStroke.fin),
  );
}
