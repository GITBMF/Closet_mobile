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
import '../collections/collections_screen.dart';

final dressingDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch<CatalogRepository>(catalogRepositoryProvider);
  final featured = await repo.getFeatured();
  final allArticles = await repo.getCatalog();

  final Map<String, List<Article>> grouped = {};
  for (final category in CatalogRepository.categories) {
    final list = allArticles
        .where((a) => a.universe.toLowerCase() == category.toLowerCase())
        .toList();
    if (list.isNotEmpty) {
      grouped[category] = list;
    }
  }

  return {
    'featured': featured,
    'grouped': grouped,
  };
});

/// Accueil « dressing » — transcription de la maquette Figma `11:30` / `11:250`.
///
/// Carte « pièce de la semaine » en arche, visuel à la une, puis deux grilles
/// de deux colonnes séparées par des titres Cormorant et des liens dorés.
class DressingScreen extends ConsumerWidget {
  const DressingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(dressingDataProvider);

    return Scaffold(
      backgroundColor: ClosetColors.beige,
      appBar: const ClosetAppBar(),
      body: asyncData.when(
        data: (data) => _CorpsAccueil(
          featured: data['featured'] as Article,
          grouped: data['grouped'] as Map<String, List<Article>>,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: ClosetColors.dore),
        ),
        error: (e, _) => const Center(child: Text('Erreur de chargement')),
      ),
    );
  }
}

class _CorpsAccueil extends ConsumerWidget {
  const _CorpsAccueil({required this.featured, required this.grouped});

  final Article featured;
  final Map<String, List<Article>> grouped;

  /// Marge latérale de l'écran dans la maquette.
  static const double _marge = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tous = [for (final liste in grouped.values) ...liste];
    final nouveautes = tous.take(4).toList();
    final coupsDeCoeur = tous.skip(4).take(4).toList();
    final univers = grouped.keys.toList();

    void ouvrirUnivers(String categorie) {
      ref
          .read<UniverseNotifier>(selectedUniverseProvider.notifier)
          .setUniverse(categorie);
      context.go('/collections');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.p32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 23),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _marge),
            child: _CartePieceDeLaSemaine(
              article: featured,
              onTap: () => context.push('/product/${featured.id}'),
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: _CarteALaUne(
              article: featured,
              onTap: () => context.push('/product/${featured.id}'),
            ),
          ),
          const SizedBox(height: 33),
          if (univers.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 19),
              child: ClosetSurtitre('explorer par univers'),
            ),
            const SizedBox(height: AppSpacing.p16),
            _RangeeUnivers(univers: univers, onTap: ouvrirUnivers),
            const SizedBox(height: AppSpacing.p20),
          ],
          if (nouveautes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: ClosetEnTeteSection(
                titre: 'Nouveauté du dressing',
                lien: 'tout découvrir',
                onLien: () => context.go('/collections'),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            _GrilleArticles(articles: nouveautes, marge: 21),
          ],
          if (coupsDeCoeur.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.p24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21),
              child: ClosetEnTeteSection(
                titre: 'Coup de coeur Clos ET',
                lien: 'voir',
                onLien: () => context.go('/collections'),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            _GrilleArticles(articles: coupsDeCoeur, marge: 21),
          ],
          if (univers.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.p24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 19),
              child: ClosetEnTeteSection(
                titre: 'Maison du moment',
                lien: 'toutes',
                onLien: () => context.go('/collections'),
              ),
            ),
            const SizedBox(height: AppSpacing.p16),
            _RangeeUnivers(univers: univers, onTap: ouvrirUnivers),
          ],
        ],
      ),
    );
  }
}

/// Carte « pièce de la semaine » : 350 × 120, vert profond, coins supérieurs
/// très arrondis (102 / 130) qui lui donnent sa silhouette en arche.
class _CartePieceDeLaSemaine extends StatelessWidget {
  const _CartePieceDeLaSemaine({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ClosetColors.vert,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(102),
          topRight: Radius.circular(130),
          bottomLeft: Radius.circular(AppRadius.carte),
          bottomRight: Radius.circular(AppRadius.carte),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'pièce de la semaine'.toUpperCase(),
            style: ClosetTextStyles.surtitre.copyWith(
              color: ClosetColors.fond400,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          Text(
            article.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.accroche.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.p4),
          Text(
            '${article.brand}. ${article.material}. T${article.size}.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ClosetTextStyles.attribut.copyWith(
              letterSpacing: 0,
              color: ClosetColors.fond200,
            ),
          ),
          const SizedBox(height: AppSpacing.p8),
          SizedBox(
            width: 236,
            height: 34,
            child: Material(
              color: ClosetColors.fond300,
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                onTap: onTap,
                child: Center(
                  child: Text(
                    'Découvrir - ${formatPrixFcfa(article.price)}',
                    style: ClosetTextStyles.bouton.copyWith(
                      color: ClosetColors.neutre1000,
                    ),
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

/// Visuel à la une : carte de 350 × 184 dont l'image occupe 326 × 160.
class _CarteALaUne extends StatelessWidget {
  const _CarteALaUne({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 184,
        padding: const EdgeInsets.all(AppSpacing.p12),
        decoration: BoxDecoration(
          color: ClosetColors.carteFond,
          border: Border.all(
            color: ClosetColors.carteBordure,
            width: AppStroke.fin,
          ),
          borderRadius: BorderRadius.circular(AppRadius.carte),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.carte),
              child: article.imageUrls.isEmpty
                  ? const ColoredBox(color: Color(0xFFE5E5E5))
                  : Image.network(
                      article.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Color(0xFFE5E5E5)),
                    ),
            ),
            Positioned(
              top: AppSpacing.p12,
              left: AppSpacing.p8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.p12,
                  vertical: AppSpacing.p4,
                ),
                decoration: BoxDecoration(
                  color: ClosetColors.emeraude100,
                  borderRadius: BorderRadius.circular(AppRadius.vignette),
                ),
                child: Text(
                  article.condition,
                  style: ClosetTextStyles.attribut.copyWith(
                    color: ClosetColors.emeraude500,
                  ),
                ),
              ),
            ),
            const Positioned(
              top: AppSpacing.p12,
              right: AppSpacing.p8,
              child: BoutonCoeur(actif: false),
            ),
          ],
        ),
      ),
    );
  }
}



/// Rangée horizontale de puces d'univers. La première (« Tout l'univers »)
/// est active dans la maquette.
class _RangeeUnivers extends StatelessWidget {
  const _RangeeUnivers({required this.univers, required this.onTap});

  final List<String> univers;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: univers.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.p12),
        itemBuilder: (context, i) {
          if (i == 0) {
            return ClosetChip(
              label: 'Tout l’univers',
              isActive: true,
              onTap: () => context.go('/collections'),
            );
          }
          final categorie = univers[i - 1];
          return ClosetChip(
            label: categorie,
            onTap: () => onTap(categorie),
          );
        },
      ),
    );
  }
}

/// Grille de deux colonnes, cartes de 169 × 249 séparées de 12.
class _GrilleArticles extends StatelessWidget {
  const _GrilleArticles({required this.articles, required this.marge});

  final List<Article> articles;
  final double marge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: marge),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: articles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.p12,
          mainAxisSpacing: AppSpacing.p12,
          childAspectRatio: 169 / 249,
        ),
        itemBuilder: (context, i) {
          final article = articles[i];
          return ArticleCard(
            article: article,
            onTap: () => context.push('/product/${article.id}'),
          );
        },
      ),
    );
  }
}
