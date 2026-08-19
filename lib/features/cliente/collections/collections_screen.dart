import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_chip.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/closet_sections.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/piece_card.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import 'filtres_sheet.dart';

// Notifiers for type-safety under strict-inference
class UniverseNotifier extends Notifier<String> {
  @override
  String build() => '';
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

class PriceFilterNotifier extends Notifier<double?> {
  @override
  double? build() => null;
  void setPrice(double? val) => state = val;
}

/// Critères de tri de la grille.
///
/// La maquette n'affiche que la pilule « Nouveautés » (`14:1281`) et le libellé
/// « triées par nouveautés », sans dessiner le sélecteur. Les trois autres
/// critères sont donc une décision : ils recouvrent ce qu'une acheteuse attend
/// d'une grille de prix, et le tri par défaut reste celui de la maquette.
enum TriCatalogue {
  nouveautes,
  prixCroissant,
  prixDecroissant,
  maison;

  /// Libellé de la pilule, tel que la maquette l'écrit pour « Nouveautés ».
  String get libelle => switch (this) {
        TriCatalogue.nouveautes => 'Nouveautés',
        TriCatalogue.prixCroissant => 'Prix croissant',
        TriCatalogue.prixDecroissant => 'Prix décroissant',
        TriCatalogue.maison => 'Maison',
      };

  /// Forme employée dans « N pièces. triées par … ».
  String get complement => switch (this) {
        TriCatalogue.nouveautes => 'nouveautés',
        TriCatalogue.prixCroissant => 'prix croissant',
        TriCatalogue.prixDecroissant => 'prix décroissant',
        TriCatalogue.maison => 'maison',
      };
}

class TriNotifier extends Notifier<TriCatalogue> {
  @override
  TriCatalogue build() => TriCatalogue.nouveautes;
  void setTri(TriCatalogue val) => state = val;
}

final triProvider = NotifierProvider<TriNotifier, TriCatalogue>(
  TriNotifier.new,
);

// State providers for search and filtering
final selectedUniverseProvider =
    NotifierProvider<UniverseNotifier, String>(UniverseNotifier.new);
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final filterBrandProvider =
    NotifierProvider<BrandFilterNotifier, String?>(BrandFilterNotifier.new);
final filterPriceProvider =
    NotifierProvider<PriceFilterNotifier, double?>(PriceFilterNotifier.new);

// Reactive filtering provider
final filteredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final universe = ref.watch<String>(selectedUniverseProvider);
  final query = ref.watch<String>(searchQueryProvider).toLowerCase();
  final brand = ref.watch<String?>(filterBrandProvider);
  final maxPrice = ref.watch<double?>(filterPriceProvider);
  final tri = ref.watch<TriCatalogue>(triProvider);

  final repo = ref.watch<CatalogRepository>(catalogRepositoryProvider);
  String? maisonId;
  if (brand != null) {
    for (final m in await repo.getMaisons()) {
      if (m.nom.toLowerCase() == brand.toLowerCase()) {
        maisonId = m.id;
        break;
      }
    }
  }
  final retenus = await repo.getCatalog(
    universe: universe.isEmpty ? null : universe,
    filtres: FiltresCatalogue(
      maisonId: maisonId,
      recherche: query.isEmpty ? null : query,
      prixMax: maxPrice,
    ),
  );

  // « Nouveautés » conserve l'ordre du catalogue, qui est déjà chronologique
  // côté dépôt : le retrier par identifiant supposerait qu'il soit numérique.
  switch (tri) {
    case TriCatalogue.nouveautes:
      break;
    case TriCatalogue.prixCroissant:
      retenus.sort((a, b) => a.price.compareTo(b.price));
    case TriCatalogue.prixDecroissant:
      retenus.sort((a, b) => b.price.compareTo(a.price));
    case TriCatalogue.maison:
      retenus.sort(
        (a, b) => a.brand.toLowerCase().compareTo(b.brand.toLowerCase()),
      );
  }

  return retenus;
});

/// Collections — maquette « Page collection ».
///
/// En-tête compact (panier + alertes, recherche + filtre), puis la grille
/// « Pièces du dressing ».
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

List<String> universCatalogue(WidgetRef ref) {
  final async = ref.watch(universProvider);
  return async.maybeWhen(
    data: (liste) => [for (final u in liste) u.nom],
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
      ref.watch<String>(selectedUniverseProvider).isNotEmpty ||
      ref.watch<String?>(filterBrandProvider) != null ||
      ref.watch<double?>(filterPriceProvider) != null;

  List<({String label, VoidCallback retirer})> get _filtresPosees {
    final univers = ref.watch<String>(selectedUniverseProvider);
    final marque = ref.watch<String?>(filterBrandProvider);
    final prixMax = ref.watch<double?>(filterPriceProvider);

    return [
      if (univers.isNotEmpty)
        (
          label: univers,
          retirer: () => ref
              .read<UniverseNotifier>(selectedUniverseProvider.notifier)
              .setUniverse(''),
        ),
      if (marque != null)
        (
          label: marque,
          retirer: () => ref.read(filterBrandProvider.notifier).setBrand(null),
        ),
      if (prixMax != null)
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
    ref.read(filterPriceProvider.notifier).setPrice(null);
    ref.read(selectedUniverseProvider.notifier).setUniverse('');
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = ref.watch(filteredArticlesProvider);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    label: ref.watch<TriCatalogue>(triProvider).libelle,
                    onTap: _choisirTri,
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
                univers: ref.watch<String>(selectedUniverseProvider),
                tri: ref.watch<TriCatalogue>(triProvider),
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
    );
  }

  void _ouvrirFiltres(BuildContext context) => afficherFiltres(context);

  /// Feuille de choix du tri, calquée sur les autres sélecteurs de l'app.
  Future<void> _choisirTri() async {
    final choix = await showModalBottomSheet<TriCatalogue>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final courant = ref.read<TriCatalogue>(triProvider);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.p20),
                Text('Trier les pièces', style: ClosetTextStyles.titreBloc),
                const SizedBox(height: AppSpacing.p12),
                for (final t in TriCatalogue.values)
                  ListTile(
                    title: Text(t.libelle, style: ClosetTextStyles.libelle),
                    trailing: Icon(
                      t == courant
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color:
                          t == courant ? ClosetColors.vert : ClosetColors.ligne,
                    ),
                    onTap: () => Navigator.of(context).pop(t),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (choix != null) ref.read(triProvider.notifier).setTri(choix);
  }
}

class _Resultats extends StatelessWidget {
  const _Resultats({
    required this.articles,
    required this.univers,
    required this.tri,
  });

  final List<Article> articles;
  final String univers;
  final TriCatalogue tri;

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const ClosetListeVide();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: ClosetEnTeteSection(
            titre: univers.isEmpty ? 'Toutes les pièces' : univers,
          ),
        ),
        const SizedBox(height: AppSpacing.p4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: ClosetSurtitre(
            articles.length == 1
                ? '1 pièce. triée par ${tri.complement}'
                : '${articles.length} pièces. triées par ${tri.complement}',
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
        style: ClosetTextStyles.saisie.copyWith(color: context.closetEncre),
        cursorColor: ClosetColors.vert,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: ClosetTextStyles.saisie.copyWith(
            color: ClosetColors.chipTexteInactif,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
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

/// Bouton rond de l'en-tête : 42 de diamètre, fond clair cerclé d'or.
class _BoutonRond extends StatelessWidget {
  const _BoutonRond({
    required this.icone,
    required this.label,
    required this.onTap,
    this.pastille,
    this.actif = false,
  });

  final IconData icone;
  final String label;
  final VoidCallback onTap;
  final int? pastille;
  final bool actif;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ClosetColors.blanc,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ClosetColors.fond300,
                  width: AppStroke.fin,
                ),
              ),
              child: Icon(icone, size: 20, color: ClosetColors.vert),
            ),
            if (pastille != null)
              Positioned(
                top: -2,
                right: -2,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.p4),
                    decoration: const BoxDecoration(
                      color: ClosetColors.vert,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$pastille',
                      style: ClosetTextStyles.micro.copyWith(
                        color: ClosetColors.creme,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            else if (actif)
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
            color: ClosetColors.blanc,
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
