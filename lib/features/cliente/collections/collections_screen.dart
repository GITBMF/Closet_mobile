import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/models/article.dart';
import '../../../core/widgets/closet_app_bar.dart';

final selectedUniverseProvider = StateProvider<String>((ref) => 'Tout l\'univers');

final catalogFutureProvider = FutureProvider.family<List<Article>, String>((ref, universe) {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getCatalog(universe: universe);
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
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedUniverse = ref.watch(selectedUniverseProvider);
    final catalogAsync = ref.watch(catalogFutureProvider(selectedUniverse));

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.offWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.goldCloset.withValues(alpha: 0.2),
                    border: Border.all(color: AppTheme.goldCloset, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: AppTheme.goldCloset,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collections',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.blackCloset,
                      ),
                    ),
                    Text(
                      'LE DRESSING',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppTheme.greyText,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22, color: AppTheme.blackCloset),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, size: 22, color: AppTheme.blackCloset),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
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
                    ref.read(selectedUniverseProvider.notifier).state = u;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.blackCloset
                          : AppTheme.warmCream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.blackCloset
                            : AppTheme.sandBeige,
                      ),
                    ),
                    child: Text(
                      u,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.blackCloset,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Grid
          Expanded(
            child: catalogAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune pièce dans cet univers',
                      style: TextStyle(color: AppTheme.greyText),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                child: CircularProgressIndicator(color: AppTheme.goldCloset),
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
}
