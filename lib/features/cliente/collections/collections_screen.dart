import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

<<<<<<< HEAD
import '../../../core/services/notification_service.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';
=======
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
>>>>>>> origin/main

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

class PriceFilterNotifier extends Notifier<RangeValues?> {
  @override
  RangeValues? build() => null;
  void setPriceRange(RangeValues? val) => state = val;
  void setPrice(double? val) {
    if (val == null) {
      state = null;
    } else {
      state = RangeValues(5000.0, val);
    }
  }
}

// State providers for search and filtering
<<<<<<< HEAD
final selectedUniverseProvider = NotifierProvider<UniverseNotifier, String>(UniverseNotifier.new);
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final filterBrandProvider = NotifierProvider<BrandFilterNotifier, String?>(BrandFilterNotifier.new);
final filterSizeProvider = NotifierProvider<SizeFilterNotifier, String?>(SizeFilterNotifier.new);
final filterConditionProvider = NotifierProvider<ConditionFilterNotifier, String?>(ConditionFilterNotifier.new);
final filterPriceProvider = NotifierProvider<PriceFilterNotifier, RangeValues?>(PriceFilterNotifier.new);
=======
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
final filterPriceProvider =
    NotifierProvider<PriceFilterNotifier, double?>(PriceFilterNotifier.new);
>>>>>>> origin/main

// Future provider to fetch all articles for local/dynamic filtering counts
final allArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getCatalog();
});

// Reactive filtering provider for screen results
final filteredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final universe = ref.watch<String>(selectedUniverseProvider);
  final query = ref.watch<String>(searchQueryProvider).toLowerCase();
  final brand = ref.watch<String?>(filterBrandProvider);
  final size = ref.watch<String?>(filterSizeProvider);
  final condition = ref.watch<String?>(filterConditionProvider);
  final priceRange = ref.watch<RangeValues?>(filterPriceProvider);

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
    if (priceRange != null) {
      if (a.price < priceRange.start || a.price > priceRange.end) {
        return false;
      }
    }
    return true;
  }).toList();
});

<<<<<<< HEAD
class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    if (intPrice >= 1000) {
      final thousands = intPrice ~/ 1000;
      final remainder = intPrice % 1000;
      if (remainder == 0) {
        return '$thousands.000 FCFA';
      }
      return '$thousands.${remainder.toString().padLeft(3, '0')} FCFA';
    }
    return '$intPrice FCFA';
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ClosetColors.beige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return const _FilterBottomSheetContent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedUniverse = ref.watch(selectedUniverseProvider);
    final catalogAsync = ref.watch(filteredArticlesProvider);

    final selectedBrand = ref.watch(filterBrandProvider);
    final selectedSize = ref.watch(filterSizeProvider);
    final selectedCondition = ref.watch(filterConditionProvider);
    final selectedPriceRange = ref.watch(filterPriceProvider);

    // Calculate active filter count
    int activeFiltersCount = 0;
    if (selectedUniverse != 'Tout l\'univers') activeFiltersCount++;
    if (selectedBrand != null) activeFiltersCount++;
    if (selectedSize != null) activeFiltersCount++;
    if (selectedCondition != null) activeFiltersCount++;
    if (selectedPriceRange != null) activeFiltersCount++;

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: AppBar(
        backgroundColor: ClosetColors.beige,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center Logo
              Image.asset(
                'assets/logo.png',
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/iconheader.png',
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'ClosET',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              // Right actions
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      button: true,
                      label: 'Panier',
                      child: GestureDetector(
                        onTap: () => context.go('/selection'),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: ClosetColors.ligne),
                          ),
                          child: const Icon(
                            Icons.shopping_basket_outlined,
                            color: ClosetColors.vertFonce,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      label: 'Notifications',
                      child: GestureDetector(
                        onTap: () {
                          ref.read(notificationProvider.notifier).show(
                                'Notifications',
                                'Aucune nouvelle notification pour le moment.',
                              );
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: ClosetColors.ligne),
                          ),
                          child: const Icon(
                            Icons.notifications_none_outlined,
                            color: ClosetColors.vertFonce,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: ClosetColors.ligne,
            height: 1,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Header content Adapter
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Filters Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Toutes les pièces',
                          style: GoogleFonts.ebGaramond(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: ClosetColors.vertFonce,
                          ),
                        ),
                      ),
                      // Filter settings button
                      Semantics(
                        button: true,
                        label: 'Afficher les filtres',
                        child: GestureDetector(
                          onTap: () => _showFilterBottomSheet(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: ClosetColors.ligne, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.tune_outlined,
                              color: ClosetColors.vertFonce,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sort dropdown / button
                      Semantics(
                        button: true,
                        label: 'Trier les pièces',
                        child: GestureDetector(
                          onTap: () => _showFilterBottomSheet(context),
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: ClosetColors.ligne, width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.swap_vert_outlined,
                                  color: ClosetColors.vertFonce,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Nouveautés',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ClosetColors.vertFonce,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: ClosetColors.ligne, width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref.read(searchQueryProvider.notifier).setQuery(val);
                      },
                      style: GoogleFonts.lato(color: ClosetColors.vertFonce, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search..',
                        hintStyle: GoogleFonts.lato(color: ClosetColors.vertFonce.withValues(alpha: 0.4), fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: ClosetColors.vertFonce, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),

                // EXPLORER PAR UNIVERS title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    'EXPLORER PAR UNIVERS',
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: ClosetColors.doreEncre,
                    ),
                  ),
                ),

                // Category Chips row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      'Tout l\'univers',
                      'Robes',
                      'Vestes',
                      'Sacs',
                      'Escarpins',
                      'Accessoires',
                    ].map((category) {
                      final isSelected = category == selectedUniverse;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            ref.read(selectedUniverseProvider.notifier).setUniverse(category);
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 40),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? ClosetColors.vertFonce : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(color: ClosetColors.ligne, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: GoogleFonts.lato(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : ClosetColors.vertFonce,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Dynamic Active Filter Chips for clearing (compromise to keep previous features accessible)
                if (activeFiltersCount > 0) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (selectedUniverse != 'Tout l\'univers')
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: selectedUniverse,
                              isOn: true,
                              onTap: () => _showFilterBottomSheet(context),
                              onClear: () {
                                ref.read(selectedUniverseProvider.notifier).setUniverse('Tout l\'univers');
                              },
                            ),
                          ),
                        if (selectedBrand != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: selectedBrand,
                              isOn: true,
                              onTap: () => _showFilterBottomSheet(context),
                              onClear: () {
                                ref.read(filterBrandProvider.notifier).setBrand(null);
                              },
                            ),
                          ),
                        if (selectedSize != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: 'Taille $selectedSize',
                              isOn: true,
                              onTap: () => _showFilterBottomSheet(context),
                              onClear: () {
                                ref.read(filterSizeProvider.notifier).setSize(null);
                              },
                            ),
                          ),
                        if (selectedPriceRange != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: '${selectedPriceRange.start.toInt() ~/ 1000}k-${selectedPriceRange.end.toInt() ~/ 1000}k F',
                              isOn: true,
                              onTap: () => _showFilterBottomSheet(context),
                              onClear: () {
                                ref.read(filterPriceProvider.notifier).setPriceRange(null);
                              },
                            ),
                          ),
                        if (selectedCondition != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: selectedCondition,
                              isOn: true,
                              onTap: () => _showFilterBottomSheet(context),
                              onClear: () {
                                ref.read(filterConditionProvider.notifier).setCondition(null);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Section header row: "Nouveauté du dressing"
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Nouveauté du dressing',
                        style: GoogleFonts.ebGaramond(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Clear all filters
                          ref.read(searchQueryProvider.notifier).clear();
                          ref.read(selectedUniverseProvider.notifier).setUniverse('Tout l\'univers');
                          ref.read(filterBrandProvider.notifier).setBrand(null);
                          ref.read(filterSizeProvider.notifier).setSize(null);
                          ref.read(filterConditionProvider.notifier).setCondition(null);
                          ref.read(filterPriceProvider.notifier).setPriceRange(null);
                          _searchController.clear();
                        },
                        child: Text(
                          'TOUT DÉCOUVRIR →',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: ClosetColors.doreEncre,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Grid Results or Empty state
          catalogAsync.when(
            data: (articles) {
              if (articles.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: ClosetColors.vertFonce.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune pièce ne correspond à vos critères',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ClosetColors.vertFonce.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).clear();
                            ref.read(selectedUniverseProvider.notifier).setUniverse('Tout l\'univers');
                            ref.read(filterBrandProvider.notifier).setBrand(null);
                            ref.read(filterSizeProvider.notifier).setSize(null);
                            ref.read(filterConditionProvider.notifier).setCondition(null);
                            ref.read(filterPriceProvider.notifier).setPriceRange(null);
                            _searchController.clear();
                          },
                          child: const Text(
                            'Réinitialiser les filtres',
                            style: TextStyle(
                              color: ClosetColors.doreEncre,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55, // Keep matching aspect ratio with extra metadata row
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      return _PieceCard(
                        article: articles[i],
                        formatPrice: _formatPrice,
                      );
                    },
                    childCount: articles.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: ClosetColors.dore),
                ),
              ),
            ),
            error: (e, _) => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text('Erreur de chargement'),
                ),
              ),
            ),
          ),

          // Slogan Footer Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 90),
              child: Center(
                child: Text(
                  'CLOS ET. ABIDJAN - PARIS - YAOUNDÉ',
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    letterSpacing: 2.5,
                    color: ClosetColors.noir.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
=======
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
      ref.watch<double?>(filterPriceProvider) != null;

  /// Filtres réellement posés, chacun avec le moyen de le retirer seul.
  ///
  /// La maquette `16:1954` affiche « Robes ✕ », « Taille M ✕ », « Neuf ✕ » :
  /// on doit pouvoir enlever un critère sans perdre les autres.
  List<({String label, VoidCallback retirer})> get _filtresPosees {
    final marque = ref.watch<String?>(filterBrandProvider);
    final taille = ref.watch<String?>(filterSizeProvider);
    final etat = ref.watch<String?>(filterConditionProvider);
    final prixMax = ref.watch<double?>(filterPriceProvider);

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
      if (prixMax != null)
        (
          label: 'Max ${formatPrixFcfa(prixMax)}',
          retirer: () => ref.read(filterPriceProvider.notifier).setPrice(null),
        ),
    ];
  }

  void _reinitialiserFiltres() {
    ref.read(filterBrandProvider.notifier).setBrand(null);
    ref.read(filterSizeProvider.notifier).setSize(null);
    ref.read(filterConditionProvider.notifier).setCondition(null);
    ref.read(filterPriceProvider.notifier).setPrice(null);
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
>>>>>>> origin/main
    );
  }
}

<<<<<<< HEAD
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isOn;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FilterChip({
    required this.label,
    required this.isOn,
    required this.onTap,
    this.onClear,
  });

=======
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

>>>>>>> origin/main
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
<<<<<<< HEAD
      selected: isOn,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isOn ? ClosetColors.vert : ClosetColors.creme,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isOn ? ClosetColors.vert : ClosetColors.ligne,
              width: 1.5,
=======
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
>>>>>>> origin/main
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
<<<<<<< HEAD
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isOn ? ClosetColors.creme : ClosetColors.vertFonce,
                ),
              ),
              if (isOn && onClear != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClear,
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: ClosetColors.creme,
                  ),
                ),
              ],
=======
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
>>>>>>> origin/main
            ],
          ),
        ),
      ),
    );
  }
}

<<<<<<< HEAD
class _PieceCard extends ConsumerWidget {
  final Article article;
  final String Function(double) formatPrice;

  const _PieceCard({
    required this.article,
    required this.formatPrice,
  });

  String _formatSizeAndMaterial(Article article) {
    final parts = <String>[];
    if (article.size.isNotEmpty) {
      String sizeStr = article.size;
      // Prepend T. if not already starting with T. or T
      if (!sizeStr.toUpperCase().startsWith('T')) {
        sizeStr = 'T.$sizeStr';
      } else if (sizeStr.toUpperCase().startsWith('T') && !sizeStr.toUpperCase().startsWith('T.')) {
        sizeStr = 'T.${sizeStr.substring(1)}';
      }
      parts.add(sizeStr);
    }
    if (article.material.isNotEmpty) {
      parts.add(article.material);
    }
    return parts.join('. ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistListProvider);
    final isWishlisted = wishlist.any((a) => a.id == article.id);

    // Build the photo/image area
    Widget photoWidget = Stack(
      children: [
        // Silhouette placeholder
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.46,
            heightFactor: 0.74,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1C3D2F).withValues(alpha: 0.14),
                    const Color(0xFF12241D).withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),
        ),
        
        // Image on top
        if (article.imageUrls.isNotEmpty)
          Image.network(
            article.imageUrls[0],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),

        // Tag État (Condition) - Mint Green Background with Dark Green Text
        Positioned(
          left: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFCBEFED),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              article.condition.toUpperCase(),
              style: GoogleFonts.lato(
                color: ClosetColors.vertFonce,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),

        // Heart Icon Button (only if not sold out)
        if (!article.isSoldOut)
          Positioned(
            right: 10,
            top: 10,
            child: Semantics(
              button: true,
              label: isWishlisted ? 'Retirer des favoris' : 'Ajouter aux favoris',
              child: GestureDetector(
                onTap: () {
                  ref.read(wishlistProvider.notifier).toggleWishlist(article);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ClosetColors.creme.withValues(alpha: 0.94),
                    shape: BoxShape.circle,
                    border: Border.all(color: ClosetColors.ligne),
                  ),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: isWishlisted ? ClosetColors.erreur : ClosetColors.vertFonce,
                  ),
                ),
              ),
            ),
          ),

        // Sold-out overlay banner at the bottom
        if (article.isSoldOut)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: ClosetColors.vertFonce.withValues(alpha: 0.85),
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: Text(
                'A trouvé son dressing',
                style: GoogleFonts.lato(
                  color: ClosetColors.creme,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );

    // Apply Grayscale Filter to Photo if Sold Out
    if (article.isSoldOut) {
      photoWidget = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.grey,
          BlendMode.saturation,
        ),
        child: photoWidget,
      );
    }

    return MergeSemantics(
      child: Semantics(
        label: '${article.brand}, ${article.title}, ${article.isSoldOut ? 'Indisponible' : formatPrice(article.price)}, état: ${article.condition}',
        child: GestureDetector(
          onTap: () => context.push('/product/${article.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: ClosetColors.creme,
              border: Border.all(color: ClosetColors.ligne, width: 1.0),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo area
                AspectRatio(
                  aspectRatio: 0.8, // 4:5 Aspect Ratio
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE7DCC6), Color(0xFFD6C6A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: photoWidget,
                  ),
                ),
                
                // Metadata
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MAISON ${article.brand.toUpperCase()}',
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          letterSpacing: 1.8,
                          color: ClosetColors.taupe,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        article.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.5,
                          color: ClosetColors.noir,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        article.isSoldOut ? 'Indisponible' : formatPrice(article.price),
                        style: GoogleFonts.cormorantGaramond(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: article.isSoldOut ? ClosetColors.taupe : ClosetColors.vertFonce,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatSizeAndMaterial(article),
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          color: ClosetColors.taupe.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterBottomSheetContent extends ConsumerStatefulWidget {
  const _FilterBottomSheetContent();

  @override
  ConsumerState<_FilterBottomSheetContent> createState() => _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends ConsumerState<_FilterBottomSheetContent> {
  late String _tempUniverse;
  String? _tempBrand;
  String? _tempSize;
  String? _tempCondition;
  late double _tempMinPrice;
  late double _tempMaxPrice;

  @override
  void initState() {
    super.initState();
    _tempUniverse = ref.read(selectedUniverseProvider);
    _tempBrand = ref.read(filterBrandProvider);
    _tempSize = ref.read(filterSizeProvider);
    _tempCondition = ref.read(filterConditionProvider);
    final priceRange = ref.read(filterPriceProvider);
    _tempMinPrice = priceRange?.start ?? 5000.0;
    _tempMaxPrice = priceRange?.end ?? 500000.0;
  }

  int _calculateMatchingCount(List<Article> allArticles) {
    final query = ref.read(searchQueryProvider).toLowerCase();
    return allArticles.where((a) {
      if (query.isNotEmpty &&
          !a.title.toLowerCase().contains(query) &&
          !a.brand.toLowerCase().contains(query) &&
          !a.description.toLowerCase().contains(query)) {
        return false;
      }
      if (_tempUniverse != 'Tout l\'univers' && a.universe.toLowerCase() != _tempUniverse.toLowerCase()) {
        return false;
      }
      if (_tempBrand != null && a.brand.toLowerCase() != _tempBrand!.toLowerCase()) {
        return false;
      }
      if (_tempSize != null && a.size.toLowerCase() != _tempSize!.toLowerCase()) {
        return false;
      }
      if (_tempCondition != null && a.condition.toLowerCase() != _tempCondition!.toLowerCase()) {
        return false;
      }
      if (a.price < _tempMinPrice || a.price > _tempMaxPrice) {
        return false;
      }
      return true;
    }).length;
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
        color: ClosetColors.doreEncre,
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? ClosetColors.vert : ClosetColors.creme,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? ClosetColors.vert : ClosetColors.ligne,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isSelected ? ClosetColors.creme : ClosetColors.vertFonce,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allArticlesAsync = ref.watch(allArticlesProvider);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: ClosetColors.beige,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ClosetColors.ligne,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Affiner ma recherche',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ClosetColors.vertFonce,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _tempUniverse = 'Tout l\'univers';
                          _tempBrand = null;
                          _tempSize = null;
                          _tempCondition = null;
                          _tempMinPrice = 5000.0;
                          _tempMaxPrice = 500000.0;
                        });
                      },
                      child: Text(
                        'Tout réinitialiser',
                        style: GoogleFonts.lato(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: ClosetColors.doreEncre,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Scrollable sections
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  children: [
                    // Univers section
                    _buildSectionTitle('UNIVERS'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CatalogRepository.categories.map((cat) {
                        final isSelected = _tempUniverse.toLowerCase() == cat.toLowerCase();
                        return _buildChoiceChip(
                          label: cat,
                          isSelected: isSelected,
                          onSelected: () {
                            setState(() {
                              _tempUniverse = isSelected ? 'Tout l\'univers' : cat;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Taille section
                    _buildSectionTitle('TAILLE'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['XS', 'S', 'M', 'L', 'XL', 'Unique', '34', '36', '38', '40', '42'].map((s) {
                        final isSelected = _tempSize == s;
                        return _buildChoiceChip(
                          label: s,
                          isSelected: isSelected,
                          onSelected: () {
                            setState(() {
                              _tempSize = isSelected ? null : s;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // État section
                    _buildSectionTitle('ÉTAT DE LA PIÈCE'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Neuf avec étiquette', 'Excellent', 'Très bon'].map((c) {
                        final isSelected = _tempCondition == c;
                        return _buildChoiceChip(
                          label: c,
                          isSelected: isSelected,
                          onSelected: () {
                            setState(() {
                              _tempCondition = isSelected ? null : c;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Prix section
                    _buildSectionTitle('PRIX'),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: ClosetColors.vert,
                        inactiveTrackColor: ClosetColors.ligne,
                        thumbColor: ClosetColors.creme,
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                        overlayColor: ClosetColors.vert.withValues(alpha: 0.12),
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: 11,
                          elevation: 3,
                        ),
                        trackHeight: 4,
                      ),
                      child: RangeSlider(
                        values: RangeValues(_tempMinPrice, _tempMaxPrice),
                        min: 5000,
                        max: 500000,
                        divisions: 99,
                        onChanged: (values) {
                          setState(() {
                            _tempMinPrice = values.start;
                            _tempMaxPrice = values.end;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_tempMinPrice.toInt()} F',
                            style: GoogleFonts.lato(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: ClosetColors.vertFonce,
                            ),
                          ),
                          Text(
                            '${_tempMaxPrice.toInt()} F',
                            style: GoogleFonts.lato(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: ClosetColors.vertFonce,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              
              // Apply CTA button at bottom
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: allArticlesAsync.when(
                  data: (allArticles) {
                    final count = _calculateMatchingCount(allArticles);
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(selectedUniverseProvider.notifier).setUniverse(_tempUniverse);
                          ref.read(filterBrandProvider.notifier).setBrand(_tempBrand);
                          ref.read(filterSizeProvider.notifier).setSize(_tempSize);
                          ref.read(filterConditionProvider.notifier).setCondition(_tempCondition);
                          // Only save range if it was changed from default
                          if (_tempMinPrice == 5000.0 && _tempMaxPrice == 500000.0) {
                            ref.read(filterPriceProvider.notifier).setPriceRange(null);
                          } else {
                            ref.read(filterPriceProvider.notifier).setPriceRange(RangeValues(_tempMinPrice, _tempMaxPrice));
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ClosetColors.vert,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Voir $count ${count > 1 ? "pièces" : "pièce"}',
                          style: GoogleFonts.lato(
                            color: ClosetColors.creme,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 52,
                    child: Center(
                      child: CircularProgressIndicator(color: ClosetColors.vert),
                    ),
                  ),
                  error: (err, stack) => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClosetColors.vert,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        'Fermer',
                        style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
=======
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
>>>>>>> origin/main
    );
  }
}
