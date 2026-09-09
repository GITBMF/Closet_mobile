import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/closet_l10n.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/closet_colors.dart';
import '../../../core/theme/closet_layout.dart';
import '../../../core/theme/closet_text_styles.dart';
import '../../../core/widgets/closet_app_bar.dart';
import '../../../core/widgets/closet_feedback.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/piece_card.dart';
import '../../../core/widgets/toasts.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/catalog_repository.dart';

/// Contenu de l'accueil, branché sur `GET /pieces` + `GET /showcasing/home`.
final dressingDataProvider = FutureProvider<AccueilDressing>((ref) {
  return ref.watch<CatalogRepository>(catalogRepositoryProvider).getAccueil();
});

/// Accueil « dressing » — transcription de la maquette Figma `11:30` / `11:250`.
///
/// Cadre « pièce de la semaine » (photo + informations), visuel à la une
/// distinct s'il existe, puis grilles de deux colonnes.
class DressingScreen extends ConsumerWidget {
  const DressingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(dressingDataProvider);

    final l10n = ClosetL10n.of(context);

    ref.listen(dressingDataProvider, (precedent, suivant) {
      signaleTransitionAsync(
        ref: ref,
        context: context,
        precedent: precedent,
        suivant: suivant,
        titre: l10n.navDressing,
        messageVide: l10n.dressingVide,
        estVide: (data) => data.estVide,
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const ClosetAppBar(),
      body: asyncData.when(
        data: (data) {
          if (data.estVide) {
            return ClosetListeVide(
              message: l10n.dressingVide,
            );
          }
          return _CorpsAccueil(accueil: data);
        },
        loading: () => const EtatEcran.chargement(),
        error: (e, _) => EtatEcran.erreur(
          erreur: e,
          onRetry: () => ref.invalidate(dressingDataProvider),
        ),
      ),
    );
  }
}

class _CorpsAccueil extends StatelessWidget {
  const _CorpsAccueil({required this.accueil});

  final AccueilDressing accueil;

  @override
  Widget build(BuildContext context) {
    final featured = accueil.pieceDeLaSemaine;
    final heroBrut = accueil.hero ?? featured;
    final hero = featured != null &&
            (heroBrut?.id == featured.id ||
                _memeVisuel(featured, heroBrut))
        ? null
        : heroBrut;
    final vus = <String>{
      if (featured != null) featured.id,
      if (hero != null) hero.id,
    };
    final fil = <Article>[
      ...accueil.nouveautes,
      ...accueil.coupsDeCoeur,
    ].where((a) => vus.add(a.id)).toList();
    final marge = ClosetLayout.of(context).gouttiere;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.p32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 23),
          if (featured != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: marge),
              child: _CartePieceDeLaSemaine(
                article: featured,
                onTap: () => context.push('/product/${featured.id}'),
              ),
            ),
          ],
          if (hero != null) ...[
            const SizedBox(height: AppSpacing.p8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: marge),
              child: _CarteALaUne(
                article: hero,
                onTap: () => context.push('/product/${hero.id}'),
              ),
            ),
          ],
          if (fil.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.p20),
            _GrilleArticles(articles: fil, marge: marge),
          ],
          const SizedBox(height: AppSpacing.p24),
        ],
      ),
    );
  }
}

/// Photos vêtements locales, utilisées si le catalogue n'a pas d'image.
const _visuelsHabits = [
  'assets/onboarding_1.jpg',
  'assets/onboarding_2.jpg',
  'assets/onboarding_3.jpg',
];

String _visuelHabitPour(Article article) =>
    _visuelsHabits[article.id.hashCode.abs() % _visuelsHabits.length];

bool _memeVisuel(Article a, Article? b) {
  if (b == null) return false;
  final ua = a.imageUrls.isEmpty ? _visuelHabitPour(a) : a.imageUrls.first;
  final ub = b.imageUrls.isEmpty ? _visuelHabitPour(b) : b.imageUrls.first;
  return ua == ub;
}

/// Cadre unique : photo de la pièce et informations, sans doublon.
class _CartePieceDeLaSemaine extends StatelessWidget {
  const _CartePieceDeLaSemaine({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return Semantics(
      button: true,
      label: l10n.pieceSemaineSemantics(
        article.title,
        formatPrixFcfa(article.price),
      ),
      child: Material(
        color: ClosetColors.vert,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.bloc),
          side: BorderSide(
            color: ClosetColors.fond300.withValues(alpha: 0.55),
            width: AppStroke.fin,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: ClosetLayout.of(context).hauteurPieceSemaine,
                width: double.infinity,
                child: _PhotoPiece(article: article),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p16,
                  AppSpacing.p12,
                  AppSpacing.p16,
                  AppSpacing.p12,
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.pieceDeLaSemaine,
                      style: ClosetTextStyles.surtitre.copyWith(
                        color: ClosetColors.fond300,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    Text(
                      article.libelleCategorie,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ClosetTextStyles.accroche.copyWith(
                        color: ClosetColors.blanc,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p4),
                    Text(
                      formatPrixFcfa(article.price),
                      style: ClosetTextStyles.prix.copyWith(
                        color: ClosetColors.fond300,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p8),
                    SizedBox(
                      width: 180,
                      height: 34,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: ClosetColors.fond300,
                          borderRadius: BorderRadius.circular(AppRadius.cercle),
                        ),
                        child: Center(
                          child: Text(
                            l10n.decouvrir,
                            style: ClosetTextStyles.actionPetite.copyWith(
                              color: ClosetColors.neutre1000,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}

/// Photo de la pièce, pleine largeur — utilisée seulement si le hero
/// est une autre pièce que celle de la semaine.
class _CarteALaUne extends StatelessWidget {
  const _CarteALaUne({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 184,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.carte),
          child: _PhotoPiece(article: article),
        ),
      ),
    );
  }
}

class _PhotoPiece extends StatelessWidget {
  const _PhotoPiece({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final local = _visuelHabitPour(article);
    if (article.imageUrls.isEmpty) {
      return Image.asset(
        local,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) =>
            const ColoredBox(color: ClosetColors.gabaritImageClair),
      );
    }
    return CachedNetworkImage(
      imageUrl: article.imageUrls.first,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) =>
          const ColoredBox(color: ClosetColors.gabaritImageClair),
      errorWidget: (context, url, error) => Image.asset(
        local,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
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
          childAspectRatio: PieceCard.ratioCarteGrille,
        ),
        itemBuilder: (context, i) {
          final article = articles[i];
          return ArticleCard(
            article: article,
            categorieSeule: true,
            onTap: () => context.push('/product/${article.id}'),
          );
        },
      ),
    );
  }
}
