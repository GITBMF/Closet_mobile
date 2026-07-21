import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/models/article.dart';
import '../../../core/widgets/closet_app_bar.dart';

final homeDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  final featured = await repo.getFeatured();
  final newArrivals = await repo.getNewArrivals();
  final coupDeCoeur = await repo.getCoupDeCoeur();
  return {
    'featured': featured,
    'newArrivals': newArrivals,
    'coupDeCoeur': coupDeCoeur,
  };
});

class DressingScreen extends ConsumerWidget {
  const DressingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: const ClosetAppBar(),
      body: asyncData.when(
        data: (data) {
          final featured = data['featured'] as Article;
          final newArrivals = data['newArrivals'] as List<Article>;
          final coupDeCoeur = data['coupDeCoeur'] as List<Article>;
          return _HomeBody(
            featured: featured,
            newArrivals: newArrivals,
            coupDeCoeur: coupDeCoeur,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.goldCloset),
        ),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final Article featured;
  final List<Article> newArrivals;
  final List<Article> coupDeCoeur;

  const _HomeBody({
    required this.featured,
    required this.newArrivals,
    required this.coupDeCoeur,
  });

  static const List<String> _universes = [
    'Tout l\'univers',
    'Robes',
    'Vestes',
    'Sacs',
    'Escarpins',
    'Accessoires',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ─── Pièce de la semaine ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _FeaturedBanner(article: featured),
          ),
        ),

        // ─── Explorer par univers ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 0, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXPLORER PAR UNIVERS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.forestGreen,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 16),
                    itemCount: _universes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final u = _universes[i];
                      final isFirst = i == 0;
                      return _UniverseChip(label: u, isSelected: isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Nouveautés du dressing ───────────────────────────────────
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Nouveautés du dressing',
            actionLabel: 'TOUT DÉCOUVRIR →',
            onAction: () => {},
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: newArrivals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final article = newArrivals[i];
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
        ),

        // ─── Coup de cœur ClosET ──────────────────────────────────────
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Coup de cœur Clos ET',
            actionLabel: 'VOIR →',
            onAction: () => {},
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: coupDeCoeur.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final article = coupDeCoeur[i];
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
        ),

       
        // ─── Footer slogan ────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 40, 0, 32),
            child: Center(
              child: Text(
                'CLOSET ·L\'ÉLÉGANCE DURABLE',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2.5,
                  color: AppTheme.greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Widgets internes ────────────────────────────────────────────────────────

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
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: AppTheme.forestGreen,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(80),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 12, color: AppTheme.goldCloset),
                SizedBox(width: 6),
                Text(
                  'PIÈCE DE LA SEMAINE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.goldCloset,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${article.brand} · ${article.material} · T. ${article.size} · Unique',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/product/${article.id}'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.goldCloset,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Découvrir — ${_formatPrice(article.price)}  →',
                  style: const TextStyle(
                    color: Colors.white,
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
  const _UniverseChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.blackCloset : AppTheme.warmCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.blackCloset : AppTheme.sandBeige,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.blackCloset,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  const _SectionHeader(
      {required this.title,
      required this.actionLabel,
      required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.blackCloset,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.goldCloset,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
