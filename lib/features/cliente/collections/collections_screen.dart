import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';

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

class PriceFilterNotifier extends Notifier<double?> {
  @override
  double? build() => null;
  void setPrice(double? val) => state = val;
}

// State providers for search and filtering
final selectedUniverseProvider = NotifierProvider<UniverseNotifier, String>(UniverseNotifier.new);
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
final filterBrandProvider = NotifierProvider<BrandFilterNotifier, String?>(BrandFilterNotifier.new);
final filterSizeProvider = NotifierProvider<SizeFilterNotifier, String?>(SizeFilterNotifier.new);
final filterConditionProvider = NotifierProvider<ConditionFilterNotifier, String?>(ConditionFilterNotifier.new);
final filterPriceProvider = NotifierProvider<PriceFilterNotifier, double?>(PriceFilterNotifier.new);

// Reactive filtering provider
final filteredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final universe = ref.watch<String>(selectedUniverseProvider);
  final query = ref.watch<String>(searchQueryProvider).toLowerCase();
  final brand = ref.watch<String?>(filterBrandProvider);
  final size = ref.watch<String?>(filterSizeProvider);
  final condition = ref.watch<String?>(filterConditionProvider);
  final maxPrice = ref.watch<double?>(filterPriceProvider);

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
    if (condition != null && a.condition.toLowerCase() != condition.toLowerCase()) {
      return false;
    }
    if (maxPrice != null && a.price > maxPrice) {
      return false;
    }
    return true;
  }).toList();
});

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedUniverse = ref.watch<String>(selectedUniverseProvider);
    final searchQuery = ref.watch<String>(searchQueryProvider);
    final catalogAsync = ref.watch<AsyncValue<List<Article>>>(filteredArticlesProvider);

    final selectedBrand = ref.watch<String?>(filterBrandProvider);
    final selectedSize = ref.watch<String?>(filterSizeProvider);
    final selectedCondition = ref.watch<String?>(filterConditionProvider);
    final selectedPrice = ref.watch<double?>(filterPriceProvider);

    // Calculate active filter count
    int activeFiltersCount = 0;
    if (selectedUniverse != 'Tout l\'univers') activeFiltersCount++;
    if (selectedBrand != null) activeFiltersCount++;
    if (selectedSize != null) activeFiltersCount++;
    if (selectedCondition != null) activeFiltersCount++;
    if (selectedPrice != null) activeFiltersCount++;

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
                  errorBuilder: (context, error, stackTrace) => const Text('ClosET', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          // Notification trigger
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header title with circular filter button ─────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collections',
                  style: GoogleFonts.ebGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ClosetColors.vertFonce,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(context, ref),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: ClosetColors.vertFonce,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Elegant Search Bar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: ClosetColors.ligne, width: 1.5),
              ),
              child: TextField(
                onChanged: (val) => ref.read(searchQueryProvider.notifier).setQuery(val),
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: searchQuery,
                    selection: TextSelection.collapsed(offset: searchQuery.length),
                  ),
                ),
                style: GoogleFonts.lato(color: ClosetColors.vertFonce, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: GoogleFonts.lato(color: ClosetColors.vertFonce.withValues(alpha: 0.5), fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: ClosetColors.vertFonce, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: ClosetColors.vertFonce, size: 20),
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ─── EXPLORER PAR UNIVERS Subtitle ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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

          // ─── Active Filter Chips Row ────────────────────────────────
          SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  // Main Filters counter chip
                  GestureDetector(
                    onTap: () => _showFilterBottomSheet(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: ClosetColors.vertFonce,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Filtres • $activeFiltersCount',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Universe filter tag
                  if (selectedUniverse != 'Tout l\'univers') ...[
                    _ActiveFilterTag(
                      label: selectedUniverse,
                      onClear: () {
                        ref.read(selectedUniverseProvider.notifier).setUniverse('Tout l\'univers');
                      },
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Brand filter tag
                  if (selectedBrand != null) ...[
                    _ActiveFilterTag(
                      label: selectedBrand,
                      onClear: () {
                        ref.read(filterBrandProvider.notifier).setBrand(null);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Size filter tag
                  if (selectedSize != null) ...[
                    _ActiveFilterTag(
                      label: 'Taille $selectedSize',
                      onClear: () {
                        ref.read(filterSizeProvider.notifier).setSize(null);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Condition filter tag
                  if (selectedCondition != null) ...[
                    _ActiveFilterTag(
                      label: selectedCondition,
                      onClear: () {
                        ref.read(filterConditionProvider.notifier).setCondition(null);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Price filter tag
                  if (selectedPrice != null) ...[
                    _ActiveFilterTag(
                      label: '< ${selectedPrice.toInt()} F',
                      onClear: () {
                        ref.read(filterPriceProvider.notifier).setPrice(null);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),

          // ─── Dynamic results count label ────────────────────────────
          catalogAsync.when(
            data: (articles) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${articles.length} pièces, triées par nouveautés →',
                style: GoogleFonts.ebGaramond(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: ClosetColors.noir.withValues(alpha: 0.6),
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (e, stack) => const SizedBox(),
          ),

          // ─── Grid Results ───────────────────────────────────────────
          Expanded(
            child: catalogAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: ClosetColors.vertFonce.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune pièce ne correspond à vos critères',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: ClosetColors.vertFonce.withValues(alpha: 0.6), fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).clear();
                            ref.read(selectedUniverseProvider.notifier).setUniverse('Tout l\'univers');
                            ref.read(filterBrandProvider.notifier).setBrand(null);
                            ref.read(filterSizeProvider.notifier).setSize(null);
                            ref.read(filterConditionProvider.notifier).setCondition(null);
                            ref.read(filterPriceProvider.notifier).setPrice(null);
                          },
                          child: const Text(
                            'Réinitialiser les filtres',
                            style: TextStyle(color: ClosetColors.doreEncre, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: articles.length,
                  itemBuilder: (context, i) {
                    final article = articles[i];
                    return _PieceCard(
                      article: article,
                      formatPrice: _formatPrice,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: ClosetColors.dore),
              ),
              error: (e, _) => const Center(
                child: Text('Erreur de chargement'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    final selectedBrand = ref.read<String?>(filterBrandProvider);
    final selectedSize = ref.read<String?>(filterSizeProvider);
    final selectedCondition = ref.read<String?>(filterConditionProvider);
    final maxPrice = ref.read<double?>(filterPriceProvider) ?? 500000.0;

    final List<String> brands = ['Sandro', 'Maje', 'Sézane', 'Jacquemus', 'Gucci', 'Prada', 'Hermès', 'Burberry', 'Zadig & Voltaire'];
    final List<String> sizes = ['34', '36', '38', '40', '42', 'S', 'M', 'L', 'Unique'];
    final List<String> conditions = ['Neuf avec étiquette', 'Excellent', 'Très bon'];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ClosetColors.beige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String? tempBrand = selectedBrand;
            String? tempSize = selectedSize;
            String? tempCondition = selectedCondition;
            double tempPrice = maxPrice;

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filtrer la sélection',
                            style: GoogleFonts.ebGaramond(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ClosetColors.vertFonce,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(filterBrandProvider.notifier).setBrand(null);
                              ref.read(filterSizeProvider.notifier).setSize(null);
                              ref.read(filterConditionProvider.notifier).setCondition(null);
                              ref.read(filterPriceProvider.notifier).setPrice(null);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Réinitialiser',
                              style: GoogleFonts.lato(
                                color: ClosetColors.doreEncre,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Marque Section
                      Text(
                        'MARQUE',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ClosetColors.vertFonce.withValues(alpha: 0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: brands.map((b) {
                          final isSel = tempBrand?.toLowerCase() == b.toLowerCase();
                          return ChoiceChip(
                            label: Text(b),
                            selected: isSel,
                            onSelected: (selected) {
                              setState(() {
                                tempBrand = selected ? b : null;
                              });
                            },
                            selectedColor: ClosetColors.vertFonce,
                            backgroundColor: Colors.white,
                            labelStyle: GoogleFonts.lato(
                              color: isSel ? Colors.white : ClosetColors.vertFonce,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Taille Section
                      Text(
                        'TAILLE',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ClosetColors.vertFonce.withValues(alpha: 0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sizes.map((s) {
                          final isSel = tempSize == s;
                          return ChoiceChip(
                            label: Text(s),
                            selected: isSel,
                            onSelected: (selected) {
                              setState(() {
                                tempSize = selected ? s : null;
                              });
                            },
                            selectedColor: ClosetColors.vertFonce,
                            backgroundColor: Colors.white,
                            labelStyle: GoogleFonts.lato(
                              color: isSel ? Colors.white : ClosetColors.vertFonce,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // État Section
                      Text(
                        'ÉTAT DE LA PIÈCE',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ClosetColors.vertFonce.withValues(alpha: 0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: conditions.map((c) {
                          final isSel = tempCondition?.toLowerCase() == c.toLowerCase();
                          return ChoiceChip(
                            label: Text(c),
                            selected: isSel,
                            onSelected: (selected) {
                              setState(() {
                                tempCondition = selected ? c : null;
                              });
                            },
                            selectedColor: ClosetColors.vertFonce,
                            backgroundColor: Colors.white,
                            labelStyle: GoogleFonts.lato(
                              color: isSel ? Colors.white : ClosetColors.vertFonce,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Prix maximum Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PRIX MAXIMUM',
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ClosetColors.vertFonce.withValues(alpha: 0.5),
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            '${tempPrice.toInt()} FCFA',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: ClosetColors.doreEncre,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: tempPrice,
                        min: 5000,
                        max: 500000,
                        divisions: 99,
                        activeColor: ClosetColors.vertFonce,
                        inactiveColor: Colors.white,
                        onChanged: (val) {
                          setState(() {
                            tempPrice = val;
                          });
                        },
                      ),
                      const SizedBox(height: 40),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(filterBrandProvider.notifier).setBrand(tempBrand);
                            ref.read(filterSizeProvider.notifier).setSize(tempSize);
                            ref.read(filterConditionProvider.notifier).setCondition(tempCondition);
                            ref.read(filterPriceProvider.notifier).setPrice(tempPrice);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ClosetColors.vertFonce,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Appliquer les filtres',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ActiveFilterTag extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _ActiveFilterTag({
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ClosetColors.vertFonce,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieceCard extends ConsumerWidget {
  final Article article;
  final String Function(double) formatPrice;

  const _PieceCard({
    required this.article,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistListProvider);
    final isWishlisted = wishlist.any((a) => a.id == article.id);

    return MergeSemantics(
      child: Semantics(
        label: '${article.brand}, ${article.title}, ${formatPrice(article.price)}, état: ${article.condition}',
        child: GestureDetector(
          onTap: () => context.push('/product/${article.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ClosetColors.ligne, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo area
                Container(
                  height: 140,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE7DCC6), Color(0xFFD6C6A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Silhouette placeholder
                      Center(
                        child: Container(
                          width: 55,
                          height: 90,
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
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
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
                      // Tag État (Condition)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6EBE0),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            article.condition.split(' ').first.toUpperCase(),
                            style: GoogleFonts.lato(
                              color: const Color(0xFF224235),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      // Heart Icon Button
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
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isWishlisted ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isWishlisted ? ClosetColors.erreur : ClosetColors.vertFonce,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Metadata
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MAISON ${article.brand.toUpperCase()}',
                        style: GoogleFonts.lato(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: ClosetColors.doreEncre,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        article.title,
                        style: GoogleFonts.ebGaramond(
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
                        formatPrice(article.price),
                        style: GoogleFonts.ebGaramond(
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: ClosetColors.vertFonce,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'T.${article.size}. ${article.material}',
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          color: ClosetColors.taupe,
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
