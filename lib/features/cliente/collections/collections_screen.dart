import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          label: 'Max ${formatPrixFcfa(prixMax)}',
          retirer: () => ref.read(filterPriceProvider.notifier).setPrice(null),
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
    final marge = ClosetLayout.of(context).gouttiere;

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
                child: const ClosetTitreEcran('Toutes les pièces'),
              ),
              const SizedBox(height: AppSpacing.p16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: marge),
                child: _BarreRecherche(
                  controller: _recherche,
                  filtresActifs: _filtresActifs,
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).setQuery(v),
                  onEffacer: () {
                    _recherche.clear();
                    ref.read(searchQueryProvider.notifier).clear();
                  },
                  onFiltres: () => _ouvrirFiltres(context),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              if (universCatalogue(ref).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.p8),
                  child: _RangeeStyles(
                    univers: universCatalogue(ref),
                    choisi: ref.watch<String>(selectedUniverseProvider),
                    onTap: (u) {
                      final notifier = ref.read<UniverseNotifier>(
                        selectedUniverseProvider.notifier,
                      );
                      notifier.setUniverse(
                        u == ref.read<String>(selectedUniverseProvider)
                            ? ''
                            : u,
                      );
                    },
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(marge, 0, marge, AppSpacing.p8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _PiluleTri(
                    label: ref.watch<TriCatalogue>(triProvider).libelle,
                    actif: true,
                    onTap: _choisirTri,
                  ),
                ),
              ),
              if (_filtresActifs) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(marge, 0, marge, AppSpacing.p12),
                  child: _BarreFiltresActifs(
                    filtres: _filtresPosees,
                    onToutEffacer: _reinitialiserFiltres,
                  ),
                ),
              ],
              catalogue.when(
                data: (articles) => _Resultats(
                  articles: articles,
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
      ),
    );
  }

  void _ouvrirFiltres(BuildContext context) => afficherFiltres(context);

  /// Feuille de choix du tri, calquée sur les autres sélecteurs de l'app.
  Future<void> _choisirTri() async {
    final choix = await showModalBottomSheet<TriCatalogue>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeuilleTri(
        courant: ref.read<TriCatalogue>(triProvider),
      ),
    );
    if (choix != null) ref.read(triProvider.notifier).setTri(choix);
  }
}

class _Resultats extends StatelessWidget {
  const _Resultats({
    required this.articles,
    required this.tri,
  });

  final List<Article> articles;
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
          padding: EdgeInsets.symmetric(
            horizontal: ClosetLayout.of(context).gouttiere,
          ),
          child: ClosetSurtitre(
            articles.length == 1
                ? '1 pièce · ${tri.complement}'
                : '${articles.length} pièces · ${tri.complement}',
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
    required this.onEffacer,
    required this.onFiltres,
    required this.filtresActifs,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
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
        textInputAction: TextInputAction.search,
        style: ClosetTextStyles.saisie.copyWith(color: context.closetEncre),
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

class _RangeeStyles extends StatelessWidget {
  const _RangeeStyles({
    required this.univers,
    required this.choisi,
    required this.onTap,
  });

  final List<String> univers;
  final String choisi;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
            horizontal: ClosetLayout.of(context).gouttiere,
          ),
        itemCount: univers.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.p12),
        itemBuilder: (context, i) {
          final u = univers[i];
          return ClosetChip(
            label: u,
            isActive: u == choisi,
            onTap: () => onTap(u),
          );
        },
      ),
    );
  }
}

class _FeuilleTri extends StatefulWidget {
  const _FeuilleTri({required this.courant});

  final TriCatalogue courant;

  @override
  State<_FeuilleTri> createState() => _FeuilleTriState();
}

class _FeuilleTriState extends State<_FeuilleTri> {
  late TriCatalogue _choix = widget.courant;

  @override
  Widget build(BuildContext context) {
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
                  t == _choix
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: t == _choix ? ClosetColors.vert : ClosetColors.ligne,
                ),
                onTap: () => setState(() => _choix = t),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                ClosetLayout.of(context).gouttiere,
                8,
                ClosetLayout.of(context).gouttiere,
                16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: Material(
                  color: ClosetColors.vert,
                  borderRadius: BorderRadius.circular(AppRadius.cercle),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.cercle),
                    onTap: () => Navigator.of(context).pop(_choix),
                    child: Center(
                      child: Text(
                        'Appliquer',
                        style: ClosetTextStyles.bouton.copyWith(
                          color: ClosetColors.blanc,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pilule de tri : remplie quand un critère est actif.
class _PiluleTri extends StatelessWidget {
  const _PiluleTri({
    required this.label,
    required this.onTap,
    this.actif = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool actif;

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
            color: actif ? ClosetColors.vert : ClosetColors.blanc,
            borderRadius: BorderRadius.circular(80),
            border: Border.all(
              color: ClosetColors.fond300,
              width: AppStroke.fin,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swap_vert_rounded,
                size: 16,
                color: actif ? ClosetColors.blanc : ClosetColors.vert,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: ClosetTextStyles.corps.copyWith(
                  color: actif ? ClosetColors.blanc : ClosetColors.vert,
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
