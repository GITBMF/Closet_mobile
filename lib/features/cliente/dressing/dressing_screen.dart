import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/closet_colors.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/models/article.dart';
import '../../../core/widgets/closet_app_bar.dart';
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

          // ─── Explorer par univers (Chips de raccourci) ──────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 0, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPLORER PAR UNIVERS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 16),
                    itemCount: CatalogRepository.categories.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final isFirst = i == 0;
                      final label = isFirst ? 'Tout l\'univers' : CatalogRepository.categories[i - 1];
                      
                      return _UniverseChip(
                        label: label,
                        isSelected: isFirst,
                        onTap: () {
                          ref.read<UniverseNotifier>(selectedUniverseProvider.notifier).setUniverse(label);
                          context.go('/collections');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
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
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(80),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 12, color: theme.colorScheme.secondary),
                const SizedBox(width: 6),
                Text(
                  'PIÈCE DE LA SEMAINE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.secondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${article.brand} · ${article.material} · T. ${article.size} · Unique',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/product/${article.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Découvrir — ${_formatPrice(article.price)}  →',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _UniverseChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UniverseChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? theme.colorScheme.onPrimary : onSurface,
          ),
        ),
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
