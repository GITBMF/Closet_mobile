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
import '../../../core/widgets/spotlight_showcase.dart';
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
    final vus = <String>{
      if (featured != null) featured.id,
    };
    final filBrut = <Article>[
      ...accueil.nouveautes,
      ...accueil.coupsDeCoeur,
    ].where((a) => vus.add(a.id)).toList();
    final marge = ClosetLayout.of(context).gouttiere;
    // Nombre de colonnes selon la largeur : téléphone, tablette, plus large.
    final largeur = MediaQuery.sizeOf(context).width;
    final colonnes = largeur >= 900 ? 4 : (largeur >= 600 ? 3 : 2);
    // Une ligne incomplète laisse des cartes seules, déséquilibrées : on
    // arrondit toujours au nombre de cartes inférieur, multiple des colonnes.
    final resteIncomplet = filBrut.length % colonnes;
    final fil = resteIncomplet == 0
        ? filBrut
        : filBrut.sublist(0, filBrut.length - resteIncomplet);

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
                key: ClosetTourKeys.pieceSemaineKey,
                article: featured,
                onTap: () => context.push('/product/${featured.id}'),
              ),
            ),
          ],
          if (fil.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.p20),
            _GrilleArticles(
              key: ClosetTourKeys.grilleKey,
              articles: fil,
              marge: marge,
              colonnes: colonnes,
            ),
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

/// Cadre unique, mis en avant : c'est le premier repère visuel de l'accueil,
/// il doit capter l'attention avant tout le reste (ombre dorée, photo plus
/// haute, titre en italique et CTA pleine largeur).
class _CartePieceDeLaSemaine extends StatelessWidget {
  const _CartePieceDeLaSemaine({
    super.key,
    required this.article,
    required this.onTap,
  });

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
        elevation: 10,
        shadowColor: ClosetColors.fond300.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.bloc),
          side: BorderSide(
            color: ClosetColors.fond300.withValues(alpha: 0.65),
            width: AppStroke.fin,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: ClosetLayout.of(context).hauteurPieceSemaine,
                    width: double.infinity,
                    child: _PhotoPiece(article: article),
                  ),
                  // Fondu vers le panneau vert, pour une transition douce
                  // plutôt qu'une coupure nette entre photo et texte.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ClosetColors.vert.withValues(alpha: 0),
                            ClosetColors.vert,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.p12,
                    top: AppSpacing.p12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ClosetColors.vert.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(AppRadius.cercle),
                        border: Border.all(
                          color: ClosetColors.fond300.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.p12,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: ClosetColors.fond300,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              l10n.pieceDeLaSemaine,
                              style: ClosetTextStyles.surtitre.copyWith(
                                color: ClosetColors.fond300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.p16,
                  AppSpacing.p4,
                  AppSpacing.p16,
                  AppSpacing.p16,
                ),
                child: Column(
                  children: [
                    Text(
                      article.libelleCategorie,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ClosetTextStyles.titreHero,
                    ),
                    const SizedBox(height: AppSpacing.p4),
                    Text(
                      formatPrixFcfa(article.price),
                      style: ClosetTextStyles.prixGrand.copyWith(
                        color: ClosetColors.fond300,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.p12),
                    SizedBox(
                      key: ClosetTourKeys.decouvrirKey,
                      width: double.infinity,
                      height: 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: ClosetColors.fond300,
                          borderRadius: BorderRadius.circular(AppRadius.cercle),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.decouvrir,
                                style: ClosetTextStyles.bouton.copyWith(
                                  color: ClosetColors.neutre1000,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward,
                                size: 15,
                                color: ClosetColors.neutre1000,
                              ),
                            ],
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

/// Grille responsive (2 colonnes en téléphone, davantage en tablette),
/// cartes de 169 × 249 séparées de 12.
class _GrilleArticles extends StatelessWidget {
  const _GrilleArticles({
    super.key,
    required this.articles,
    required this.marge,
    required this.colonnes,
  });

  final List<Article> articles;
  final double marge;
  final int colonnes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: marge),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: articles.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: colonnes,
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
