import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../collections/collections_screen.dart';

final dressingDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch<CatalogRepository>(catalogRepositoryProvider);
  final featured = await repo.getFeatured();
  final allArticles = await repo.getCatalog();
  
  final Map<String, List<Article>> grouped = {};
  for (final category in CatalogRepository.categories) {
    final list = allArticles.where((a) => a.universe.toLowerCase() == category.toLowerCase()).toList();
    if (list.isNotEmpty) {
      grouped[category] = list;
    }
  }
  
  return {
    'featured': featured,
    'grouped': grouped,
  };
});

class DressingScreen extends ConsumerWidget {
  const DressingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(dressingDataProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const ClosetAppBar(),
      body: asyncData.when(
        data: (data) {
          final featured = data['featured'] as Article;
          final grouped = data['grouped'] as Map<String, List<Article>>;
          return _HomeBody(
            featured: featured,
            grouped: grouped,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: ClosetColors.dore),
        ),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  final Article featured;
  final Map<String, List<Article>> grouped;

  const _HomeBody({
    required this.featured,
    required this.grouped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Pièce de la semaine ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _FeaturedBanner(article: featured),
          ),

          // ─── Listes par catégorie (Style Google Play Store) ────────
          ...grouped.entries.map((entry) {
            final category = entry.key;
            final articles = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: category,
                  actionLabel: 'VOIR TOUT →',
                  onAction: () {
                    ref.read<UniverseNotifier>(selectedUniverseProvider.notifier).setUniverse(category);
                    context.go('/collections');
                  },
                ),
                SizedBox(
                  height: 280,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: articles.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final article = articles[i];
                      return SizedBox(
                        width: 180,
                        child: ArticleCard(
                          article: article,
                          onTap: () => context.push('/product/${article.id}'),
                        ),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Divider(thickness: 0.5, color: ClosetColors.ligne),
                ),
              ],
            );
          }),

          // ─── Footer slogan ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 32),
            child: Center(
              child: Text(
                'CLOSET · L\'ÉLÉGANCE DURABLE',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2.5,
                  color: onSurfaceColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  final Article article;
  const _FeaturedBanner({required this.article});

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    final thousands = intPrice ~/ 1000;
    final remainder = intPrice % 1000;
    if (remainder == 0) return '$thousands 000 FCFA';
    return '$thousands ${remainder.toString().padLeft(3, '0')} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    
    return Container(
      height: 176,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClosetColors.ligne, width: 1),
        boxShadow: [
          BoxShadow(
            color: onSurfaceColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side: Text Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 10, color: theme.colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            'PIÈCE DE LA SEMAINE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.secondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: onSurfaceColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${article.brand} · ${article.material} · T. ${article.size}',
                        style: TextStyle(
                          fontSize: 10,
                          color: onSurfaceColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/product/${article.id}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Découvrir — ${_formatPrice(article.price)}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right side: Image inside green half-circle
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
            child: Container(
              width: 110,
              height: 152,
              decoration: const BoxDecoration(
                color: ClosetColors.vert,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(76)),
              ),
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(73)),
                child: Image.network(
                  article.imageUrls[0],
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: ClosetColors.ligne,
                    child: Icon(Icons.image_not_supported_outlined, color: ClosetColors.taupe),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
