import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';

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

  static const List<String> _universes = [
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
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedUniverse = ref.watch<String>(selectedUniverseProvider);
    final searchQuery = ref.watch<String>(searchQueryProvider);
    final catalogAsync = ref.watch<AsyncValue<List<Article>>>(filteredArticlesProvider);
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    // Checks if any filters are active to colorize filter icon
    final hasActiveFilters = ref.watch<String?>(filterBrandProvider) != null ||
        ref.watch<String?>(filterSizeProvider) != null ||
        ref.watch<String?>(filterConditionProvider) != null ||
        ref.watch<double?>(filterPriceProvider) != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/iconheader.png',
              width: 36,
              height: 36,
              errorBuilder: (_, _, _) => Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ClosetColors.vert,
                ),
                child: const Center(
                  child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collections',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceColor,
                  ),
                ),
                Text(
                  'LE DRESSING',
                  style: TextStyle(
                    fontSize: 8,
                    color: onSurfaceColor.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              size: 22,
              color: hasActiveFilters ? theme.colorScheme.secondary : onSurfaceColor,
            ),
            onPressed: () => _showFilterBottomSheet(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Elegant Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: onSurfaceColor.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (val) => ref.read<SearchQueryNotifier>(searchQueryProvider.notifier).setQuery(val),
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text: searchQuery,
                    selection: TextSelection.collapsed(offset: searchQuery.length),
                  ),
                ),
                style: TextStyle(color: onSurfaceColor),
                decoration: InputDecoration(
                  hintText: 'Rechercher une marque, une pièce...',
                  hintStyle: TextStyle(color: onSurfaceColor.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search, color: onSurfaceColor.withValues(alpha: 0.7)),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: onSurfaceColor),
                          onPressed: () {
                            ref.read<SearchQueryNotifier>(searchQueryProvider.notifier).clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Universe filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _universes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final u = _universes[i];
                final isSelected = u == selectedUniverse;
                return GestureDetector(
                  onTap: () {
                    ref.read<UniverseNotifier>(selectedUniverseProvider.notifier).setUniverse(u);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      u,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? theme.colorScheme.onPrimary : onSurfaceColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Grid Results
          Expanded(
            child: catalogAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: onSurfaceColor.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune pièce ne correspond à vos critères',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.6), fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            ref.read<SearchQueryNotifier>(searchQueryProvider.notifier).clear();
                            ref.read<BrandFilterNotifier>(filterBrandProvider.notifier).setBrand(null);
                            ref.read<SizeFilterNotifier>(filterSizeProvider.notifier).setSize(null);
                            ref.read<ConditionFilterNotifier>(filterConditionProvider.notifier).setCondition(null);
                            ref.read<PriceFilterNotifier>(filterPriceProvider.notifier).setPrice(null);
                          },
                          child: Text(
                            'Réinitialiser les filtres',
                            style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: articles.length,
                  itemBuilder: (context, i) {
                    final article = articles[i];
                    return ArticleCard(
                      article: article,
                      onTap: () => context.push('/product/${article.id}'),
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
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

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
      backgroundColor: theme.scaffoldBackgroundColor,
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
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: onSurfaceColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read<BrandFilterNotifier>(filterBrandProvider.notifier).setBrand(null);
                              ref.read<SizeFilterNotifier>(filterSizeProvider.notifier).setSize(null);
                              ref.read<ConditionFilterNotifier>(filterConditionProvider.notifier).setCondition(null);
                              ref.read<PriceFilterNotifier>(filterPriceProvider.notifier).setPrice(null);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Réinitialiser',
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
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
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor.withValues(alpha: 0.5),
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
                            selectedColor: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.surface,
                            labelStyle: TextStyle(
                              color: isSel ? theme.colorScheme.onPrimary : onSurfaceColor,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Taille Section
                      Text(
                        'TAILLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor.withValues(alpha: 0.5),
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
                            selectedColor: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.surface,
                            labelStyle: TextStyle(
                              color: isSel ? theme.colorScheme.onPrimary : onSurfaceColor,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // État Section
                      Text(
                        'ÉTAT DE LA PIÈCE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor.withValues(alpha: 0.5),
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
                            selectedColor: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.surface,
                            labelStyle: TextStyle(
                              color: isSel ? theme.colorScheme.onPrimary : onSurfaceColor,
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
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: onSurfaceColor.withValues(alpha: 0.5),
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            '${tempPrice.toInt()} FCFA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: tempPrice,
                        min: 5000,
                        max: 500000,
                        divisions: 99,
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: theme.colorScheme.surface,
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
                            ref.read<BrandFilterNotifier>(filterBrandProvider.notifier).setBrand(tempBrand);
                            ref.read<SizeFilterNotifier>(filterSizeProvider.notifier).setSize(tempSize);
                            ref.read<ConditionFilterNotifier>(filterConditionProvider.notifier).setCondition(tempCondition);
                            ref.read<PriceFilterNotifier>(filterPriceProvider.notifier).setPrice(tempPrice);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Appliquer les filtres',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
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
