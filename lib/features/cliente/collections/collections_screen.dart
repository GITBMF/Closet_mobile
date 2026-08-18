import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/piece_card.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';
import 'filtres_sheet.dart';

// Notifiers for type-safety under strict-inference
class UniverseNotifier extends Notifier<String> {
  @override
  String build() => 'Tout l\'univers';
  void setUniverse(String val) => state = val;
}

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String val) => state = val;
  void clear() => state = '';
}

class BrandFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setBrand(String? val) => state = val;
}

class SizeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setSize(String? val) => state = val;
}

class ConditionFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setCondition(String? val) => state = val;
}

class PriceRangeFilterNotifier extends Notifier<RangeValues?> {
  @override
  RangeValues? build() => null;
  void setRange(RangeValues? val) => state = val;
}

// State providers for search and filtering
final selectedUniverseProvider =
    NotifierProvider<UniverseNotifier, String>(UniverseNotifier.new);
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final filterBrandProvider =
    NotifierProvider<BrandFilterNotifier, String?>(BrandFilterNotifier.new);
final filterSizeProvider =
    NotifierProvider<SizeFilterNotifier, String?>(SizeFilterNotifier.new);
final filterConditionProvider = NotifierProvider<ConditionFilterNotifier,
    String?>(ConditionFilterNotifier.new);
final filterPriceRangeProvider =
    NotifierProvider<PriceRangeFilterNotifier, RangeValues?>(
        PriceRangeFilterNotifier.new);

// Reactive filtering provider
final filteredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final universe = ref.watch<String>(selectedUniverseProvider);
  final query = ref.watch<String>(searchQueryProvider).toLowerCase();
  final brand = ref.watch<String?>(filterBrandProvider);
  final size = ref.watch<String?>(filterSizeProvider);
  final condition = ref.watch<String?>(filterConditionProvider);
  final priceRange = ref.watch<RangeValues?>(filterPriceRangeProvider);

  final repo = ref.watch<CatalogRepository>(catalogRepositoryProvider);
  final allArticles = await repo.getCatalog(universe: universe);

  return allArticles.where((a) {
    if (query.isNotEmpty &&
        !a.title.toLowerCase().contains(query) &&
        !a.brand.toLowerCase().contains(query) &&
        !a.description.toLowerCase().contains(query)) {
      return false;
    }
    if (brand != null && a.brand.toLowerCase() != brand.toLowerCase()) {
      return false;
    }
    if (size != null && a.size.toLowerCase() != size.toLowerCase()) {
      return false;
    }
    if (condition != null &&
        a.condition.toLowerCase() != condition.toLowerCase()) {
      return false;
    }
    if (priceRange != null && (a.price < priceRange.start || a.price > priceRange.end)) {
      return false;
    }
    return true;
  }).toList();
});

/// Collections — transcription des maquettes `14:1281` et `16:2260`.
///
/// Titre « Toutes les pièces », bouton de filtres et pilule de tri, barre de
/// recherche en pilule, puces d'univers, puis grille de deux colonnes.
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  static const List<String> universes = [
    'Tout l\'univers',
    'Robes',
    'Vestes',
    'Sacs',
    'Escarpins',
    'Accessoires',
    'Bijoux',
    'Maille',
    'Manteaux',
  ];

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
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
      ref.watch<String?>(filterBrandProvider) != null ||
      ref.watch<String?>(filterSizeProvider) != null ||
      ref.watch<String?>(filterConditionProvider) != null ||
      ref.watch<RangeValues?>(filterPriceRangeProvider) != null;

  /// Filtres réellement posés, chacun avec le moyen de le retirer seul.
  ///
  /// La maquette `16:1954` affiche « Robes ✕ », « Taille M ✕ », « Neuf ✕ » :
  /// on doit pouvoir enlever un critère sans perdre les autres.
  List<({String label, VoidCallback retirer})> get _filtresPosees {
    final marque = ref.watch<String?>(filterBrandProvider);
    final taille = ref.watch<String?>(filterSizeProvider);
    final etat = ref.watch<String?>(filterConditionProvider);
    final fourchette = ref.watch<RangeValues?>(filterPriceRangeProvider);

    return [
      if (marque != null)
        (
          label: marque,
          retirer: () => ref.read(filterBrandProvider.notifier).setBrand(null),
        ),
      if (taille != null)
        (
          label: 'Taille $taille',
          retirer: () => ref.read(filterSizeProvider.notifier).setSize(null),
        ),
      if (etat != null)
        (
          label: etat,
          retirer: () =>
              ref.read(filterConditionProvider.notifier).setCondition(null),
        ),
      if (fourchette != null)
        (
          label:
              '${formatPrixFcfa(fourchette.start)} – ${formatPrixFcfa(fourchette.end)}',
          retirer: () =>
              ref.read(filterPriceRangeProvider.notifier).setRange(null),
        ),
    ];
  }

  void _reinitialiserFiltres() {
    ref.read(filterBrandProvider.notifier).setBrand(null);
    ref.read(filterSizeProvider.notifier).setSize(null);
    ref.read(filterConditionProvider.notifier).setCondition(null);
    ref.read(filterPriceRangeProvider.notifier).setRange(null);
  }

  @override
  Widget build(BuildContext context) {
    final universSelectionne = ref.watch<String>(selectedUniverseProvider);
    final catalogue = ref.watch(filteredArticlesProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: const ClosetAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.p32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.p12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: Row(
                children: [
                  const Expanded(child: ClosetTitreEcran('Toutes les pièces')),
                  _BoutonFiltres(
                    actif: _filtresActifs,
                    onTap: () => _ouvrirFiltres(context),
                  ),
                  const SizedBox(width: AppSpacing.p8),
                  _PiluleTri(
                    label: 'Nouveautés',
                    onTap: () => _ouvrirFiltres(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
              child: _BarreRecherche(
                controller: _recherche,
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).setQuery(v),
                onEffacer: () {
                  _recherche.clear();
                  ref.read(searchQueryProvider.notifier).clear();
                },
              ),
            ),
            const SizedBox(height: AppSpacing.p24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 19),
              child: ClosetSurtitre('explorer par univers'),
            ),
            const SizedBox(height: AppSpacing.p16),
            SizedBox(
              height: 30,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.p20),
                itemCount: CollectionsScreen.universes.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.p12),
                itemBuilder: (context, i) {
                  final univers = CollectionsScreen.universes[i];
                  return ClosetChip(
                    label: univers,
                    isActive: univers == universSelectionne,
                    onTap: () => ref
                        .read<UniverseNotifier>(selectedUniverseProvider.notifier)
                        .setUniverse(univers),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.p24),
            if (_filtresActifs) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(21, 0, 21, AppSpacing.p12),
                child: _BarreFiltresActifs(
                  filtres: _filtresPosees,
                  onToutEffacer: _reinitialiserFiltres,
                ),
              ),
            ],
            catalogue.when(
              data: (articles) => _Resultats(
                articles: articles,
                univers: universSelectionne,
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(
                  child: CircularProgressIndicator(color: ClosetColors.dore),
                ),
              ),
              error: (e, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: Text('Erreur de chargement')),
              ),
            ),
            const ClosetSignature(),
          ],
        ),
      ),
    );
  }

  void _ouvrirFiltres(BuildContext context) => afficherFiltres(context);
}

class _Resultats extends StatelessWidget {
  const _Resultats({required this.articles, required this.univers});

  final List<Article> articles;
  final String univers;

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64, horizontal: 32),
        child: Center(
          child: Text(
            'Aucune pièce ne correspond à votre recherche.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: ClosetEnTeteSection(titre: univers),
        ),
        const SizedBox(height: AppSpacing.p4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: ClosetSurtitre(
            '${articles.length} pièces. triées par nouveautés',
          ),
        ),
        const SizedBox(height: AppSpacing.p16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
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
    required this.onEffacer,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onEffacer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: ClosetTextStyles.saisie.copyWith(color: ClosetColors.noir),
        cursorColor: ClosetColors.vert,
        decoration: InputDecoration(
          hintText: 'Rechercher une pièce, une maison…',
          hintStyle: ClosetTextStyles.saisie.copyWith(
            color: ClosetColors.chipTexteInactif,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: ClosetColors.chipTexteInactif,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  color: ClosetColors.chipTexteInactif,
                  onPressed: onEffacer,
                ),
          filled: true,
          fillColor: Colors.white,
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

/// Bouton rond d'ouverture des filtres (42 de diamètre).
class _BoutonFiltres extends StatelessWidget {
  const _BoutonFiltres({required this.actif, required this.onTap});

  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Filtrer',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ClosetColors.fond300,
                  width: AppStroke.fin,
                ),
              ),
              child: const Icon(
                Icons.tune,
                size: 18,
                color: ClosetColors.vert,
              ),
            ),
            if (actif)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: ClosetColors.vert,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pilule de tri : 129 × 42, rayon 80.
class _PiluleTri extends StatelessWidget {
  const _PiluleTri({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(80),
            border: Border.all(
              color: ClosetColors.fond300,
              width: AppStroke.fin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.swap_vert_rounded,
                size: 16,
                color: ClosetColors.vert,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: ClosetTextStyles.corps.copyWith(
                  color: ClosetColors.vert,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bandeau des filtres actifs — maquette `16:1954`.
///
/// Une pastille « Filtres.N » puis une pastille retirable par critère posé.
class _BarreFiltresActifs extends StatelessWidget {
  const _BarreFiltresActifs({
    required this.filtres,
    required this.onToutEffacer,
  });

  final List<({String label, VoidCallback retirer})> filtres;
  final VoidCallback onToutEffacer;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.p8,
      runSpacing: AppSpacing.p8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ClosetChip(
          label: 'Filtres.${filtres.length}',
          isActive: true,
          onTap: onToutEffacer,
        ),
        for (final f in filtres)
          ClosetChip(
            label: f.label,
            hasCloseIcon: true,
            onTap: f.retirer,
            onCloseTap: f.retirer,
          ),
      ],
    );
  }
}
