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
import '../../../core/widgets/closet_filet.dart';
import '../../../core/widgets/closet_header_button.dart';
import '../../../core/widgets/etat_ecran.dart';
import '../../../core/widgets/icone_panier.dart';
import '../../../core/widgets/jauge_etat.dart';
import '../../../core/widgets/piece_card.dart';
import '../../../core/widgets/spotlight_showcase.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/article.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/wishlist_repository.dart';

final productDetailProvider =
    FutureProvider.family<Article?, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).getById(id);
});

/// Fiche produit — transcription des maquettes `16:3328` et `16:3063`.
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.articleId});

  final String articleId;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final _pageController = PageController();
  int _imageCourante = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final articleAsync = ref.watch(productDetailProvider(widget.articleId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: articleAsync.when(
        data: (article) {
          if (article == null) {
            return EtatEcran.vide(
              icone: Icons.search_off_rounded,
              titre: l10n.pieceIntrouvableTitre,
              message: l10n.pieceIntrouvableMessage,
              action: () => context.pop(),
              libelleAction: l10n.retour,
            );
          }
          return Stack(
            children: [
              _Corps(
                article: article,
                pageController: _pageController,
                imageCourante: _imageCourante,
                onImageChangee: (i) => setState(() => _imageCourante = i),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _BarreAjout(article: article),
              ),
              // Hors du carrousel : les boutons restent visibles pendant le
              // défilement de la fiche (remarque AMINA — navigation ancrée).
              Positioned(
                top: MediaQuery.paddingOf(context).top + AppSpacing.p8,
                left: MediaQuery.paddingOf(context).left +
                    ClosetLayout.of(context).gouttiere,
                right: MediaQuery.paddingOf(context).right +
                    ClosetLayout.of(context).gouttiere,
                child: _BoutonsFiche(article: article),
              ),
            ],
          );
        },
        loading: () => const EtatEcran.chargement(),
        error: (e, _) => EtatEcran.erreur(
          erreur: e,
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.articleId)),
        ),
      ),
    );
  }
}

class _Corps extends ConsumerWidget {
  const _Corps({
    required this.article,
    required this.pageController,
    required this.imageCourante,
    required this.onImageChangee,
  });

  final Article article;
  final PageController pageController;
  final int imageCourante;
  final ValueChanged<int> onImageChangee;

  static String? _recit(Article article) {
    final story = article.story?.trim() ?? '';
    if (story.isNotEmpty) return story;
    if (article.description.trim().isNotEmpty) {
      return article.description.trim();
    }
    return null;
  }

  List<({String label, String valeur})> _caracteristiques(ClosetL10n l10n) {
    return [
      if (article.color.trim().isNotEmpty)
        (label: l10n.couleurVetement, valeur: article.color),
      if (article.size.trim().isNotEmpty)
        (label: l10n.tailleEtCoupe, valeur: article.size),
      if (article.material.trim().isNotEmpty)
        (label: l10n.matiere, valeur: article.material),
      (label: l10n.conseilsLavageLabel, valeur: article.conseilsLavage(l10n)),
      if (article.universe.trim().isNotEmpty)
        (label: l10n.universLabel, valeur: article.universe),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final recit = _recit(article);
    final lignes = _caracteristiques(l10n);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Carrousel(
            article: article,
            controller: pageController,
            indexCourant: imageCourante,
            onChange: onImageChangee,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        style: ClosetTextStyles.nomProduit.copyWith(
                          fontSize: 22,
                          letterSpacing: -0.44,
                        ),
                      ),
                    ),
                    if (article.etoilesEtat > 0) ...[
                      const SizedBox(width: AppSpacing.p8),
                      EtoilesEtat(article.etoilesEtat, taille: 14),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.p8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        formatPrixFcfa(article.price),
                        style: ClosetTextStyles.prixGrand.copyWith(
                          color: context.closetPrix,
                        ),
                      ),
                    ),
                    _StatutStock(epuise: article.isSoldOut),
                  ],
                ),
                if (article.sourceurId != null &&
                    article.libelleSourceur.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.p8),
                  _LienSourceur(article: article),
                ],
                if (article.condition.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.p12),
                  const _FiletTableau(),
                  const SizedBox(height: AppSpacing.p12),
                  JaugeEtatPiece(
                    niveau: article.niveauEtat,
                    imperfections: article.imperfections,
                  ),
                  const SizedBox(height: AppSpacing.p12),
                ],
                if (lignes.isNotEmpty) ...[
                  const _FiletTableau(),
                  for (final ligne in lignes) ...[
                    _LigneCaracteristique(
                      label: ligne.label,
                      valeur: ligne.valeur,
                    ),
                    const _FiletTableau(),
                  ],
                ],
                if (recit != null) ...[
                  const SizedBox(height: AppSpacing.p12),
                  Text(
                    recit,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: ClosetTextStyles.citation,
                  ),
                ],
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Carrousel extends StatelessWidget {
  const _Carrousel({
    required this.article,
    required this.controller,
    required this.indexCourant,
    required this.onChange,
  });

  final Article article;
  final PageController controller;
  final int indexCourant;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final images = article.imageUrls;
    final layout = ClosetLayout.of(context);

    return SizedBox(
      key: ClosetTourKeys.produitCarrouselKey,
      height: layout.hauteurHeroProduit,
      child: Stack(
        children: [
          Positioned.fill(
            child: images.isEmpty
                ? const ColoredBox(color: ClosetColors.gabaritImage)
                : PageView.builder(
                    controller: controller,
                    itemCount: images.length,
                    onPageChanged: onChange,
                    itemBuilder: (context, i) => CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          const ColoredBox(color: ClosetColors.gabaritImage),
                      errorWidget: (_, _, _) =>
                          const ColoredBox(color: ClosetColors.gabaritImage),
                    ),
                  ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: AppSpacing.p16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: ClosetColors.blanc.withValues(
                          alpha: i == indexCourant ? 1 : 0.45,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Trait des tableaux d'informations : le plus fin possible, en teinte claire.
class _FiletTableau extends StatelessWidget {
  const _FiletTableau();

  @override
  Widget build(BuildContext context) {
    return ClosetFilet(
      couleur: context.closetLigne,
      epaisseur: 0.4,
      hauteur: 0.4,
    );
  }
}

class _LigneCaracteristique extends StatelessWidget {
  const _LigneCaracteristique({required this.label, required this.valeur});

  final String label;
  final String valeur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.p8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: ClosetTextStyles.corps.copyWith(
                color: context.closetSecondaire,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.p12),
          Expanded(
            flex: 6,
            child: Text(
              valeur,
              textAlign: TextAlign.end,
              style: ClosetTextStyles.corpsMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarreAjout extends ConsumerWidget {
  const _BarreAjout({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final dejaDansSelection =
        ref.watch(cartListProvider).any((a) => a.id == article.id);
    final indisponible = article.isSoldOut;

    final layout = ClosetLayout.of(context);
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            layout.gouttiere,
            0,
            layout.gouttiere,
            AppSpacing.p12,
          ),
          child: SizedBox(
            key: ClosetTourKeys.produitAjoutKey,
            height: layout.cibleTactile,
            width: double.infinity,
            child: Material(
              color: indisponible
                  ? ClosetColors.doreDesactive
                  : context.closetAction,
              borderRadius: BorderRadius.circular(AppRadius.cercle),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.cercle),
                onTap: indisponible
                    ? null
                    : () => basculerSelection(context, ref, article),
                child: Center(
                  child: Text(
                    indisponible
                        ? l10n.indisponibleLabel
                        : dejaDansSelection
                            ? l10n.retirerDeSelection
                            : l10n.ajouterASelection,
                    style: ClosetTextStyles.bouton.copyWith(
                      color: indisponible ? ClosetColors.neutre900 : context.closetActionTexte,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Disponibilité de la pièce, affichée à droite du prix.
///
/// Réutilise [StatusBadge] et ses couleurs plutôt qu'un badge ad hoc, pour que
/// la fiche produit parle le même langage visuel que les listes de commandes.
class _StatutStock extends StatelessWidget {
  const _StatutStock({required this.epuise});

  final bool epuise;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    return epuise
        ? StatusBadge(
            text: l10n.epuise,
            backgroundColor: ClosetColors.refusFond,
            textColor: ClosetColors.refusTexte,
          )
        : StatusBadge(
            text: l10n.enStock,
            backgroundColor: ClosetColors.emeraude100,
            textColor: ClosetColors.emeraude500,
          );
  }
}

/// Retour et wishlist, épinglés en haut de la fiche produit.
///
/// Vit dans le [Stack] racine plutôt que dans le carrousel : les boutons
/// restent ainsi accessibles quelle que soit la position de défilement.
class _BoutonsFiche extends ConsumerWidget {
  const _BoutonsFiche({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ClosetL10n.of(context);
    final enWishlist =
        ref.watch(wishlistListProvider).any((a) => a.id == article.id);
    final dansSelection =
        ref.watch(cartListProvider).any((a) => a.id == article.id);
    final nbSelection = ref.watch(cartCountProvider);

    return Row(
      children: [
        ClosetBoutonHeader(
          icone: Icons.arrow_back_ios_new,
          label: l10n.retour,
          onTap: () => context.pop(),
          sansDisque: true,
        ),
        const Spacer(),
        ClosetBoutonHeader(
          icone: Icons.shopping_basket_outlined,
          dessin: (t, c) => IconePanier(
            taille: t,
            couleur: c,
            rempli: dansSelection,
          ),
          label: dansSelection
              ? l10n.dansMaSelection(nbSelection)
              : l10n.maSelection,
          pastille: nbSelection > 0 ? nbSelection : null,
          onTap: () => context.go('/selection'),
          sansDisque: true,
        ),
        ClosetBoutonHeader(
          key: ClosetTourKeys.produitFavoriKey,
          icone: enWishlist ? Icons.favorite : Icons.favorite_border,
          label: enWishlist ? l10n.retirerDeWishlist : l10n.ajouterAWishlist,
          couleurIcone: enWishlist ? ClosetColors.erreurCouture : null,
          onTap: () => basculerFavori(context, ref, article),
          sansDisque: true,
        ),
      ],
    );
  }
}

/// « Vendu par `<sourceur>` », cliquable vers l'ensemble de son catalogue.
class _LienSourceur extends StatelessWidget {
  const _LienSourceur({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final l10n = ClosetL10n.of(context);
    final nom = article.libelleSourceur;

    return Row(
      children: [
        Text(
          l10n.venduPar,
          style: ClosetTextStyles.meta.copyWith(color: context.closetSecondaire),
        ),
        Flexible(
          child: Semantics(
            button: true,
            label: l10n.voirCatalogueDe(nom),
            child: InkWell(
              onTap: () => context.push(
                '/catalogue-sourceur/${article.sourceurId}'
                '?nom=${Uri.encodeComponent(nom)}',
              ),
              child: Text(
                nom,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ClosetTextStyles.meta.copyWith(
                  color: context.closetVert,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: context.closetVert,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
